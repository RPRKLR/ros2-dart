// Decode throughput for the rosbridge wire formats, on realistically sized
// messages. Run with:
//
//   dart run benchmark/wire_benchmark.dart
//
// Numbers are for a release-mode VM; JIT figures are lower but the ratios
// hold. The point is the ratio between encodings, not the absolute rate.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:ros2_client/ros2_client.dart';

/// One measured case.
final class Case {
  Case(this.name, this.bytes, this.frame, this.decode);

  final String name;

  /// Size of the frame on the wire.
  final int bytes;
  final Object frame;

  /// Full decode: wire frame to a typed message.
  final void Function(Object frame) decode;
}

void main() {
  final cases = <Case>[
    ..._imageCases(640, 480),
    ..._imageCases(1920, 1080),
    ..._laserScanCases(1080),
    ..._pointCloudCases(65536),
  ];

  stdout.writeln('');
  _row('case', 'wire KB', 'msg/s', 'MB/s', 'us/msg');
  stdout.writeln('-' * 62);
  for (final c in cases) {
    final result = _measure(c);
    _row(
      c.name,
      (c.bytes / 1024).toStringAsFixed(0),
      result.perSecond.toStringAsFixed(0),
      (result.perSecond * c.bytes / (1024 * 1024)).toStringAsFixed(1),
      (result.microsPerOp).toStringAsFixed(0),
    );
  }
  stdout.writeln('');
}

void _row(String a, String b, String c, String d, String e) => stdout.writeln(
    '${a.padRight(26)}${b.padLeft(8)}${c.padLeft(10)}${d.padLeft(9)}'
    '${e.padLeft(9)}');

({double perSecond, double microsPerOp}) _measure(Case c) {
  // Warm up so the JIT has optimised the hot path before timing.
  for (var i = 0; i < 20; i++) {
    c.decode(c.frame);
  }
  final watch = Stopwatch()..start();
  var ops = 0;
  while (watch.elapsedMilliseconds < 600) {
    c.decode(c.frame);
    ops++;
  }
  watch.stop();
  final seconds = watch.elapsedMicroseconds / 1e6;
  return (
    perSecond: ops / seconds,
    microsPerOp: watch.elapsedMicroseconds / ops,
  );
}

// --- sensor_msgs/Image -------------------------------------------------

List<Case> _imageCases(int width, int height) {
  final data = Uint8List(width * height * 3);
  for (var i = 0; i < data.length; i++) {
    data[i] = i & 0xff;
  }
  final msg = {
    'header': {
      'stamp': {'sec': 1700000000, 'nanosec': 500000000},
      'frame_id': 'camera_optical_frame',
    },
    'height': height,
    'width': width,
    'encoding': 'rgb8',
    'is_bigendian': 0,
    'step': width * 3,
  };

  // JSON carries uint8[] as base64, which is what rosbridge does.
  final json = jsonEncode({
    'op': 'publish',
    'topic': '/camera/image_raw',
    'msg': {...msg, 'data': base64Encode(data)},
  });

  // CBOR carries it as a byte string -- rosbridge's cbor_conversion.py sends
  // `bytes(val)` for sequence<uint8>, not a tagged typed array.
  final cbor = cborEncode(CborValue({
    'op': 'publish',
    'topic': '/camera/image_raw',
    'msg': {...msg, 'data': CborBytes(data)},
  }));

  final label = '${width}x$height rgb8';
  return [
    Case('$label json', json.length, json, _decodeImage),
    Case('$label cbor', cbor.length, Uint8List.fromList(cbor), _decodeImage),
  ];
}

void _decodeImage(Object frame) {
  final decoded = WireCodec.decode(frame);
  final image = RosImage.fromJson(decoded['msg']! as Map<String, Object?>);
  if (image.data.isEmpty) throw StateError('empty');
}

// --- sensor_msgs/LaserScan ---------------------------------------------

List<Case> _laserScanCases(int beams) {
  final ranges = Float32List(beams);
  for (var i = 0; i < beams; i++) {
    ranges[i] = 1.0 + (i % 100) / 10.0;
  }
  final msg = {
    'header': {
      'stamp': {'sec': 1700000000, 'nanosec': 0},
      'frame_id': 'laser',
    },
    'angle_min': -math.pi,
    'angle_max': math.pi,
    'angle_increment': 2 * math.pi / beams,
    'range_min': 0.1,
    'range_max': 30.0,
  };

  final json = jsonEncode({
    'op': 'publish',
    'topic': '/scan',
    'msg': {...msg, 'ranges': ranges, 'intensities': <double>[]},
  });

  // float32[] is tag 85, little-endian, per cbor_conversion.py.
  final cbor = cborEncode(CborValue({
    'op': 'publish',
    'topic': '/scan',
    'msg': {
      ...msg,
      'ranges': CborBytes(Uint8List.sublistView(ranges),
          tags: [CborTag.float32ArrayLE]),
      'intensities': const <Object>[],
    },
  }));

  return [
    Case('$beams-beam scan json', json.length, json, _decodeScan),
    Case('$beams-beam scan cbor', cbor.length, Uint8List.fromList(cbor),
        _decodeScan),
  ];
}

void _decodeScan(Object frame) {
  final decoded = WireCodec.decode(frame);
  final scan = LaserScan.fromJson(decoded['msg']! as Map<String, Object?>);
  if (scan.ranges.isEmpty) throw StateError('empty');
}

// --- a point-cloud-sized uint8[] ---------------------------------------

List<Case> _pointCloudCases(int points) {
  // 32 bytes per point: xyz + rgb + padding, the usual PointCloud2 layout.
  final data = Uint8List(points * 32);
  for (var i = 0; i < data.length; i++) {
    data[i] = i & 0xff;
  }
  final json = jsonEncode({
    'op': 'publish',
    'topic': '/points',
    'msg': {'data': base64Encode(data)},
  });
  final cbor = cborEncode(CborValue({
    'op': 'publish',
    'topic': '/points',
    'msg': {'data': CborBytes(data)},
  }));

  void decode(Object frame) {
    final decoded = WireCodec.decode(frame);
    final msg = decoded['msg']! as Map<String, Object?>;
    final bytes = Field.asBytes(msg['data']);
    if (bytes.isEmpty) throw StateError('empty');
  }

  return [
    Case('${points ~/ 1024}k-point cloud json', json.length, json, decode),
    Case('${points ~/ 1024}k-point cloud cbor', cbor.length,
        Uint8List.fromList(cbor), decode),
  ];
}
