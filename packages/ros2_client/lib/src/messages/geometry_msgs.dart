import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'conversions.dart';
import 'message.dart';
import 'std_msgs.dart';

/// `geometry_msgs/msg/Vector3`.
@immutable
final class Vector3 implements RosMessage {
  const Vector3({this.x = 0, this.y = 0, this.z = 0});
  factory Vector3.fromJson(Map<String, Object?> json) => Vector3(
        x: Field.asDouble(json['x']),
        y: Field.asDouble(json['y']),
        z: Field.asDouble(json['z']),
      );
  static const Vector3 zero = Vector3();
  final double x, y, z;

  double get length => math.sqrt(x * x + y * y + z * z);

  @override
  String get rosType => 'geometry_msgs/msg/Vector3';
  @override
  Map<String, Object?> toJson() => {'x': x, 'y': y, 'z': z};
  @override
  bool operator ==(Object other) =>
      other is Vector3 && other.x == x && other.y == y && other.z == z;
  @override
  int get hashCode => Object.hash(x, y, z);
  @override
  String toString() => 'Vector3($x, $y, $z)';
}

/// `geometry_msgs/msg/Point`.
@immutable
final class Point implements RosMessage {
  const Point({this.x = 0, this.y = 0, this.z = 0});
  factory Point.fromJson(Map<String, Object?> json) => Point(
        x: Field.asDouble(json['x']),
        y: Field.asDouble(json['y']),
        z: Field.asDouble(json['z']),
      );
  final double x, y, z;

  double distanceTo(Point other) {
    final dx = x - other.x, dy = y - other.y, dz = z - other.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  @override
  String get rosType => 'geometry_msgs/msg/Point';
  @override
  Map<String, Object?> toJson() => {'x': x, 'y': y, 'z': z};
  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y && other.z == z;
  @override
  int get hashCode => Object.hash(x, y, z);
  @override
  String toString() => 'Point($x, $y, $z)';
}

/// `geometry_msgs/msg/Quaternion`.
@immutable
final class Quaternion implements RosMessage {
  const Quaternion({this.x = 0, this.y = 0, this.z = 0, this.w = 1});
  factory Quaternion.fromJson(Map<String, Object?> json) => Quaternion(
        x: Field.asDouble(json['x']),
        y: Field.asDouble(json['y']),
        z: Field.asDouble(json['z']),
        w: Field.asDouble(json['w']),
      );

  /// A rotation of [radians] about +Z — the only rotation most ground robots
  /// ever need.
  factory Quaternion.fromYaw(double radians) => Quaternion(
        z: math.sin(radians / 2),
        w: math.cos(radians / 2),
      );

  /// A rotation from roll, pitch and yaw in radians.
  ///
  /// XYZ fixed-axis, per REP-103: roll about X, then pitch about Y, then yaw
  /// about Z, each about the *fixed* frame rather than the rotated one. This
  /// is the inverse of the `rpy` getter in `TransformMath`.
  factory Quaternion.fromRpy(double roll, double pitch, double yaw) {
    final cr = math.cos(roll / 2);
    final sr = math.sin(roll / 2);
    final cp = math.cos(pitch / 2);
    final sp = math.sin(pitch / 2);
    final cy = math.cos(yaw / 2);
    final sy = math.sin(yaw / 2);
    return Quaternion(
      w: cr * cp * cy + sr * sp * sy,
      x: sr * cp * cy - cr * sp * sy,
      y: cr * sp * cy + sr * cp * sy,
      z: cr * cp * sy - sr * sp * cy,
    );
  }

  static const Quaternion identity = Quaternion();
  final double x, y, z, w;

  /// Rotation about +Z in radians, in `(-pi, pi]`.
  double get yaw => math.atan2(2 * (w * z + x * y), 1 - 2 * (y * y + z * z));

  @override
  String get rosType => 'geometry_msgs/msg/Quaternion';
  @override
  Map<String, Object?> toJson() => {'x': x, 'y': y, 'z': z, 'w': w};
  @override
  bool operator ==(Object other) =>
      other is Quaternion &&
      other.x == x &&
      other.y == y &&
      other.z == z &&
      other.w == w;
  @override
  int get hashCode => Object.hash(x, y, z, w);
  @override
  String toString() => 'Quaternion($x, $y, $z, $w)';
}

/// `geometry_msgs/msg/Pose`.
@immutable
final class Pose implements RosMessage {
  const Pose({
    this.position = const Point(),
    this.orientation = Quaternion.identity,
  });
  factory Pose.fromJson(Map<String, Object?> json) => Pose(
        position: Field.asMessage(json['position'], Point.fromJson),
        orientation: Field.asMessage(json['orientation'], Quaternion.fromJson),
      );
  final Point position;
  final Quaternion orientation;
  @override
  String get rosType => 'geometry_msgs/msg/Pose';
  @override
  Map<String, Object?> toJson() =>
      {'position': position.toJson(), 'orientation': orientation.toJson()};
  @override
  bool operator ==(Object other) =>
      other is Pose &&
      other.position == position &&
      other.orientation == orientation;
  @override
  int get hashCode => Object.hash(position, orientation);
  @override
  String toString() => 'Pose($position, yaw=${orientation.yaw})';
}

/// `geometry_msgs/msg/PoseStamped`.
@immutable
final class PoseStamped implements RosMessage {
  const PoseStamped({this.header = const Header(), this.pose = const Pose()});
  factory PoseStamped.fromJson(Map<String, Object?> json) => PoseStamped(
        header: Field.asMessage(json['header'], Header.fromJson),
        pose: Field.asMessage(json['pose'], Pose.fromJson),
      );
  final Header header;
  final Pose pose;
  @override
  String get rosType => 'geometry_msgs/msg/PoseStamped';
  @override
  Map<String, Object?> toJson() =>
      {'header': header.toJson(), 'pose': pose.toJson()};
  @override
  bool operator ==(Object other) =>
      other is PoseStamped && other.header == header && other.pose == pose;
  @override
  int get hashCode => Object.hash(header, pose);
}

/// `geometry_msgs/msg/Twist` — the canonical velocity command.
@immutable
final class Twist implements RosMessage {
  const Twist({this.linear = Vector3.zero, this.angular = Vector3.zero});
  factory Twist.fromJson(Map<String, Object?> json) => Twist(
        linear: Field.asMessage(json['linear'], Vector3.fromJson),
        angular: Field.asMessage(json['angular'], Vector3.fromJson),
      );

