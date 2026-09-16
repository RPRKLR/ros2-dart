// PointCloud2 layouts taken from what real drivers publish: 16-byte XYZ+pad
// from most lidars, 32-byte XYZRGB from RGB-D cameras, and the truncated and
// non-dense cases that only show up on hardware.
import 'dart:typed_data';

import 'package:ros2_client/ros2_client.dart';
import 'package:test/test.dart';

/// A cloud of [count] points laid out x,y,z as float32 plus 4 bytes of padding
/// — the 16-byte stride almost every lidar driver uses.
PointCloud2 xyzCloud(int count,
    {bool bigEndian = false, int pointStep = 16, int? truncateTo}) {
  final bytes = Uint8List(count * pointStep);
  final view = ByteData.sublistView(bytes);
  final endian = bigEndian ? Endian.big : Endian.little;
  for (var i = 0; i < count; i++) {
    final at = i * pointStep;
    view.setFloat32(at, i.toDouble(), endian);
    view.setFloat32(at + 4, i * 2.0, endian);
    view.setFloat32(at + 8, i * 3.0, endian);
  }
  return PointCloud2(
    height: 1,
    width: count,
    pointStep: pointStep,
    rowStep: pointStep * count,
    isBigendian: bigEndian,
    fields: const [
      PointField(name: 'x', offset: 0, datatype: PointField.float32),
      PointField(name: 'y', offset: 4, datatype: PointField.float32),
      PointField(name: 'z', offset: 8, datatype: PointField.float32),
    ],
    data: truncateTo == null
        ? bytes
        : Uint8List.sublistView(bytes, 0, truncateTo),
  );
}

