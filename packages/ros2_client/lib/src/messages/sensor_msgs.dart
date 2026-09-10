import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'conversions.dart';
import 'geometry_msgs.dart';
import 'message.dart';
import 'point_cloud_reader.dart';
import 'std_msgs.dart';

/// `sensor_msgs/msg/Image`.
///
/// Subscribe with [Compression.cbor] — under JSON the `data` field arrives
/// base64-encoded and costs roughly 10x more to move and decode.
@immutable
final class RosImage implements RosMessage {
  const RosImage({
    this.header = const Header(),
    this.height = 0,
    this.width = 0,
    this.encoding = '',
    this.isBigendian = 0,
    this.step = 0,
    required this.data,
  });

  factory RosImage.fromJson(Map<String, Object?> json) => RosImage(
        header: Field.asMessage(json['header'], Header.fromJson),
        height: Field.asInt(json['height']),
        width: Field.asInt(json['width']),
        encoding: Field.asString(json['encoding']),
        isBigendian: Field.asInt(json['is_bigendian']),
        step: Field.asInt(json['step']),
        data: Field.asBytes(json['data']),
      );

  final Header header;
  final int height;
  final int width;

  /// e.g. `rgb8`, `bgr8`, `mono8`, `16UC1`.
  final String encoding;
  final int isBigendian;

  /// Row length in bytes.
  final int step;
  final Uint8List data;

  /// Bytes per pixel implied by [encoding], or `null` if unrecognised.
  int? get bytesPerPixel => switch (encoding) {
        'mono8' || '8UC1' => 1,
        'mono16' || '16UC1' => 2,
        'rgb8' || 'bgr8' || '8UC3' => 3,
        'rgba8' || 'bgra8' || '8UC4' => 4,
        _ => null,
      };

  @override
  String get rosType => 'sensor_msgs/msg/Image';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'height': height,
        'width': width,
        'encoding': encoding,
        'is_bigendian': isBigendian,
        'step': step,
        'data': Field.encodeBytes(data),
      };

  @override
  String toString() =>
      'RosImage(${width}x$height, $encoding, ${data.lengthInBytes} bytes)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RosImage &&
          other.header == header &&
          other.height == height &&
          other.width == width &&
          other.encoding == encoding &&
          other.isBigendian == isBigendian &&
          other.step == step &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hash(
        header,
        height,
        width,
        encoding,
        isBigendian,
        step,
        Object.hashAll(data),
      );
}

/// `sensor_msgs/msg/CompressedImage` — usually the cheapest way to stream a
/// camera to a UI, since the payload is already JPEG/PNG and can be handed
/// straight to a Flutter `RosImage.memory`.
@immutable
final class CompressedImage implements RosMessage {
  const CompressedImage({
    this.header = const Header(),
    this.format = '',
    required this.data,
  });

  factory CompressedImage.fromJson(Map<String, Object?> json) =>
      CompressedImage(
        header: Field.asMessage(json['header'], Header.fromJson),
        format: Field.asString(json['format']),
        data: Field.asBytes(json['data']),
      );

  final Header header;

  /// e.g. `jpeg`, `png`, or `rgb8; jpeg compressed bgr8`.
  final String format;
  final Uint8List data;

  @override
  String get rosType => 'sensor_msgs/msg/CompressedImage';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'format': format,
        'data': Field.encodeBytes(data),
      };

  @override
  String toString() => 'CompressedImage($format, ${data.lengthInBytes} bytes)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompressedImage &&
          other.header == header &&
          other.format == format &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hash(
        header,
        format,
        Object.hashAll(data),
      );
}

/// `sensor_msgs/msg/LaserScan`.
@immutable
final class LaserScan implements RosMessage {
  const LaserScan({
    this.header = const Header(),
    this.angleMin = 0,
    this.angleMax = 0,
    this.angleIncrement = 0,
    this.timeIncrement = 0,
    this.scanTime = 0,
    this.rangeMin = 0,
    this.rangeMax = 0,
    required this.ranges,
    required this.intensities,
  });

  factory LaserScan.fromJson(Map<String, Object?> json) => LaserScan(
        header: Field.asMessage(json['header'], Header.fromJson),
        angleMin: Field.asDouble(json['angle_min']),
        angleMax: Field.asDouble(json['angle_max']),
        angleIncrement: Field.asDouble(json['angle_increment']),
        timeIncrement: Field.asDouble(json['time_increment']),
        scanTime: Field.asDouble(json['scan_time']),
        rangeMin: Field.asDouble(json['range_min']),
        rangeMax: Field.asDouble(json['range_max']),
        ranges: Field.asFloat32List(json['ranges']),
        intensities: Field.asFloat32List(json['intensities']),
      );

