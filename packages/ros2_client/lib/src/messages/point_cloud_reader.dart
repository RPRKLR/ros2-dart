import 'dart:typed_data';

import 'sensor_msgs.dart';

/// Thrown when a cloud's declared layout does not match the bytes it carries.
final class PointCloudFormatException implements Exception {
  PointCloudFormatException(this.message);
  final String message;

  @override
  String toString() => 'PointCloudFormatException: $message';
}

/// Reads values out of a [PointCloud2]'s packed buffer in place.
///
/// A point cloud is a binary blob plus a description of its layout. Turning it
/// into a list of point objects costs one allocation per point per frame,
/// which for a 100k-point lidar at 10 Hz is a million allocations a second and
/// is why point cloud rendering in a naive client is unusable. Nothing here
/// allocates per point: every read is an offset into the same buffer the
/// socket delivered.
///
/// ```dart
/// final reader = cloud.reader();
/// final xyz = reader.xyz(stride: 4);       // every 4th point, for drawing
/// final near = reader.readFloat('intensity', 0);
/// ```
final class PointCloudReader {
  /// Validates the cloud's layout once, so every later read can skip checks.
  ///
  /// Throws [PointCloudFormatException] if the layout is self-contradictory.
  /// A cloud whose `data` is shorter than its header claims is *not* an error:
  /// [length] reports what is actually readable, since a truncated cloud is
  /// worth rendering partially rather than discarding.
  factory PointCloudReader(PointCloud2 cloud) {
    if (cloud.pointStep <= 0) {
      throw PointCloudFormatException(
          'point_step is ${cloud.pointStep}; a cloud with no stride cannot be '
          'read');
    }
    for (final field in cloud.fields) {
      if (field.elementSize == 0) {
        throw PointCloudFormatException(
            'field "${field.name}" has unknown datatype ${field.datatype}');
      }
      final end = field.offset + field.elementSize * _countOf(field);
      if (field.offset < 0 || end > cloud.pointStep) {
        throw PointCloudFormatException(
            'field "${field.name}" spans bytes ${field.offset}..$end of a '
            '${cloud.pointStep}-byte point');
      }
    }

    // The header may promise more points than arrived. Trust the bytes.
    final declared = cloud.pointCount;
    final available = cloud.data.lengthInBytes ~/ cloud.pointStep;
    return PointCloudReader._(
      cloud,
      ByteData.sublistView(cloud.data),
      declared < available ? declared : available,
      cloud.isBigendian ? Endian.big : Endian.little,
    );
  }

  PointCloudReader._(this.cloud, this._bytes, this.length, this._endian);

  static int _countOf(PointField field) => field.count < 1 ? 1 : field.count;

  final PointCloud2 cloud;
  final ByteData _bytes;
  final Endian _endian;

  /// Points actually readable from the buffer.
  ///
  /// Less than `width * height` when the message was truncated in transit.
  final int length;

  bool get isEmpty => length == 0;

  /// Whether the cloud carries a field by this name.
  bool has(String name) => cloud.fieldNamed(name) != null;

  /// Names of every field, in declaration order.
  List<String> get fieldNames => [for (final f in cloud.fields) f.name];

  /// Reads [name] at [index] as a double, whatever its declared datatype.
  ///
  /// Integer fields are widened rather than rejected, so `intensity` reads the
  /// same whether a driver declares it `float32` or `uint16`.
  double readFloat(String name, int index, {int element = 0}) {
    final field = _require(name);
    final at = _offsetOf(field, index, element);
    return switch (field.datatype) {
      PointField.float32 => _bytes.getFloat32(at, _endian),
      PointField.float64 => _bytes.getFloat64(at, _endian),
      _ => _readInt(field, at).toDouble(),
    };
  }

  /// Reads [name] at [index] as an int.
  ///
  /// A float field is truncated, and a non-finite one throws rather than
  /// producing a garbage integer.
  int readInt(String name, int index, {int element = 0}) {
    final field = _require(name);
    final at = _offsetOf(field, index, element);
    if (!field.isFloat) return _readInt(field, at);
    final value = field.datatype == PointField.float32
        ? _bytes.getFloat32(at, _endian)
        : _bytes.getFloat64(at, _endian);
    if (!value.isFinite) {
      throw PointCloudFormatException(
          'point $index field "$name" is $value and has no integer form');
    }
    return value.toInt();
  }

  /// The `x`, `y` and `z` fields of every [stride]-th point, interleaved.
  ///
  /// The result is `[x0, y0, z0, x1, y1, z1, ...]`, which is the layout a
  /// vertex buffer wants. [stride] subsamples: a 200k-point cloud drawn at
  /// `stride: 8` is 25k points, which is usually indistinguishable on screen
  /// and eight times cheaper.
  ///
  /// Points with a non-finite coordinate are skipped, because a cloud that is
  /// not `is_dense` uses NaN to mean "no return" and plotting those puts
  /// garbage at the origin.
  Float32List xyz({int stride = 1}) {
    if (stride < 1) {
      throw ArgumentError.value(stride, 'stride', 'must be at least 1');
    }
    final x = _require('x');
    final y = _require('y');
    final z = _require('z');

    final capacity = ((length + stride - 1) ~/ stride) * 3;
    final out = Float32List(capacity);
    var n = 0;
    for (var i = 0; i < length; i += stride) {
      final base = i * cloud.pointStep;
      final px = _coordinate(x, base);
      final py = _coordinate(y, base);
      final pz = _coordinate(z, base);
      if (!px.isFinite || !py.isFinite || !pz.isFinite) continue;
      out[n++] = px;
      out[n++] = py;
      out[n++] = pz;
    }
    // Exact-length view; no copy, and no trailing zeros to draw at the origin.
    return Float32List.sublistView(out, 0, n);
  }

  double _coordinate(PointField field, int base) {
    final at = base + field.offset;
    return switch (field.datatype) {
      PointField.float32 => _bytes.getFloat32(at, _endian),
      PointField.float64 => _bytes.getFloat64(at, _endian),
      _ => _readInt(field, at).toDouble(),
    };
  }

  int _readInt(PointField field, int at) => switch (field.datatype) {
        PointField.int8 => _bytes.getInt8(at),
        PointField.uint8 => _bytes.getUint8(at),
        PointField.int16 => _bytes.getInt16(at, _endian),
        PointField.uint16 => _bytes.getUint16(at, _endian),
        PointField.int32 => _bytes.getInt32(at, _endian),
        PointField.uint32 => _bytes.getUint32(at, _endian),
        _ => throw PointCloudFormatException(
            'field "${field.name}" has unknown datatype ${field.datatype}'),
      };

  PointField _require(String name) {
    final field = cloud.fieldNamed(name);
    if (field == null) {
      throw PointCloudFormatException(
          'no field "$name" in this cloud; it has ${fieldNames.join(", ")}');
    }
    return field;
  }

  int _offsetOf(PointField field, int index, int element) {
    if (index < 0 || index >= length) {
      throw RangeError.index(index, this, 'index', null, length);
    }
    final count = _countOf(field);
    if (element < 0 || element >= count) {
      throw RangeError.index(element, field, 'element', null, count);
    }
    return index * cloud.pointStep +
        field.offset +
        element * field.elementSize;
  }

  @override
  String toString() =>
      'PointCloudReader($length points, ${fieldNames.join(",")})';
}