void main() {
  group('reading points', () {
    test('reads xyz interleaved for a vertex buffer', () {
      final reader = xyzCloud(4).reader();

      expect(reader.length, 4);
      expect(reader.xyz(), [
        0, 0, 0, //
        1, 2, 3, //
        2, 4, 6, //
        3, 6, 9,
      ]);
    });

    test('subsamples by stride', () {
      final reader = xyzCloud(10).reader();
      final third = reader.xyz(stride: 3);
      expect(third.length, 4 * 3);
      expect(third.sublist(0, 3), [0, 0, 0]);
      expect(third.sublist(3, 6), [3, 6, 9]);
    });

    test('reads a single field by name and index', () {
      final reader = xyzCloud(5).reader();
      expect(reader.readFloat('y', 3), 6.0);
      expect(reader.has('z'), isTrue);
      expect(reader.has('intensity'), isFalse);
      expect(reader.fieldNames, ['x', 'y', 'z']);
    });

    test('honours big-endian clouds', () {
      final reader = xyzCloud(3, bigEndian: true).reader();
      expect(reader.readFloat('x', 2), 2.0);
      expect(reader.readFloat('z', 2), 6.0);
    });

    test('does not allocate per point', () {
      // A million-point cloud must still read in bounded memory: the reader
      // holds a view, and xyz() produces exactly one Float32List.
      final reader = xyzCloud(100000).reader();
      expect(reader.length, 100000);
      final points = reader.xyz(stride: 100);
      expect(points.length, 1000 * 3);
      expect(reader.cloud.data.lengthInBytes, 1600000);
    });
  });

  group('layouts real drivers produce', () {
    test('reads an integer field as a double', () {
      // Some drivers declare intensity uint16 rather than float32.
      final bytes = Uint8List(2 * 20);
      final view = ByteData.sublistView(bytes);
      for (var i = 0; i < 2; i++) {
        view.setFloat32(i * 20, i.toDouble(), Endian.little);
        view.setUint16(i * 20 + 16, 300 + i, Endian.little);
      }
      final cloud = PointCloud2(
        width: 2,
        pointStep: 20,
        fields: const [
          PointField(name: 'x', offset: 0, datatype: PointField.float32),
          PointField(
              name: 'intensity', offset: 16, datatype: PointField.uint16),
        ],
        data: bytes,
      );

      final reader = cloud.reader();
      expect(reader.readFloat('intensity', 1), 301.0);
      expect(reader.readInt('intensity', 0), 300);
    });

    test('skips non-finite points, which mean "no return"', () {
      final bytes = Uint8List(3 * 16);
      final view = ByteData.sublistView(bytes);
      // Point 0 valid, point 1 NaN, point 2 valid.
      view.setFloat32(0, 1.0, Endian.little);
      view.setFloat32(16, double.nan, Endian.little);
      view.setFloat32(32, 3.0, Endian.little);
      final cloud = PointCloud2(
        width: 3,
        pointStep: 16,
        isDense: false,
        fields: const [
          PointField(name: 'x', offset: 0, datatype: PointField.float32),
          PointField(name: 'y', offset: 4, datatype: PointField.float32),
          PointField(name: 'z', offset: 8, datatype: PointField.float32),
        ],
        data: bytes,
      );

      // Plotting a NaN point puts garbage at the origin, so it is dropped and
      // the result is exactly the valid points, with no trailing zeros.
      final xyz = cloud.reader().xyz();
      expect(xyz.length, 2 * 3);
      expect(xyz[0], 1.0);
      expect(xyz[3], 3.0);
    });

    test('an organised cloud counts height * width', () {
      final cloud = PointCloud2(
        height: 4,
        width: 5,
        pointStep: 16,
        fields: const [
          PointField(name: 'x', offset: 0, datatype: PointField.float32),
        ],
        data: Uint8List(4 * 5 * 16),
      );
      expect(cloud.pointCount, 20);
      expect(cloud.reader().length, 20);
    });
  });

  group('malformed input', () {
    test('a truncated cloud reads the points that did arrive', () {
      // The header promises 10; only 4 points' worth of bytes came through.
      final cloud = xyzCloud(10, truncateTo: 4 * 16);
      final reader = cloud.reader();

      expect(cloud.pointCount, 10, reason: 'header still claims ten');
      expect(reader.length, 4, reason: 'but only four are readable');
      expect(reader.xyz().length, 4 * 3);
      // Reading past what arrived must be a clean range error, not a crash
      // deep in ByteData.
      expect(() => reader.readFloat('x', 5), throwsRangeError);
    });

    test('a zero point_step is rejected rather than dividing by zero', () {
      expect(
        () => PointCloud2(width: 4, pointStep: 0, data: Uint8List(64)).reader(),
        throwsA(isA<PointCloudFormatException>()),
      );
    });

    test('a field running past the end of a point is rejected', () {
      expect(
        () => PointCloud2(
          width: 1,
          pointStep: 8,
          fields: const [
            PointField(name: 'z', offset: 6, datatype: PointField.float64),
          ],
          data: Uint8List(8),
        ).reader(),
        throwsA(isA<PointCloudFormatException>()
            .having((e) => e.message, 'message', contains('spans bytes'))),
      );
    });

    test('an unknown datatype is rejected', () {
      expect(
        () => PointCloud2(
          width: 1,
          pointStep: 8,
          fields: const [PointField(name: 'x', offset: 0, datatype: 99)],
          data: Uint8List(8),
        ).reader(),
        throwsA(isA<PointCloudFormatException>()
            .having((e) => e.message, 'message', contains('datatype 99'))),
      );
    });

    test('asking for a field the cloud does not have names what it has', () {
      final reader = xyzCloud(2).reader();
      expect(
        () => reader.readFloat('rgb', 0),
        throwsA(isA<PointCloudFormatException>()
            .having((e) => e.message, 'message', contains('x, y, z'))),
      );
    });

    test('xyz on a cloud with no x field is rejected', () {
      final cloud = PointCloud2(
        width: 1,
        pointStep: 4,
        fields: const [
          PointField(
              name: 'intensity', offset: 0, datatype: PointField.float32),
        ],
        data: Uint8List(4),
      );
      expect(() => cloud.reader().xyz(),
          throwsA(isA<PointCloudFormatException>()));
    });

    test('a stride below one is rejected', () {
      expect(() => xyzCloud(4).reader().xyz(stride: 0), throwsArgumentError);
    });

    test('an empty cloud reads as empty rather than throwing', () {
      final reader = PointCloud2(width: 0, pointStep: 16, fields: const [
        PointField(name: 'x', offset: 0, datatype: PointField.float32),
        PointField(name: 'y', offset: 4, datatype: PointField.float32),
        PointField(name: 'z', offset: 8, datatype: PointField.float32),
      ]).reader();

      expect(reader.isEmpty, isTrue);
      expect(reader.length, 0);
      expect(reader.xyz(), isEmpty);
    });
  });

  group('wire round trip', () {
    test('decodes from a rosbridge-shaped map', () {
      final source = xyzCloud(3);
      final decoded = PointCloud2.fromJson(source.toJson());

      expect(decoded.width, 3);
      expect(decoded.pointStep, 16);
      expect(decoded.fields.map((f) => f.name), ['x', 'y', 'z']);
      expect(decoded.reader().xyz(), source.reader().xyz());
    });

    test('is registered under its ROS type', () {
      registerStandardMessages();
      expect(MessageRegistry.of<PointCloud2>().rosType,
          'sensor_msgs/msg/PointCloud2');
    });
  });

  group('organised clouds with row padding', () {
    test('honours row_step instead of assuming a flat run of points', () {
      // 2 rows of 2 points, 12-byte points, 32-byte rows: 8 bytes of padding
      // after each row. Depth cameras really do pad like this.
      const pointStep = 12;
      const rowStep = 32;
      final bytes = Uint8List(2 * rowStep);
      final view = ByteData.sublistView(bytes);
      var n = 1;
      for (var row = 0; row < 2; row++) {
        for (var col = 0; col < 2; col++) {
          final at = row * rowStep + col * pointStep;
          view.setFloat32(at, n.toDouble(), Endian.little);
          view.setFloat32(at + 4, n.toDouble(), Endian.little);
          view.setFloat32(at + 8, n.toDouble(), Endian.little);
          n++;
        }
      }
      final cloud = PointCloud2(
        height: 2,
        width: 2,
        pointStep: pointStep,
        rowStep: rowStep,
        fields: const [
          PointField(name: 'x', offset: 0, datatype: PointField.float32),
          PointField(name: 'y', offset: 4, datatype: PointField.float32),
          PointField(name: 'z', offset: 8, datatype: PointField.float32),
        ],
        data: bytes,
      );

      // Reading point i at i * point_step walks into the padding and shifts
      // every point after the first row.
      expect(cloud.reader().xyz(), [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4]);
      expect(cloud.reader().readFloat('x', 3), 4.0);
    });

    test('an unpadded organised cloud is unaffected', () {
      final bytes = Uint8List(4 * 12);
      final view = ByteData.sublistView(bytes);
      for (var i = 0; i < 4; i++) {
        view.setFloat32(i * 12, (i + 1).toDouble(), Endian.little);
      }
      final cloud = PointCloud2(
        height: 2,
        width: 2,
        pointStep: 12,
        rowStep: 24, // exactly width * point_step
        fields: const [
          PointField(name: 'x', offset: 0, datatype: PointField.float32),
        ],
        data: bytes,
      );
      expect(cloud.reader().readFloat('x', 3), 4.0);
    });
  });

  group('decode defaults and equality', () {
    test('an absent height and is_dense fall back to the real defaults', () {
      final cloud = PointCloud2.fromJson(const {'point_step': 1});
      // height 0 would make every point unreadable, and is_dense false would
      // claim invalid points that are not there.
      expect(cloud.height, 1);
      expect(cloud.isDense, isTrue);
    });

    test('PointCloud2 is a value type, as RosMessage promises', () {
      final a = PointCloud2(
          width: 1, pointStep: 4, data: Uint8List.fromList([1, 2, 3, 4]));
      final b = PointCloud2(
          width: 1, pointStep: 4, data: Uint8List.fromList([1, 2, 3, 4]));
      final c = PointCloud2(
          width: 1, pointStep: 4, data: Uint8List.fromList([1, 2, 3, 5]));

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('TFMessage is a value type too', () {
      final a =
          TFMessage(transforms: [const RosTransformStamped(childFrameId: 'b')]);
      final b =
          TFMessage(transforms: [const RosTransformStamped(childFrameId: 'b')]);
      final c =
          TFMessage(transforms: [const RosTransformStamped(childFrameId: 'c')]);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}