  final Header header;
  final double angleMin, angleMax, angleIncrement;
  final double timeIncrement, scanTime;
  final double rangeMin, rangeMax;
  final Float32List ranges;
  final Float32List intensities;

  /// Bearing of sample [i] in radians.
  double angleAt(int i) => angleMin + i * angleIncrement;

  @override
  String get rosType => 'sensor_msgs/msg/LaserScan';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'angle_min': angleMin,
        'angle_max': angleMax,
        'angle_increment': angleIncrement,
        'time_increment': timeIncrement,
        'scan_time': scanTime,
        'range_min': rangeMin,
        'range_max': rangeMax,
        'ranges': Field.encodeNumbers(ranges),
        'intensities': Field.encodeNumbers(intensities),
      };

  @override
  String toString() => 'LaserScan(${ranges.length} samples)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LaserScan &&
          other.header == header &&
          other.angleMin == angleMin &&
          other.angleMax == angleMax &&
          other.angleIncrement == angleIncrement &&
          other.timeIncrement == timeIncrement &&
          other.scanTime == scanTime &&
          other.rangeMin == rangeMin &&
          other.rangeMax == rangeMax &&
          _listEquals(other.ranges, ranges) &&
          _listEquals(other.intensities, intensities));

  @override
  int get hashCode => Object.hash(
        header,
        angleMin,
        angleMax,
        angleIncrement,
        timeIncrement,
        scanTime,
        rangeMin,
        rangeMax,
        Object.hashAll(ranges),
        Object.hashAll(intensities),
      );
}

/// `sensor_msgs/msg/Imu`.
@immutable
final class Imu implements RosMessage {
  const Imu({
    this.header = const Header(),
    this.orientation = Quaternion.identity,
    this.angularVelocity = Vector3.zero,
    this.linearAcceleration = Vector3.zero,
  });

  factory Imu.fromJson(Map<String, Object?> json) => Imu(
        header: Field.asMessage(json['header'], Header.fromJson),
        orientation: Field.asMessage(json['orientation'], Quaternion.fromJson),
        angularVelocity:
            Field.asMessage(json['angular_velocity'], Vector3.fromJson),
        linearAcceleration:
            Field.asMessage(json['linear_acceleration'], Vector3.fromJson),
      );

  final Header header;
  final Quaternion orientation;
  final Vector3 angularVelocity;
  final Vector3 linearAcceleration;

  @override
  String get rosType => 'sensor_msgs/msg/Imu';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'orientation': orientation.toJson(),
        'angular_velocity': angularVelocity.toJson(),
        'linear_acceleration': linearAcceleration.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Imu &&
          other.header == header &&
          other.orientation == orientation &&
          other.angularVelocity == angularVelocity &&
          other.linearAcceleration == linearAcceleration);

  @override
  int get hashCode => Object.hash(
        header,
        orientation,
        angularVelocity,
        linearAcceleration,
      );
}

/// `sensor_msgs/msg/JointState`.
@immutable
final class JointState implements RosMessage {
  const JointState({
    this.header = const Header(),
    this.name = const [],
    required this.position,
    required this.velocity,
    required this.effort,
  });

  factory JointState.fromJson(Map<String, Object?> json) => JointState(
        header: Field.asMessage(json['header'], Header.fromJson),
        name: Field.asStringList(json['name']),
        position: Field.asFloat64List(json['position']),
        velocity: Field.asFloat64List(json['velocity']),
        effort: Field.asFloat64List(json['effort']),
      );

  final Header header;
  final List<String> name;
  final Float64List position;
  final Float64List velocity;
  final Float64List effort;

  /// Position of the joint called [jointName], or `null` if absent.
  double? positionOf(String jointName) {
    final i = name.indexOf(jointName);
    return (i >= 0 && i < position.length) ? position[i] : null;
  }

  @override
  String get rosType => 'sensor_msgs/msg/JointState';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'name': name,
        'position': Field.encodeNumbers(position),
        'velocity': Field.encodeNumbers(velocity),
        'effort': Field.encodeNumbers(effort),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JointState &&
          other.header == header &&
          _listEquals(other.name, name) &&
          _listEquals(other.position, position) &&
          _listEquals(other.velocity, velocity) &&
          _listEquals(other.effort, effort));

  @override
  int get hashCode => Object.hash(
        header,
        Object.hashAll(name),
        Object.hashAll(position),
        Object.hashAll(velocity),
        Object.hashAll(effort),
      );
}

