import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'conversions.dart';
import 'geometry_msgs.dart';
import 'message.dart';
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
  });

  factory NavSatFix.fromJson(Map<String, Object?> json) => NavSatFix(
        header: Field.asMessage(json['header'], Header.fromJson),
        latitude: Field.asDouble(json['latitude']),
        longitude: Field.asDouble(json['longitude']),
        altitude: Field.asDouble(json['altitude']),
        status: Field.asInt(
            (json['status'] as Map<String, Object?>?)?['status'] ?? -1),
      );

  final Header header;
  final double latitude, longitude, altitude;

  /// -1 no fix, 0 unaugmented fix, 1 SBAS, 2 GBAS.
  final int status;

  bool get hasFix => status >= 0;

  @override
  String get rosType => 'sensor_msgs/msg/NavSatFix';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'status': {'status': status, 'service': 0},
      };
}

/// Registers every `sensor_msgs` codec.
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
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
