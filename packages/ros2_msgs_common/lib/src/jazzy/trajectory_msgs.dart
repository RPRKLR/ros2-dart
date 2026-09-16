// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package trajectory_msgs

import 'dart:typed_data';

import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;

/// The header is used to specify the coordinate frame and the reference time for
/// the trajectory durations
///
/// `trajectory_msgs/msg/JointTrajectory`
final class JointTrajectory implements RosMessage {
  JointTrajectory({
    ros2.Header? header,
    this.jointNames = const [],
    this.points = const [],
  }) : header = header ?? ros2.Header();

  factory JointTrajectory.fromJson(Map<String, Object?> json) =>
      JointTrajectory(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        jointNames: Field.asStringList(json['joint_names']),
        points: Field.asList<JointTrajectoryPoint>(
            json['points'], JointTrajectoryPoint.fromJson),
      );

  final ros2.Header header;
  final List<String> jointNames;
  final List<JointTrajectoryPoint> points;

  @override
  String get rosType => 'trajectory_msgs/msg/JointTrajectory';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'joint_names': jointNames,
        'points': points.map((JointTrajectoryPoint e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JointTrajectory &&
          other.header == header &&
          _listEquals(other.jointNames, jointNames) &&
          _listEquals(other.points, points));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...jointNames,
        ...points,
      ]);

  @override
  String toString() => 'JointTrajectory(${toJson()})';
}

/// Each trajectory point specifies either positions[, velocities[, accelerations]]
/// or positions[, effort] for the trajectory to be executed.
/// All specified values are in the same order as the joint names in JointTrajectory.msg.
///
/// `trajectory_msgs/msg/JointTrajectoryPoint`
final class JointTrajectoryPoint implements RosMessage {
  JointTrajectoryPoint({
    Float64List? positions,
    Float64List? velocities,
    Float64List? accelerations,
    Float64List? effort,
    ros2.RosDuration? timeFromStart,
  })  : positions = positions ?? Float64List(0),
        velocities = velocities ?? Float64List(0),
        accelerations = accelerations ?? Float64List(0),
        effort = effort ?? Float64List(0),
        timeFromStart = timeFromStart ?? ros2.RosDuration();

  factory JointTrajectoryPoint.fromJson(Map<String, Object?> json) =>
      JointTrajectoryPoint(
        positions: Field.asFloat64List(json['positions']),
        velocities: Field.asFloat64List(json['velocities']),
        accelerations: Field.asFloat64List(json['accelerations']),
        effort: Field.asFloat64List(json['effort']),
        timeFromStart:
            Field.asMessage(json['time_from_start'], ros2.RosDuration.fromJson),
      );

  final Float64List positions;
  final Float64List velocities;
  final Float64List accelerations;
  final Float64List effort;
  final ros2.RosDuration timeFromStart;

  @override
  String get rosType => 'trajectory_msgs/msg/JointTrajectoryPoint';

  @override
  Map<String, Object?> toJson() => {
        'positions': Field.encodeNumbers(positions),
        'velocities': Field.encodeNumbers(velocities),
        'accelerations': Field.encodeNumbers(accelerations),
        'effort': Field.encodeNumbers(effort),
        'time_from_start': timeFromStart.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JointTrajectoryPoint &&
          _listEquals(other.positions, positions) &&
          _listEquals(other.velocities, velocities) &&
          _listEquals(other.accelerations, accelerations) &&
          _listEquals(other.effort, effort) &&
          other.timeFromStart == timeFromStart);

  @override
  int get hashCode => Object.hashAll([
        ...positions,
        ...velocities,
        ...accelerations,
        ...effort,
        timeFromStart,
      ]);

  @override
  String toString() => 'JointTrajectoryPoint(${toJson()})';
}

/// The header is used to specify the coordinate frame and the reference time for the trajectory durations
///
/// `trajectory_msgs/msg/MultiDOFJointTrajectory`
final class MultiDOFJointTrajectory implements RosMessage {
  MultiDOFJointTrajectory({
    ros2.Header? header,
    this.jointNames = const [],
    this.points = const [],
  }) : header = header ?? ros2.Header();