/// `sensor_msgs/msg/BatteryState`.
@immutable
final class BatteryState implements RosMessage {
  const BatteryState({
    this.header = const Header(),
    this.voltage = 0,
    this.current = 0,
    this.charge = 0,
    this.capacity = 0,
    this.percentage = 0,
    this.powerSupplyStatus = 0,
    this.present = false,
  });

  factory BatteryState.fromJson(Map<String, Object?> json) => BatteryState(
        header: Field.asMessage(json['header'], Header.fromJson),
        voltage: Field.asDouble(json['voltage']),
        current: Field.asDouble(json['current']),
        charge: Field.asDouble(json['charge']),
        capacity: Field.asDouble(json['capacity']),
        percentage: Field.asDouble(json['percentage']),
        powerSupplyStatus: Field.asInt(json['power_supply_status']),
        present: Field.asBool(json['present']),
      );

  final Header header;
  final double voltage, current, charge, capacity;

  /// Charge fraction in `0.0..1.0`.
  final double percentage;
  final int powerSupplyStatus;
  final bool present;

  bool get isCharging => powerSupplyStatus == 1;

  @override
  String get rosType => 'sensor_msgs/msg/BatteryState';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'voltage': voltage,
        'current': current,
        'charge': charge,
        'capacity': capacity,
        'percentage': percentage,
        'power_supply_status': powerSupplyStatus,
        'present': present,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatteryState &&
          other.header == header &&
          other.voltage == voltage &&
          other.current == current &&
          other.charge == charge &&
          other.capacity == capacity &&
          other.percentage == percentage &&
          other.powerSupplyStatus == powerSupplyStatus &&
          other.present == present);

  @override
  int get hashCode => Object.hash(
        header,
        voltage,
        current,
        charge,
        capacity,
        percentage,
        powerSupplyStatus,
        present,
      );
}

/// `sensor_msgs/msg/NavSatFix`.
@immutable
final class NavSatFix implements RosMessage {
  const NavSatFix({
    this.header = const Header(),
    this.latitude = 0,
    this.longitude = 0,
    this.altitude = 0,
    this.status = 0,
    this.service = 0,
  });

  factory NavSatFix.fromJson(Map<String, Object?> json) => NavSatFix(
        header: Field.asMessage(json['header'], Header.fromJson),
        latitude: Field.asDouble(json['latitude']),
        longitude: Field.asDouble(json['longitude']),
        altitude: Field.asDouble(json['altitude']),
        status: Field.asInt(
            (json['status'] as Map<String, Object?>?)?['status'] ?? -1),
        service: Field.asInt(
            (json['status'] as Map<String, Object?>?)?['service'] ?? 0),
      );

  final Header header;
  final double latitude, longitude, altitude;

  /// -1 no fix, 0 unaugmented fix, 1 SBAS, 2 GBAS.
  final int status;

  /// Bitmask of the constellations used for the fix: 1 GPS, 2 GLONASS,
  /// 4 COMPASS/BeiDou, 8 Galileo. Dropping it on a round trip would silently
  /// discard which constellations a receiver actually saw.
  final int service;

  bool get hasFix => status >= 0;

  @override
  String get rosType => 'sensor_msgs/msg/NavSatFix';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'status': {'status': status, 'service': service},
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NavSatFix &&
          other.header == header &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.altitude == altitude &&
          other.status == status &&
          other.service == service);

  @override
  int get hashCode => Object.hash(
        header,
        latitude,
        longitude,
        altitude,
        status,
        service,
      );
}

/// Registers every `sensor_msgs` codec.
/// `sensor_msgs/msg/PointField` — one channel in a [PointCloud2]'s blob.
@immutable
final class PointField implements RosMessage {
  const PointField({
    this.name = '',
    this.offset = 0,
    this.datatype = 0,
    this.count = 1,
  });

  factory PointField.fromJson(Map<String, Object?> json) => PointField(
        name: Field.asString(json['name']),
        offset: Field.asInt(json['offset']),
        datatype: Field.asInt(json['datatype']),
        count: Field.asInt(json['count']),
      );

  static const int int8 = 1;
  static const int uint8 = 2;
  static const int int16 = 3;
  static const int uint16 = 4;
  static const int int32 = 5;
  static const int uint32 = 6;
  static const int float32 = 7;
  static const int float64 = 8;

  /// Conventionally `x`, `y`, `z`, `intensity`, `rgb`, `rgba`.
  final String name;

  /// Byte offset of this field within one point.
  final int offset;

  /// One of the datatype constants above.
  final int datatype;

  /// Elements in this field; almost always 1.
  final int count;

  /// Width of one element in bytes, or 0 if [datatype] is unknown.
  int get elementSize => switch (datatype) {
        int8 || uint8 => 1,
        int16 || uint16 => 2,
        int32 || uint32 || float32 => 4,
        float64 => 8,
        _ => 0,
      };

