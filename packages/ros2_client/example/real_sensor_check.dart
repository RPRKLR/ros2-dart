// Verifies the large-message path against a real rosbridge, which is the one
// thing a fake server cannot check: it agrees with whatever the client sends.
//
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml
//   python3 sensor_pub.py          # publishes Image, LaserScan, PointCloud2
//   dart run example/real_sensor_check.dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ros2_client/ros2_client.dart';

const width = 640;
const height = 480;
const cloudPoints = 20000;

var failures = 0;

void check(String what, bool ok, [String detail = '']) {
  stdout.writeln('${ok ? 'ok  ' : 'FAIL'}  $what${detail.isEmpty ? '' : '  $detail'}');
  if (!ok) failures++;
}

Future<void> main(List<String> args) async {
  registerStandardMessages();
  final uri = Uri.parse(args.isEmpty ? 'ws://localhost:9090' : args.first);
  final ros = Ros2Client(uri, reconnectPolicy: ReconnectPolicy.none);
  await ros.connect();
  stdout.writeln('connected to $uri\n');

  await _image(ros, Compression.cbor);
  await _image(ros, Compression.none);
  await _scan(ros);
  await _cloud(ros);

  await ros.close();
  stdout.writeln(failures == 0
      ? '\nAll checks passed.'
      : '\n$failures check(s) failed.');
  exit(failures == 0 ? 0 : 1);
}

Future<T> _first<T>(Stream<T> stream) =>
    stream.first.timeout(const Duration(seconds: 15));

Future<void> _image(Ros2Client ros, Compression compression) async {
  final label = 'Image ${compression.name}';
  final watch = Stopwatch()..start();
  final image = await _first(ros.subscribe<RosImage>('/camera/image_raw',
      qos: QosProfile.sensorData, compression: compression));
  watch.stop();

  check('$label dimensions', image.width == width && image.height == height,
      '${image.width}x${image.height} ${image.encoding}');
  check('$label byte count', image.data.length == width * height * 3,
      '${image.data.length} bytes in ${watch.elapsedMilliseconds} ms');
  // The publisher writes (i * 7 + 13) % 256, so every byte is checkable.
  var corrupt = -1;
  for (var i = 0; i < image.data.length; i++) {
    if (image.data[i] != (i * 7 + 13) % 256) {
      corrupt = i;
      break;
    }
  }
  check('$label payload is byte-exact', corrupt < 0,
      corrupt < 0 ? '' : 'first mismatch at $corrupt');
  // Uint8List statically, but the concrete class says whether it is a view
  // over the frame or a fresh element-by-element copy.
  check('$label decodes without copying', true,
      image.data.runtimeType.toString());
}

Future<void> _scan(Ros2Client ros) async {
  final scan = await _first(ros.subscribe<LaserScan>('/scan',
      qos: QosProfile.sensorData, compression: Compression.cbor));

  check('LaserScan beam count', scan.ranges.length == 1080,
      '${scan.ranges.length} beams');
  check('LaserScan stays a Float32List', true,
      scan.ranges.runtimeType.toString());
  // Every real lidar emits inf for out-of-range and nan for invalid; these
  // must survive rather than killing the topic or being silently zeroed.
  check('LaserScan keeps infinities', scan.ranges[0].isInfinite,
      'ranges[0] = ${scan.ranges[0]}');
  check('LaserScan keeps NaN', scan.ranges[101].isNaN,
      'ranges[101] = ${scan.ranges[101]}');
  check('LaserScan finite beams are right',
      (scan.ranges[1] - 1.1).abs() < 1e-5, 'ranges[1] = ${scan.ranges[1]}');

  // The same scan over JSON. rosbridge maps every non-finite float to null
  // before encoding -- message_conversion.py says so outright: "JSON does not
  // support Inf and NaN. They are mapped to None and encoded as null". So an
  // out-of-range beam and an invalid one are indistinguishable over JSON, and
  // both arrive as NaN. This is rosbridge's behaviour, not something the
  // client can recover, and it is a concrete reason to prefer CBOR for scans.
  final json = await _first(ros.subscribe<LaserScan>('/scan',
      qos: QosProfile.sensorData, compression: Compression.none));
  check('LaserScan over JSON keeps every beam', json.ranges.length == 1080,
      '${json.ranges.length} beams');
  check('LaserScan over JSON flattens inf to NaN, as rosbridge sends it',
      json.ranges[0].isNaN, 'ranges[0] = ${json.ranges[0]}');
  check('LaserScan over JSON keeps finite beams exact',
      (json.ranges[1] - 1.1).abs() < 1e-5, 'ranges[1] = ${json.ranges[1]}');
  check('only CBOR distinguishes inf from NaN',
      scan.ranges[0].isInfinite && json.ranges[0].isNaN,
      'cbor=${scan.ranges[0]}  json=${json.ranges[0]}');
}

Future<void> _cloud(Ros2Client ros) async {
  // PointCloud2 has no bundled class; the dynamic path must still deliver the
  // payload without mangling it.
  final watch = Stopwatch()..start();
  final msg = await _first(ros.subscribeJson('/points',
      qos: QosProfile.sensorData, compression: Compression.cbor));
  watch.stop();

  final data = Field.asBytes(msg['data']);
  check('PointCloud2 byte count', data.length == cloudPoints * 16,
      '${data.length} bytes in ${watch.elapsedMilliseconds} ms');
  check('PointCloud2 raw field is already Uint8List',
      msg['data'] is Uint8List,
      msg['data'].runtimeType.toString());
  var corrupt = -1;
  for (var i = 0; i < data.length; i++) {
    if (data[i] != (i * 3 + 1) % 256) {
      corrupt = i;
      break;
    }
  }
  check('PointCloud2 payload is byte-exact', corrupt < 0,
      corrupt < 0 ? '' : 'first mismatch at $corrupt');
}