  factory MultiDOFJointTrajectory.fromJson(Map<String, Object?> json) =>
      MultiDOFJointTrajectory(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        jointNames: Field.asStringList(json['joint_names']),
        points: Field.asList<MultiDOFJointTrajectoryPoint>(
            json['points'], MultiDOFJointTrajectoryPoint.fromJson),
      );

  final ros2.Header header;
  final List<String> jointNames;
  final List<MultiDOFJointTrajectoryPoint> points;

  @override
  String get rosType => 'trajectory_msgs/msg/MultiDOFJointTrajectory';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'joint_names': jointNames,
        'points':
            points.map((MultiDOFJointTrajectoryPoint e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MultiDOFJointTrajectory &&
          other.header == header &&
          _listEquals(other.jointNames, jointNames) &&
          _listEquals(other.points, points));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...jointNames,
        ...points,
      ]);

  @override
  String toString() => 'MultiDOFJointTrajectory(${toJson()})';
}

/// Each multi-dof joint can specify a transform (up to 6 DOF).
///
/// `trajectory_msgs/msg/MultiDOFJointTrajectoryPoint`
final class MultiDOFJointTrajectoryPoint implements RosMessage {
  MultiDOFJointTrajectoryPoint({
    this.transforms = const [],
    this.velocities = const [],
    this.accelerations = const [],
    ros2.RosDuration? timeFromStart,
  }) : timeFromStart = timeFromStart ?? ros2.RosDuration();

  factory MultiDOFJointTrajectoryPoint.fromJson(Map<String, Object?> json) =>
      MultiDOFJointTrajectoryPoint(
        transforms: Field.asList<ros2.RosTransform>(
            json['transforms'], ros2.RosTransform.fromJson),
        velocities:
            Field.asList<ros2.Twist>(json['velocities'], ros2.Twist.fromJson),
        accelerations: Field.asList<ros2.Twist>(
            json['accelerations'], ros2.Twist.fromJson),
        timeFromStart:
            Field.asMessage(json['time_from_start'], ros2.RosDuration.fromJson),
      );

  final List<ros2.RosTransform> transforms;
  final List<ros2.Twist> velocities;
  final List<ros2.Twist> accelerations;
  final ros2.RosDuration timeFromStart;

  @override
  String get rosType => 'trajectory_msgs/msg/MultiDOFJointTrajectoryPoint';

  @override
  Map<String, Object?> toJson() => {
        'transforms':
            transforms.map((ros2.RosTransform e) => e.toJson()).toList(),
        'velocities': velocities.map((ros2.Twist e) => e.toJson()).toList(),
        'accelerations':
            accelerations.map((ros2.Twist e) => e.toJson()).toList(),
        'time_from_start': timeFromStart.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MultiDOFJointTrajectoryPoint &&
          _listEquals(other.transforms, transforms) &&
          _listEquals(other.velocities, velocities) &&
          _listEquals(other.accelerations, accelerations) &&
          other.timeFromStart == timeFromStart);

  @override
  int get hashCode => Object.hashAll([
        ...transforms,
        ...velocities,
        ...accelerations,
        timeFromStart,
      ]);

  @override
  String toString() => 'MultiDOFJointTrajectoryPoint(${toJson()})';
}

/// Element-wise list comparison used by generated `==`.
bool _listEquals(List<Object?> a, List<Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Registers every message in `trajectory_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerTrajectoryMsgs() {
  MessageRegistry.register(const MessageCodec<JointTrajectory>(
    rosType: 'trajectory_msgs/msg/JointTrajectory',
    fromJson: JointTrajectory.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<JointTrajectoryPoint>(
    rosType: 'trajectory_msgs/msg/JointTrajectoryPoint',
    fromJson: JointTrajectoryPoint.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MultiDOFJointTrajectory>(
    rosType: 'trajectory_msgs/msg/MultiDOFJointTrajectory',
    fromJson: MultiDOFJointTrajectory.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MultiDOFJointTrajectoryPoint>(
    rosType: 'trajectory_msgs/msg/MultiDOFJointTrajectoryPoint',
    fromJson: MultiDOFJointTrajectoryPoint.fromJson,
    toJson: _toJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