  bool get isFloat => datatype == float32 || datatype == float64;

  @override
  String get rosType => 'sensor_msgs/msg/PointField';

  @override
  Map<String, Object?> toJson() => {
        'name': name,
        'offset': offset,
        'datatype': datatype,
        'count': count,
      };

  @override
  String toString() => 'PointField($name @$offset type=$datatype)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PointField &&
          other.name == name &&
          other.offset == offset &&
          other.datatype == datatype &&
          other.count == count);

  @override
  int get hashCode => Object.hash(name, offset, datatype, count);
}

/// `sensor_msgs/msg/PointCloud2`.
///
/// The points live in [data] as a packed binary blob whose layout [fields]
/// describes; nothing here decodes them. Use [reader] to read values out of
/// that buffer without materialising a Dart object per point — a 100k-point
/// cloud would otherwise cost 100k allocations per frame, every frame.
@immutable
final class PointCloud2 implements RosMessage {
  PointCloud2({
    this.header = const Header(),
    this.height = 1,
    this.width = 0,
    this.fields = const [],
    this.isBigendian = false,
    this.pointStep = 0,
    this.rowStep = 0,
    Uint8List? data,
    this.isDense = true,
  }) : data = data ?? _noBytes;

  factory PointCloud2.fromJson(Map<String, Object?> json) => PointCloud2(
        header: Field.asMessage(json['header'], Header.fromJson),
        height: Field.asInt(json['height']),
        width: Field.asInt(json['width']),
        fields: Field.asList(json['fields'], PointField.fromJson),
        isBigendian: Field.asBool(json['is_bigendian']),
        pointStep: Field.asInt(json['point_step']),
        rowStep: Field.asInt(json['row_step']),
        data: Field.asBytes(json['data']),
        isDense: Field.asBool(json['is_dense']),
      );

  static final Uint8List _noBytes = Uint8List(0);

  final Header header;

  /// 1 for an unordered cloud; the image height for an organised one.
  final int height;
  final int width;
  final List<PointField> fields;
  final bool isBigendian;

  /// Bytes per point, and therefore the stride through [data].
  final int pointStep;
  final int rowStep;

  /// The packed points. Arrives as a view over the CBOR frame, uncopied.
  final Uint8List data;
  final bool isDense;

  /// Points described by the header, which may exceed what [data] holds if the
  /// message was truncated.
  int get pointCount => height * width;

  /// The named field, or `null` if this cloud does not carry it.
  PointField? fieldNamed(String name) {
    for (final field in fields) {
      if (field.name == name) return field;
    }
    return null;
  }

  /// A reader over [data]. Cheap to construct; holds no copy of the points.
  PointCloudReader reader() => PointCloudReader(this);

  @override
  String get rosType => 'sensor_msgs/msg/PointCloud2';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'height': height,
        'width': width,
        'fields': [for (final f in fields) f.toJson()],
        'is_bigendian': isBigendian,
        'point_step': pointStep,
        'row_step': rowStep,
        'data': Field.encodeBytes(data),
        'is_dense': isDense,
      };

  @override
  String toString() => 'PointCloud2(${width}x$height, '
      '${fields.map((f) => f.name).join(",")}, ${data.lengthInBytes} bytes)';
}

void registerSensorMsgs() {
  MessageRegistry.register(const MessageCodec<RosImage>(
      rosType: 'sensor_msgs/msg/Image',
      fromJson: RosImage.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<CompressedImage>(
      rosType: 'sensor_msgs/msg/CompressedImage',
      fromJson: CompressedImage.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<LaserScan>(
      rosType: 'sensor_msgs/msg/LaserScan',
      fromJson: LaserScan.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<Imu>(
      rosType: 'sensor_msgs/msg/Imu', fromJson: Imu.fromJson, toJson: _toJson));
  MessageRegistry.register(const MessageCodec<JointState>(
      rosType: 'sensor_msgs/msg/JointState',
      fromJson: JointState.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<BatteryState>(
      rosType: 'sensor_msgs/msg/BatteryState',
      fromJson: BatteryState.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<NavSatFix>(
      rosType: 'sensor_msgs/msg/NavSatFix',
      fromJson: NavSatFix.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<PointField>(
      rosType: 'sensor_msgs/msg/PointField',
      fromJson: PointField.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<PointCloud2>(
      rosType: 'sensor_msgs/msg/PointCloud2',
      fromJson: PointCloud2.fromJson,
      toJson: _toJson));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();

/// Element-wise comparison, so two structurally identical messages holding
/// separate typed-data buffers still compare equal.
bool _listEquals(List<Object?> a, List<Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