  /// A differential-drive command: [forward] m/s and [turn] rad/s.
  factory Twist.drive({double forward = 0, double turn = 0}) => Twist(
        linear: Vector3(x: forward),
        angular: Vector3(z: turn),
      );

  /// An all-zero twist. Publish this to stop a robot.
  static const Twist stop = Twist();

  final Vector3 linear;
  final Vector3 angular;

  @override
  String get rosType => 'geometry_msgs/msg/Twist';
  @override
  Map<String, Object?> toJson() =>
      {'linear': linear.toJson(), 'angular': angular.toJson()};
  @override
  bool operator ==(Object other) =>
      other is Twist && other.linear == linear && other.angular == angular;
  @override
  int get hashCode => Object.hash(linear, angular);
  @override
  String toString() => 'Twist(linear: $linear, angular: $angular)';
}

/// `geometry_msgs/msg/Transform`.
@immutable
final class RosTransform implements RosMessage {
  const RosTransform({
    this.translation = Vector3.zero,
    this.rotation = Quaternion.identity,
  });
  factory RosTransform.fromJson(Map<String, Object?> json) => RosTransform(
        translation: Field.asMessage(json['translation'], Vector3.fromJson),
        rotation: Field.asMessage(json['rotation'], Quaternion.fromJson),
      );
  final Vector3 translation;
  final Quaternion rotation;
  @override
  String get rosType => 'geometry_msgs/msg/Transform';
  @override
  Map<String, Object?> toJson() =>
      {'translation': translation.toJson(), 'rotation': rotation.toJson()};
  @override
  bool operator ==(Object other) =>
      other is RosTransform &&
      other.translation == translation &&
      other.rotation == rotation;
  @override
  int get hashCode => Object.hash(translation, rotation);
}

/// `geometry_msgs/msg/TransformStamped`.
@immutable
final class RosTransformStamped implements RosMessage {
  const RosTransformStamped({
    this.header = const Header(),
    this.childFrameId = '',
    this.transform = const RosTransform(),
  });
  factory RosTransformStamped.fromJson(Map<String, Object?> json) =>
      RosTransformStamped(
        header: Field.asMessage(json['header'], Header.fromJson),
        childFrameId: Field.asString(json['child_frame_id']),
        transform: Field.asMessage(json['transform'], RosTransform.fromJson),
      );
  final Header header;
  final String childFrameId;
  final RosTransform transform;
  @override
  String get rosType => 'geometry_msgs/msg/TransformStamped';
  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'child_frame_id': childFrameId,
        'transform': transform.toJson(),
      };
  @override
  bool operator ==(Object other) =>
      other is RosTransformStamped &&
      other.header == header &&
      other.childFrameId == childFrameId &&
      other.transform == transform;
  @override
  int get hashCode => Object.hash(header, childFrameId, transform);
}

/// `tf2_msgs/msg/TFMessage` — the payload of `/tf` and `/tf_static`.
@immutable
final class TFMessage implements RosMessage {
  const TFMessage({this.transforms = const []});

  factory TFMessage.fromJson(Map<String, Object?> json) => TFMessage(
        transforms:
            Field.asList(json['transforms'], RosTransformStamped.fromJson),
      );

  final List<RosTransformStamped> transforms;

  @override
  String get rosType => 'tf2_msgs/msg/TFMessage';

  @override
  Map<String, Object?> toJson() =>
      {'transforms': transforms.map((t) => t.toJson()).toList()};

  @override
  String toString() => 'TFMessage(${transforms.length} transforms)';
}

/// Registers every `geometry_msgs` codec.
void registerGeometryMsgs() {
  MessageRegistry.register(const MessageCodec<Vector3>(
      rosType: 'geometry_msgs/msg/Vector3',
      fromJson: Vector3.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<Point>(
      rosType: 'geometry_msgs/msg/Point',
      fromJson: Point.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<Quaternion>(
      rosType: 'geometry_msgs/msg/Quaternion',
      fromJson: Quaternion.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<Pose>(
      rosType: 'geometry_msgs/msg/Pose',
      fromJson: Pose.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<PoseStamped>(
      rosType: 'geometry_msgs/msg/PoseStamped',
      fromJson: PoseStamped.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<Twist>(
      rosType: 'geometry_msgs/msg/Twist',
      fromJson: Twist.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<RosTransform>(
      rosType: 'geometry_msgs/msg/Transform',
      fromJson: RosTransform.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<RosTransformStamped>(
      rosType: 'geometry_msgs/msg/TransformStamped',
      fromJson: RosTransformStamped.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<TFMessage>(
      rosType: 'tf2_msgs/msg/TFMessage',
      fromJson: TFMessage.fromJson,
      toJson: _toJson));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
