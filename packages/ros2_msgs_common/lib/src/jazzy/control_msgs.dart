// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package control_msgs

import 'dart:typed_data';

import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;
import 'geometry_msgs.dart';
import 'std_msgs.dart';
import 'trajectory_msgs.dart';

/// Admittance parameters
///
/// `control_msgs/msg/AdmittanceControllerState`
final class AdmittanceControllerState implements RosMessage {
  AdmittanceControllerState({
    Float64MultiArray? mass,
    Float64MultiArray? damping,
    Float64MultiArray? stiffness,
    ros2.Quaternion? rotBaseControl,
    ros2.RosTransformStamped? refTransBaseFt,
    Int8MultiArray? selectedAxes,
    ros2.StringMsg? ftSensorFrame,
    ros2.RosTransformStamped? admittancePosition,
    TwistStamped? admittanceAcceleration,
    TwistStamped? admittanceVelocity,
    WrenchStamped? wrenchBase,
    ros2.JointState? jointState,
  })  : mass = mass ?? Float64MultiArray(),
        damping = damping ?? Float64MultiArray(),
        stiffness = stiffness ?? Float64MultiArray(),
        rotBaseControl = rotBaseControl ?? ros2.Quaternion(),
        refTransBaseFt = refTransBaseFt ?? ros2.RosTransformStamped(),
        selectedAxes = selectedAxes ?? Int8MultiArray(),
        ftSensorFrame = ftSensorFrame ?? ros2.StringMsg(),
        admittancePosition = admittancePosition ?? ros2.RosTransformStamped(),
        admittanceAcceleration = admittanceAcceleration ?? TwistStamped(),
        admittanceVelocity = admittanceVelocity ?? TwistStamped(),
        wrenchBase = wrenchBase ?? WrenchStamped(),
        jointState = jointState ?? ros2.JointState.fromJson(const {});

  factory AdmittanceControllerState.fromJson(Map<String, Object?> json) =>
      AdmittanceControllerState(
        mass: Field.asMessage(json['mass'], Float64MultiArray.fromJson),
        damping: Field.asMessage(json['damping'], Float64MultiArray.fromJson),
        stiffness:
            Field.asMessage(json['stiffness'], Float64MultiArray.fromJson),
        rotBaseControl:
            Field.asMessage(json['rot_base_control'], ros2.Quaternion.fromJson),
        refTransBaseFt: Field.asMessage(
            json['ref_trans_base_ft'], ros2.RosTransformStamped.fromJson),
        selectedAxes:
            Field.asMessage(json['selected_axes'], Int8MultiArray.fromJson),
        ftSensorFrame:
            Field.asMessage(json['ft_sensor_frame'], ros2.StringMsg.fromJson),
        admittancePosition: Field.asMessage(
            json['admittance_position'], ros2.RosTransformStamped.fromJson),
        admittanceAcceleration: Field.asMessage(
            json['admittance_acceleration'], TwistStamped.fromJson),
        admittanceVelocity:
            Field.asMessage(json['admittance_velocity'], TwistStamped.fromJson),
        wrenchBase:
            Field.asMessage(json['wrench_base'], WrenchStamped.fromJson),
        jointState:
            Field.asMessage(json['joint_state'], ros2.JointState.fromJson),
      );

  /// 6-vector of mass terms used in the admittance calculation
  final Float64MultiArray mass;

  /// 6-vector of damping terms used in the admittance calculation
  final Float64MultiArray damping;

  /// 6-vector of stiffness terms used in the admittance calculation
  final Float64MultiArray stiffness;

  /// quaternion describing the orientation of the control frame
  final ros2.Quaternion rotBaseControl;

  /// force torque sensor transform at the reference joint configuration
  final ros2.RosTransformStamped refTransBaseFt;

  /// 6-vector of 0/1 describing if admittance is enable in the corresponding control frame axis
  final Int8MultiArray selectedAxes;

  /// name of the force torque frame
  final ros2.StringMsg ftSensorFrame;

  /// calculated admittance position in cartesian space
  final ros2.RosTransformStamped admittancePosition;

  /// calculated admittance acceleration in cartesian space
  final TwistStamped admittanceAcceleration;

  /// calculated admittance velocity in cartesian space
  final TwistStamped admittanceVelocity;

  /// wrench used in the admittance calculation
  final WrenchStamped wrenchBase;

  /// calculated admittance offsets in joint space
  final ros2.JointState jointState;

  @override
  String get rosType => 'control_msgs/msg/AdmittanceControllerState';

  @override
  Map<String, Object?> toJson() => {
        'mass': mass.toJson(),
        'damping': damping.toJson(),
        'stiffness': stiffness.toJson(),
        'rot_base_control': rotBaseControl.toJson(),
        'ref_trans_base_ft': refTransBaseFt.toJson(),
        'selected_axes': selectedAxes.toJson(),
        'ft_sensor_frame': ftSensorFrame.toJson(),
        'admittance_position': admittancePosition.toJson(),
        'admittance_acceleration': admittanceAcceleration.toJson(),
        'admittance_velocity': admittanceVelocity.toJson(),
        'wrench_base': wrenchBase.toJson(),
        'joint_state': jointState.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdmittanceControllerState &&
          other.mass == mass &&
          other.damping == damping &&
          other.stiffness == stiffness &&
          other.rotBaseControl == rotBaseControl &&
          other.refTransBaseFt == refTransBaseFt &&
          other.selectedAxes == selectedAxes &&
          other.ftSensorFrame == ftSensorFrame &&
          other.admittancePosition == admittancePosition &&
          other.admittanceAcceleration == admittanceAcceleration &&
          other.admittanceVelocity == admittanceVelocity &&
          other.wrenchBase == wrenchBase &&
          other.jointState == jointState);

  @override
  int get hashCode => Object.hashAll([
        mass,
        damping,
        stiffness,
        rotBaseControl,
        refTransBaseFt,
        selectedAxes,
        ftSensorFrame,
        admittancePosition,
        admittanceAcceleration,
        admittanceVelocity,
        wrenchBase,
        jointState,
      ]);

  @override
  String toString() => 'AdmittanceControllerState(${toJson()})';
}

/// This message publishes values for multiple batteries at once.
///
/// `control_msgs/msg/BatteryStateArray`
final class BatteryStateArray implements RosMessage {
  const BatteryStateArray({
    this.batteryStates = const [],
  });

  factory BatteryStateArray.fromJson(Map<String, Object?> json) =>
      BatteryStateArray(
        batteryStates: Field.asList<ros2.BatteryState>(
            json['battery_states'], ros2.BatteryState.fromJson),
      );

  final List<ros2.BatteryState> batteryStates;

  @override
  String get rosType => 'control_msgs/msg/BatteryStateArray';

  @override
  Map<String, Object?> toJson() => {
        'battery_states':
            batteryStates.map((ros2.BatteryState e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatteryStateArray &&
          _listEquals(other.batteryStates, batteryStates));

  @override
  int get hashCode => Object.hashAll([
        ...batteryStates,
      ]);

  @override
  String toString() => 'BatteryStateArray(${toJson()})';
}

/// `control_msgs/msg/DynamicInterfaceGroupValues`
final class DynamicInterfaceGroupValues implements RosMessage {
  DynamicInterfaceGroupValues({
    ros2.Header? header,
    this.interfaceGroups = const [],
    this.interfaceValues = const [],
  }) : header = header ?? ros2.Header();

  factory DynamicInterfaceGroupValues.fromJson(Map<String, Object?> json) =>
      DynamicInterfaceGroupValues(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        interfaceGroups: Field.asStringList(json['interface_groups']),
        interfaceValues: Field.asList<InterfaceValue>(
            json['interface_values'], InterfaceValue.fromJson),
      );

  final ros2.Header header;
  final List<String> interfaceGroups;
  final List<InterfaceValue> interfaceValues;

  @override
  String get rosType => 'control_msgs/msg/DynamicInterfaceGroupValues';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'interface_groups': interfaceGroups,
        'interface_values':
            interfaceValues.map((InterfaceValue e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DynamicInterfaceGroupValues &&
          other.header == header &&
          _listEquals(other.interfaceGroups, interfaceGroups) &&
          _listEquals(other.interfaceValues, interfaceValues));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...interfaceGroups,
        ...interfaceValues,
      ]);

  @override
  String toString() => 'DynamicInterfaceGroupValues(${toJson()})';
}

/// `control_msgs/msg/DynamicInterfaceValues`
final class DynamicInterfaceValues implements RosMessage {
  DynamicInterfaceValues({
    ros2.Header? header,
    InterfaceValue? states,
    InterfaceValue? commands,
  })  : header = header ?? ros2.Header(),
        states = states ?? InterfaceValue(),
        commands = commands ?? InterfaceValue();

  factory DynamicInterfaceValues.fromJson(Map<String, Object?> json) =>
      DynamicInterfaceValues(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        states: Field.asMessage(json['states'], InterfaceValue.fromJson),
        commands: Field.asMessage(json['commands'], InterfaceValue.fromJson),
      );

  final ros2.Header header;
  final InterfaceValue states;
  final InterfaceValue commands;

  @override
  String get rosType => 'control_msgs/msg/DynamicInterfaceValues';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'states': states.toJson(),
        'commands': commands.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DynamicInterfaceValues &&
          other.header == header &&
          other.states == states &&
          other.commands == commands);

  @override
  int get hashCode => Object.hashAll([
        header,
        states,
        commands,
      ]);

  @override
  String toString() => 'DynamicInterfaceValues(${toJson()})';
}

/// `control_msgs/msg/DynamicJointState`
final class DynamicJointState implements RosMessage {
  DynamicJointState({
    ros2.Header? header,
    this.jointNames = const [],
    this.interfaceValues = const [],
  }) : header = header ?? ros2.Header();

  factory DynamicJointState.fromJson(Map<String, Object?> json) =>
      DynamicJointState(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        jointNames: Field.asStringList(json['joint_names']),
        interfaceValues: Field.asList<InterfaceValue>(
            json['interface_values'], InterfaceValue.fromJson),
      );

  final ros2.Header header;
  final List<String> jointNames;
  final List<InterfaceValue> interfaceValues;

  @override
  String get rosType => 'control_msgs/msg/DynamicJointState';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'joint_names': jointNames,
        'interface_values':
            interfaceValues.map((InterfaceValue e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DynamicJointState &&
          other.header == header &&
          _listEquals(other.jointNames, jointNames) &&
          _listEquals(other.interfaceValues, interfaceValues));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...jointNames,
        ...interfaceValues,
      ]);

  @override
  String toString() => 'DynamicJointState(${toJson()})';
}

/// `control_msgs/msg/Float64Values`
final class Float64Values implements RosMessage {
  Float64Values({
    ros2.Header? header,
    Float64List? values,
  })  : header = header ?? ros2.Header(),
        values = values ?? Float64List(0);

  factory Float64Values.fromJson(Map<String, Object?> json) => Float64Values(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        values:
            json['values'] == null ? null : Field.asFloat64List(json['values']),
      );

  final ros2.Header header;
  final Float64List values;

  @override
  String get rosType => 'control_msgs/msg/Float64Values';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'values': Field.encodeNumbers(values),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Float64Values &&
          other.header == header &&
          _listEquals(other.values, values));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...values,
      ]);

  @override
  String toString() => 'Float64Values(${toJson()})';
}

/// `control_msgs/msg/GripperCommand`
final class GripperCommand implements RosMessage {
  const GripperCommand({
    this.position = 0,
    this.maxEffort = 0,
  });

  factory GripperCommand.fromJson(Map<String, Object?> json) => GripperCommand(
        position: Field.doubleAt(json, 'position'),
        maxEffort: Field.doubleAt(json, 'max_effort'),
      );

  final double position;
  final double maxEffort;

  @override
  String get rosType => 'control_msgs/msg/GripperCommand';

  @override
  Map<String, Object?> toJson() => {
        'position': position,
        'max_effort': maxEffort,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GripperCommand &&
          other.position == position &&
          other.maxEffort == maxEffort);

  @override
  int get hashCode => Object.hashAll([
        position,
        maxEffort,
      ]);

  @override
  String toString() => 'GripperCommand(${toJson()})';
}

/// List of resource interface names
///
/// `control_msgs/msg/InterfaceValue`
final class InterfaceValue implements RosMessage {
  InterfaceValue({
    this.interfaceNames = const [],
    Float64List? values,
  }) : values = values ?? Float64List(0);

  factory InterfaceValue.fromJson(Map<String, Object?> json) => InterfaceValue(
        interfaceNames: Field.asStringList(json['interface_names']),
        values:
            json['values'] == null ? null : Field.asFloat64List(json['values']),
      );

  final List<String> interfaceNames;
  final Float64List values;

  @override
  String get rosType => 'control_msgs/msg/InterfaceValue';

  @override
  Map<String, Object?> toJson() => {
        'interface_names': interfaceNames,
        'values': Field.encodeNumbers(values),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterfaceValue &&
          _listEquals(other.interfaceNames, interfaceNames) &&
          _listEquals(other.values, values));

  @override
  int get hashCode => Object.hashAll([
        ...interfaceNames,
        ...values,
      ]);

  @override
  String toString() => 'InterfaceValue(${toJson()})';
}

/// Version of JointTolerance.msg with added component field for joints with multiple degrees of freedom
/// The difference between two MultiDOFJointTrajectoryPoint cannot be represented as a single number,
/// hence we use the component field to represent how to calculate the difference in a way that can
/// be represented as a single number.
///
/// `control_msgs/msg/JointComponentTolerance`
final class JointComponentTolerance implements RosMessage {
  const JointComponentTolerance({
    this.jointName = '',
    this.component = 0,
    this.position = 0,
    this.velocity = 0,
    this.acceleration = 0,
  });

  factory JointComponentTolerance.fromJson(Map<String, Object?> json) =>
      JointComponentTolerance(
        jointName: Field.stringAt(json, 'joint_name'),
        component: Field.intAt(json, 'component'),
        position: Field.doubleAt(json, 'position'),
        velocity: Field.doubleAt(json, 'velocity'),
        acceleration: Field.doubleAt(json, 'acceleration'),
      );

  static const int xAxis = 1;
  static const int yAxis = 2;
  static const int zAxis = 3;
  static const int translation = 4;
  static const int rotation = 5;

  final String jointName;
  final int component;
  final double position;
  final double velocity;
  final double acceleration;

  @override
  String get rosType => 'control_msgs/msg/JointComponentTolerance';

  @override
  Map<String, Object?> toJson() => {
        'joint_name': jointName,
        'component': component,
        'position': position,
        'velocity': velocity,
        'acceleration': acceleration,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JointComponentTolerance &&
          other.jointName == jointName &&
          other.component == component &&
          other.position == position &&
          other.velocity == velocity &&
          other.acceleration == acceleration);

  @override
  int get hashCode => Object.hashAll([
        jointName,
        component,
        position,
        velocity,
        acceleration,
      ]);

  @override
  String toString() => 'JointComponentTolerance(${toJson()})';
}

/// This message presents current controller state of one joint.
///
/// `control_msgs/msg/JointControllerState`
final class JointControllerState implements RosMessage {
  JointControllerState({
    ros2.Header? header,
    this.setPoint = 0,
    this.processValue = 0,
    this.processValueDot = 0,
    this.error = 0,
    this.timeStep = 0,
    this.command = 0,
    this.p = 0,
    this.i = 0,
    this.d = 0,
    this.iClamp = 0,
    this.antiwindup = false,
  }) : header = header ?? ros2.Header();

  factory JointControllerState.fromJson(Map<String, Object?> json) =>
      JointControllerState(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        setPoint: Field.doubleAt(json, 'set_point'),
        processValue: Field.doubleAt(json, 'process_value'),
        processValueDot: Field.doubleAt(json, 'process_value_dot'),
        error: Field.doubleAt(json, 'error'),
        timeStep: Field.doubleAt(json, 'time_step'),
        command: Field.doubleAt(json, 'command'),
        p: Field.doubleAt(json, 'p'),
        i: Field.doubleAt(json, 'i'),
        d: Field.doubleAt(json, 'd'),
        iClamp: Field.doubleAt(json, 'i_clamp'),
        antiwindup: Field.boolAt(json, 'antiwindup'),
      );

  final ros2.Header header;
  final double setPoint;
  final double processValue;
  final double processValueDot;
  final double error;
  final double timeStep;
  final double command;
  final double p;
  final double i;
  final double d;
  final double iClamp;
  final bool antiwindup;

  @override
  String get rosType => 'control_msgs/msg/JointControllerState';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'set_point': setPoint,
        'process_value': processValue,
        'process_value_dot': processValueDot,
        'error': error,
        'time_step': timeStep,
        'command': command,
        'p': p,
        'i': i,
        'd': d,
        'i_clamp': iClamp,
        'antiwindup': antiwindup,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JointControllerState &&
          other.header == header &&
          other.setPoint == setPoint &&
          other.processValue == processValue &&
          other.processValueDot == processValueDot &&
          other.error == error &&
          other.timeStep == timeStep &&
          other.command == command &&
          other.p == p &&
          other.i == i &&
          other.d == d &&
          other.iClamp == iClamp &&
          other.antiwindup == antiwindup);

  @override
  int get hashCode => Object.hashAll([
        header,
        setPoint,
        processValue,
        processValueDot,
        error,
        timeStep,
        command,
        p,
        i,
        d,
        iClamp,
        antiwindup,
      ]);

  @override
  String toString() => 'JointControllerState(${toJson()})';
}

/// Used in time-stamping the message.
///
/// `control_msgs/msg/JointJog`
final class JointJog implements RosMessage {
  JointJog({
    ros2.Header? header,
    this.jointNames = const [],
    Float64List? displacements,
    Float64List? velocities,
    this.duration = 0,
  })  : header = header ?? ros2.Header(),
        displacements = displacements ?? Float64List(0),
        velocities = velocities ?? Float64List(0);

  factory JointJog.fromJson(Map<String, Object?> json) => JointJog(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        jointNames: Field.asStringList(json['joint_names']),
        displacements: json['displacements'] == null
            ? null
            : Field.asFloat64List(json['displacements']),
        velocities: json['velocities'] == null
            ? null
            : Field.asFloat64List(json['velocities']),
        duration: Field.doubleAt(json, 'duration'),
      );

  final ros2.Header header;
  final List<String> jointNames;

  /// or position_deltas
  final Float64List displacements;
  final Float64List velocities;
  final double duration;

  @override
  String get rosType => 'control_msgs/msg/JointJog';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'joint_names': jointNames,
        'displacements': Field.encodeNumbers(displacements),
        'velocities': Field.encodeNumbers(velocities),
        'duration': duration,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JointJog &&
          other.header == header &&
          _listEquals(other.jointNames, jointNames) &&
          _listEquals(other.displacements, displacements) &&
          _listEquals(other.velocities, velocities) &&
          other.duration == duration);

  @override
  int get hashCode => Object.hashAll([
        header,
        ...jointNames,
        ...displacements,
        ...velocities,
        duration,
      ]);

  @override
  String toString() => 'JointJog(${toJson()})';
}

/// The tolerances specify the amount the position, velocity, and
/// accelerations can vary from the setpoints.  For example, in the case
/// of trajectory control, when the actual position varies beyond
/// (desired position + position tolerance), the trajectory goal may
/// abort.
///
/// There are two special values for tolerances:
/// * 0 - The tolerance is unspecified and will remain at whatever the default is
/// * -1 - The tolerance is "erased".  If there was a default, the joint will be
/// allowed to move without restriction.
///
/// `control_msgs/msg/JointTolerance`
final class JointTolerance implements RosMessage {
  const JointTolerance({
    this.name = '',
    this.position = 0,
    this.velocity = 0,
    this.acceleration = 0,
  });

  factory JointTolerance.fromJson(Map<String, Object?> json) => JointTolerance(
        name: Field.stringAt(json, 'name'),
        position: Field.doubleAt(json, 'position'),
        velocity: Field.doubleAt(json, 'velocity'),
        acceleration: Field.doubleAt(json, 'acceleration'),
      );

  final String name;

  /// in radians or meters (for a revolute or prismatic joint, respectively)
  final double position;

  /// in rad/sec or m/sec
  final double velocity;

  /// in rad/sec^2 or m/sec^2
  final double acceleration;

  @override
  String get rosType => 'control_msgs/msg/JointTolerance';

  @override
  Map<String, Object?> toJson() => {
        'name': name,
        'position': position,
        'velocity': velocity,
        'acceleration': acceleration,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JointTolerance &&
          other.name == name &&
          other.position == position &&
          other.velocity == velocity &&
          other.acceleration == acceleration);

  @override
  int get hashCode => Object.hashAll([
        name,
        position,
        velocity,
        acceleration,
      ]);

  @override
  String toString() => 'JointTolerance(${toJson()})';
}

/// This message presents current controller state of JTC
///
/// `control_msgs/msg/JointTrajectoryControllerState`
final class JointTrajectoryControllerState implements RosMessage {
  JointTrajectoryControllerState({
    ros2.Header? header,
    this.jointNames = const [],
    JointTrajectoryPoint? reference,
    JointTrajectoryPoint? feedback,
    JointTrajectoryPoint? error,
    JointTrajectoryPoint? output,
    this.multiDofJointNames = const [],
    MultiDOFJointTrajectoryPoint? multiDofReference,
    MultiDOFJointTrajectoryPoint? multiDofFeedback,
    MultiDOFJointTrajectoryPoint? multiDofError,
    MultiDOFJointTrajectoryPoint? multiDofOutput,
    this.speedScalingFactor = 0,
  })  : header = header ?? ros2.Header(),
        reference = reference ?? JointTrajectoryPoint(),
        feedback = feedback ?? JointTrajectoryPoint(),
        error = error ?? JointTrajectoryPoint(),
        output = output ?? JointTrajectoryPoint(),
        multiDofReference = multiDofReference ?? MultiDOFJointTrajectoryPoint(),
        multiDofFeedback = multiDofFeedback ?? MultiDOFJointTrajectoryPoint(),
        multiDofError = multiDofError ?? MultiDOFJointTrajectoryPoint(),
        multiDofOutput = multiDofOutput ?? MultiDOFJointTrajectoryPoint();

  factory JointTrajectoryControllerState.fromJson(Map<String, Object?> json) =>
      JointTrajectoryControllerState(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        jointNames: Field.asStringList(json['joint_names']),
        reference:
            Field.asMessage(json['reference'], JointTrajectoryPoint.fromJson),
        feedback:
            Field.asMessage(json['feedback'], JointTrajectoryPoint.fromJson),
        error: Field.asMessage(json['error'], JointTrajectoryPoint.fromJson),
        output: Field.asMessage(json['output'], JointTrajectoryPoint.fromJson),
        multiDofJointNames: Field.asStringList(json['multi_dof_joint_names']),
        multiDofReference: Field.asMessage(
            json['multi_dof_reference'], MultiDOFJointTrajectoryPoint.fromJson),
        multiDofFeedback: Field.asMessage(
            json['multi_dof_feedback'], MultiDOFJointTrajectoryPoint.fromJson),
        multiDofError: Field.asMessage(
            json['multi_dof_error'], MultiDOFJointTrajectoryPoint.fromJson),
        multiDofOutput: Field.asMessage(
            json['multi_dof_output'], MultiDOFJointTrajectoryPoint.fromJson),
        speedScalingFactor: Field.doubleAt(json, 'speed_scaling_factor'),
      );

  final ros2.Header header;
  final List<String> jointNames;
  final JointTrajectoryPoint reference;
  final JointTrajectoryPoint feedback;
  final JointTrajectoryPoint error;
  final JointTrajectoryPoint output;
  final List<String> multiDofJointNames;
  final MultiDOFJointTrajectoryPoint multiDofReference;
  final MultiDOFJointTrajectoryPoint multiDofFeedback;
  final MultiDOFJointTrajectoryPoint multiDofError;
  final MultiDOFJointTrajectoryPoint multiDofOutput;
  final double speedScalingFactor;

  @override
  String get rosType => 'control_msgs/msg/JointTrajectoryControllerState';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'joint_names': jointNames,
        'reference': reference.toJson(),
        'feedback': feedback.toJson(),
        'error': error.toJson(),
        'output': output.toJson(),
        'multi_dof_joint_names': multiDofJointNames,
        'multi_dof_reference': multiDofReference.toJson(),
        'multi_dof_feedback': multiDofFeedback.toJson(),
        'multi_dof_error': multiDofError.toJson(),
        'multi_dof_output': multiDofOutput.toJson(),
        'speed_scaling_factor': speedScalingFactor,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JointTrajectoryControllerState &&
          other.header == header &&
          _listEquals(other.jointNames, jointNames) &&
          other.reference == reference &&
          other.feedback == feedback &&
          other.error == error &&
          other.output == output &&
          _listEquals(other.multiDofJointNames, multiDofJointNames) &&
          other.multiDofReference == multiDofReference &&
          other.multiDofFeedback == multiDofFeedback &&
          other.multiDofError == multiDofError &&
          other.multiDofOutput == multiDofOutput &&
          other.speedScalingFactor == speedScalingFactor);

  @override
  int get hashCode => Object.hashAll([
        header,
        ...jointNames,
        reference,
        feedback,
        error,
        output,
        ...multiDofJointNames,
        multiDofReference,
        multiDofFeedback,
        multiDofError,
        multiDofOutput,
        speedScalingFactor,
      ]);

  @override
  String toString() => 'JointTrajectoryControllerState(${toJson()})';
}

/// `control_msgs/msg/Keys`
final class Keys implements RosMessage {
  Keys({
    ros2.Header? header,
    this.keys = const [],
  }) : header = header ?? ros2.Header();

  factory Keys.fromJson(Map<String, Object?> json) => Keys(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        keys: Field.asStringList(json['keys']),
      );

  final ros2.Header header;
  final List<String> keys;

  @override
  String get rosType => 'control_msgs/msg/Keys';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'keys': keys,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Keys &&
          other.header == header &&
          _listEquals(other.keys, keys));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...keys,
      ]);

  @override
  String toString() => 'Keys(${toJson()})';
}

/// `control_msgs/msg/MecanumDriveControllerState`
final class MecanumDriveControllerState implements RosMessage {
  MecanumDriveControllerState({
    ros2.Header? header,
    this.frontLeftWheelVelocity = 0,
    this.backLeftWheelVelocity = 0,
    this.backRightWheelVelocity = 0,
    this.frontRightWheelVelocity = 0,
    ros2.Twist? referenceVelocity,
  })  : header = header ?? ros2.Header(),
        referenceVelocity = referenceVelocity ?? ros2.Twist();

  factory MecanumDriveControllerState.fromJson(Map<String, Object?> json) =>
      MecanumDriveControllerState(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        frontLeftWheelVelocity:
            Field.doubleAt(json, 'front_left_wheel_velocity'),
        backLeftWheelVelocity: Field.doubleAt(json, 'back_left_wheel_velocity'),
        backRightWheelVelocity:
            Field.doubleAt(json, 'back_right_wheel_velocity'),
        frontRightWheelVelocity:
            Field.doubleAt(json, 'front_right_wheel_velocity'),
        referenceVelocity:
            Field.asMessage(json['reference_velocity'], ros2.Twist.fromJson),
      );

  final ros2.Header header;
  final double frontLeftWheelVelocity;
  final double backLeftWheelVelocity;
  final double backRightWheelVelocity;
  final double frontRightWheelVelocity;
  final ros2.Twist referenceVelocity;

  @override
  String get rosType => 'control_msgs/msg/MecanumDriveControllerState';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'front_left_wheel_velocity': frontLeftWheelVelocity,
        'back_left_wheel_velocity': backLeftWheelVelocity,
        'back_right_wheel_velocity': backRightWheelVelocity,
        'front_right_wheel_velocity': frontRightWheelVelocity,
        'reference_velocity': referenceVelocity.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MecanumDriveControllerState &&
          other.header == header &&
          other.frontLeftWheelVelocity == frontLeftWheelVelocity &&
          other.backLeftWheelVelocity == backLeftWheelVelocity &&
          other.backRightWheelVelocity == backRightWheelVelocity &&
          other.frontRightWheelVelocity == frontRightWheelVelocity &&
          other.referenceVelocity == referenceVelocity);

  @override
  int get hashCode => Object.hashAll([
        header,
        frontLeftWheelVelocity,
        backLeftWheelVelocity,
        backRightWheelVelocity,
        frontRightWheelVelocity,
        referenceVelocity,
      ]);

  @override
  String toString() => 'MecanumDriveControllerState(${toJson()})';
}

/// Key Value pair to be used in MotionPrimitive messages
///
/// `control_msgs/msg/MotionArgument`
final class MotionArgument implements RosMessage {
  const MotionArgument({
    this.name = '',
    this.value = 0,
  });

  factory MotionArgument.fromJson(Map<String, Object?> json) => MotionArgument(
        name: Field.stringAt(json, 'name'),
        value: Field.doubleAt(json, 'value'),
      );

  final String name;
  final double value;

  @override
  String get rosType => 'control_msgs/msg/MotionArgument';

  @override
  Map<String, Object?> toJson() => {
        'name': name,
        'value': value,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MotionArgument && other.name == name && other.value == value);

  @override
  int get hashCode => Object.hashAll([
        name,
        value,
      ]);

  @override
  String toString() => 'MotionArgument(${toJson()})';
}

/// `control_msgs/msg/MotionPrimitive`
final class MotionPrimitive implements RosMessage {
  MotionPrimitive({
    this.type = -1,
    this.blendRadius = 0,
    this.additionalArguments = const [],
    this.poses = const [],
    Float64List? jointPositions,
  }) : jointPositions = jointPositions ?? Float64List(0);

  factory MotionPrimitive.fromJson(Map<String, Object?> json) =>
      MotionPrimitive(
        type: Field.intAt(json, 'type', -1),
        blendRadius: Field.doubleAt(json, 'blend_radius'),
        additionalArguments: Field.asList<MotionArgument>(
            json['additional_arguments'], MotionArgument.fromJson),
        poses: Field.asList<ros2.PoseStamped>(
            json['poses'], ros2.PoseStamped.fromJson),
        jointPositions: json['joint_positions'] == null
            ? null
            : Field.asFloat64List(json['joint_positions']),
      );

  static const int unknown = -1;

  /// Often referred as PTP
  static const int linearJoint = 0;

  /// Often referred as LIN
  static const int linearCartesian = 50;

  /// Often referred as CIRC
  static const int circularCartesian = 51;

  /// one of the above
  final int type;
  final double blendRadius;

  /// (max) velocity, (max) acceleration, efficiency
  final List<MotionArgument> additionalArguments;
  final List<ros2.PoseStamped> poses;
  final Float64List jointPositions;

  @override
  String get rosType => 'control_msgs/msg/MotionPrimitive';

  @override
  Map<String, Object?> toJson() => {
        'type': type,
        'blend_radius': blendRadius,
        'additional_arguments':
            additionalArguments.map((MotionArgument e) => e.toJson()).toList(),
        'poses': poses.map((ros2.PoseStamped e) => e.toJson()).toList(),
        'joint_positions': Field.encodeNumbers(jointPositions),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MotionPrimitive &&
          other.type == type &&
          other.blendRadius == blendRadius &&
          _listEquals(other.additionalArguments, additionalArguments) &&
          _listEquals(other.poses, poses) &&
          _listEquals(other.jointPositions, jointPositions));

  @override
  int get hashCode => Object.hashAll([
        type,
        blendRadius,
        ...additionalArguments,
        ...poses,
        ...jointPositions,
      ]);

  @override
  String toString() => 'MotionPrimitive(${toJson()})';
}

/// `control_msgs/msg/MotionPrimitiveSequence`
final class MotionPrimitiveSequence implements RosMessage {
  const MotionPrimitiveSequence({
    this.motions = const [],
  });

  factory MotionPrimitiveSequence.fromJson(Map<String, Object?> json) =>
      MotionPrimitiveSequence(
        motions: Field.asList<MotionPrimitive>(
            json['motions'], MotionPrimitive.fromJson),
      );

  final List<MotionPrimitive> motions;

  @override
  String get rosType => 'control_msgs/msg/MotionPrimitiveSequence';

  @override
  Map<String, Object?> toJson() => {
        'motions': motions.map((MotionPrimitive e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MotionPrimitiveSequence && _listEquals(other.motions, motions));

  @override
  int get hashCode => Object.hashAll([
        ...motions,
      ]);

  @override
  String toString() => 'MotionPrimitiveSequence(${toJson()})';
}

/// The message defines command for multiple degrees of freedom (DoF) typically used by many controllers.
/// The message intentionally avoids 'joint' nomenclature because it can be generally use for command with
/// different semantic meanings, e.g., joints, Cartesian axes, or have abstract meaning like GPIO interface.
///
/// `control_msgs/msg/MultiDOFCommand`
final class MultiDOFCommand implements RosMessage {
  MultiDOFCommand({
    this.dofNames = const [],
    Float64List? values,
    Float64List? valuesDot,
  })  : values = values ?? Float64List(0),
        valuesDot = valuesDot ?? Float64List(0);

  factory MultiDOFCommand.fromJson(Map<String, Object?> json) =>
      MultiDOFCommand(
        dofNames: Field.asStringList(json['dof_names']),
        values:
            json['values'] == null ? null : Field.asFloat64List(json['values']),
        valuesDot: json['values_dot'] == null
            ? null
            : Field.asFloat64List(json['values_dot']),
      );

  final List<String> dofNames;
  final Float64List values;
  final Float64List valuesDot;

  @override
  String get rosType => 'control_msgs/msg/MultiDOFCommand';

  @override
  Map<String, Object?> toJson() => {
        'dof_names': dofNames,
        'values': Field.encodeNumbers(values),
        'values_dot': Field.encodeNumbers(valuesDot),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MultiDOFCommand &&
          _listEquals(other.dofNames, dofNames) &&
          _listEquals(other.values, values) &&
          _listEquals(other.valuesDot, valuesDot));

  @override
  int get hashCode => Object.hashAll([
        ...dofNames,
        ...values,
        ...valuesDot,
      ]);

  @override
  String toString() => 'MultiDOFCommand(${toJson()})';
}

/// This message presents current controller state of multiple degrees of freedom.
///
/// `control_msgs/msg/MultiDOFStateStamped`
final class MultiDOFStateStamped implements RosMessage {
  MultiDOFStateStamped({
    ros2.Header? header,
    this.dofStates = const [],
  }) : header = header ?? ros2.Header();

  factory MultiDOFStateStamped.fromJson(Map<String, Object?> json) =>
      MultiDOFStateStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        dofStates: Field.asList<SingleDOFState>(
            json['dof_states'], SingleDOFState.fromJson),
      );

  final ros2.Header header;
  final List<SingleDOFState> dofStates;

  @override
  String get rosType => 'control_msgs/msg/MultiDOFStateStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'dof_states': dofStates.map((SingleDOFState e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MultiDOFStateStamped &&
          other.header == header &&
          _listEquals(other.dofStates, dofStates));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...dofStates,
      ]);

  @override
  String toString() => 'MultiDOFStateStamped(${toJson()})';
}

/// `control_msgs/msg/PidState`
final class PidState implements RosMessage {
  PidState({
    ros2.Header? header,
    ros2.RosDuration? timestep,
    this.error = 0,
    this.errorDot = 0,
    this.pError = 0,
    this.iError = 0,
    this.dError = 0,
    this.pTerm = 0,
    this.iTerm = 0,
    this.dTerm = 0,
    this.iMax = 0,
    this.iMin = 0,
    this.output = 0,
  })  : header = header ?? ros2.Header(),
        timestep = timestep ?? ros2.RosDuration();

  factory PidState.fromJson(Map<String, Object?> json) => PidState(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        timestep: Field.asMessage(json['timestep'], ros2.RosDuration.fromJson),
        error: Field.doubleAt(json, 'error'),
        errorDot: Field.doubleAt(json, 'error_dot'),
        pError: Field.doubleAt(json, 'p_error'),
        iError: Field.doubleAt(json, 'i_error'),
        dError: Field.doubleAt(json, 'd_error'),
        pTerm: Field.doubleAt(json, 'p_term'),
        iTerm: Field.doubleAt(json, 'i_term'),
        dTerm: Field.doubleAt(json, 'd_term'),
        iMax: Field.doubleAt(json, 'i_max'),
        iMin: Field.doubleAt(json, 'i_min'),
        output: Field.doubleAt(json, 'output'),
      );

  final ros2.Header header;
  final ros2.RosDuration timestep;
  final double error;
  final double errorDot;
  final double pError;
  final double iError;
  final double dError;
  final double pTerm;
  final double iTerm;
  final double dTerm;
  final double iMax;
  final double iMin;
  final double output;

  @override
  String get rosType => 'control_msgs/msg/PidState';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'timestep': timestep.toJson(),
        'error': error,
        'error_dot': errorDot,
        'p_error': pError,
        'i_error': iError,
        'd_error': dError,
        'p_term': pTerm,
        'i_term': iTerm,
        'd_term': dTerm,
        'i_max': iMax,
        'i_min': iMin,
        'output': output,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PidState &&
          other.header == header &&
          other.timestep == timestep &&
          other.error == error &&
          other.errorDot == errorDot &&
          other.pError == pError &&
          other.iError == iError &&
          other.dError == dError &&
          other.pTerm == pTerm &&
          other.iTerm == iTerm &&
          other.dTerm == dTerm &&
          other.iMax == iMax &&
          other.iMin == iMin &&
          other.output == output);

  @override
  int get hashCode => Object.hashAll([
        header,
        timestep,
        error,
        errorDot,
        pError,
        iError,
        dError,
        pTerm,
        iTerm,
        dTerm,
        iMax,
        iMin,
        output,
      ]);

  @override
  String toString() => 'PidState(${toJson()})';
}

/// This message presents current controller state of one degree of freedom.
///
/// `control_msgs/msg/SingleDOFState`
final class SingleDOFState implements RosMessage {
  const SingleDOFState({
    this.name = '',
    this.reference = 0,
    this.feedback = 0,
    this.feedbackDot = 0,
    this.error = 0,
    this.errorDot = 0,
    this.timeStep = 0,
    this.output = 0,
  });

  factory SingleDOFState.fromJson(Map<String, Object?> json) => SingleDOFState(
        name: Field.stringAt(json, 'name'),
        reference: Field.doubleAt(json, 'reference'),
        feedback: Field.doubleAt(json, 'feedback'),
        feedbackDot: Field.doubleAt(json, 'feedback_dot'),
        error: Field.doubleAt(json, 'error'),
        errorDot: Field.doubleAt(json, 'error_dot'),
        timeStep: Field.doubleAt(json, 'time_step'),
        output: Field.doubleAt(json, 'output'),
      );

  final String name;
  final double reference;
  final double feedback;
  final double feedbackDot;
  final double error;
  final double errorDot;
  final double timeStep;
  final double output;

  @override
  String get rosType => 'control_msgs/msg/SingleDOFState';

  @override
  Map<String, Object?> toJson() => {
        'name': name,
        'reference': reference,
        'feedback': feedback,
        'feedback_dot': feedbackDot,
        'error': error,
        'error_dot': errorDot,
        'time_step': timeStep,
        'output': output,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SingleDOFState &&
          other.name == name &&
          other.reference == reference &&
          other.feedback == feedback &&
          other.feedbackDot == feedbackDot &&
          other.error == error &&
          other.errorDot == errorDot &&
          other.timeStep == timeStep &&
          other.output == output);

  @override
  int get hashCode => Object.hashAll([
        name,
        reference,
        feedback,
        feedbackDot,
        error,
        errorDot,
        timeStep,
        output,
      ]);

  @override
  String toString() => 'SingleDOFState(${toJson()})';
}

/// This message presents current controller state of one degree of freedom.
///
/// `control_msgs/msg/SingleDOFStateStamped`
final class SingleDOFStateStamped implements RosMessage {
  SingleDOFStateStamped({
    ros2.Header? header,
    SingleDOFState? dofState,
  })  : header = header ?? ros2.Header(),
        dofState = dofState ?? SingleDOFState();

  factory SingleDOFStateStamped.fromJson(Map<String, Object?> json) =>
      SingleDOFStateStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        dofState: Field.asMessage(json['dof_state'], SingleDOFState.fromJson),
      );

  final ros2.Header header;
  final SingleDOFState dofState;

  @override
  String get rosType => 'control_msgs/msg/SingleDOFStateStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'dof_state': dofState.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SingleDOFStateStamped &&
          other.header == header &&
          other.dofState == dofState);

  @override
  int get hashCode => Object.hashAll([
        header,
        dofState,
      ]);

  @override
  String toString() => 'SingleDOFStateStamped(${toJson()})';
}

/// This message contains a scaling factor to scale trajectory execution. A factor of 1.0 means
/// execution at normal speed, a factor of 0.0 means a full pause.
/// Negative values are not allowed (Which should be checked by any instance consuming this message).
///
/// `control_msgs/msg/SpeedScalingFactor`
final class SpeedScalingFactor implements RosMessage {
  const SpeedScalingFactor({
    this.factor = 0,
  });

  factory SpeedScalingFactor.fromJson(Map<String, Object?> json) =>
      SpeedScalingFactor(
        factor: Field.doubleAt(json, 'factor'),
      );

  final double factor;

  @override
  String get rosType => 'control_msgs/msg/SpeedScalingFactor';

  @override
  Map<String, Object?> toJson() => {
        'factor': factor,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeedScalingFactor && other.factor == factor);

  @override
  int get hashCode => Object.hashAll([
        factor,
      ]);

  @override
  String toString() => 'SpeedScalingFactor(${toJson()})';
}

/// `control_msgs/msg/SteeringControllerStatus`
final class SteeringControllerStatus implements RosMessage {
  SteeringControllerStatus({
    ros2.Header? header,
    Float64List? tractionWheelsPosition,
    Float64List? tractionWheelsVelocity,
    Float64List? steerPositions,
    Float64List? linearVelocityCommand,
    Float64List? steeringAngleCommand,
  })  : header = header ?? ros2.Header(),
        tractionWheelsPosition = tractionWheelsPosition ?? Float64List(0),
        tractionWheelsVelocity = tractionWheelsVelocity ?? Float64List(0),
        steerPositions = steerPositions ?? Float64List(0),
        linearVelocityCommand = linearVelocityCommand ?? Float64List(0),
        steeringAngleCommand = steeringAngleCommand ?? Float64List(0);

  factory SteeringControllerStatus.fromJson(Map<String, Object?> json) =>
      SteeringControllerStatus(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        tractionWheelsPosition: json['traction_wheels_position'] == null
            ? null
            : Field.asFloat64List(json['traction_wheels_position']),
        tractionWheelsVelocity: json['traction_wheels_velocity'] == null
            ? null
            : Field.asFloat64List(json['traction_wheels_velocity']),
        steerPositions: json['steer_positions'] == null
            ? null
            : Field.asFloat64List(json['steer_positions']),
        linearVelocityCommand: json['linear_velocity_command'] == null
            ? null
            : Field.asFloat64List(json['linear_velocity_command']),
        steeringAngleCommand: json['steering_angle_command'] == null
            ? null
            : Field.asFloat64List(json['steering_angle_command']),
      );

  final ros2.Header header;

  /// positions of traction wheels if the robot is controlled by position
  final Float64List tractionWheelsPosition;

  /// velocities of traction wheels if the robot is controlled by velocity
  final Float64List tractionWheelsVelocity;

  /// positions of steering joints
  final Float64List steerPositions;

  /// value commanded to tractions joint
  final Float64List linearVelocityCommand;

  /// values commanded to steering joints
  final Float64List steeringAngleCommand;

  @override
  String get rosType => 'control_msgs/msg/SteeringControllerStatus';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'traction_wheels_position': Field.encodeNumbers(tractionWheelsPosition),
        'traction_wheels_velocity': Field.encodeNumbers(tractionWheelsVelocity),
        'steer_positions': Field.encodeNumbers(steerPositions),
        'linear_velocity_command': Field.encodeNumbers(linearVelocityCommand),
        'steering_angle_command': Field.encodeNumbers(steeringAngleCommand),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SteeringControllerStatus &&
          other.header == header &&
          _listEquals(other.tractionWheelsPosition, tractionWheelsPosition) &&
          _listEquals(other.tractionWheelsVelocity, tractionWheelsVelocity) &&
          _listEquals(other.steerPositions, steerPositions) &&
          _listEquals(other.linearVelocityCommand, linearVelocityCommand) &&
          _listEquals(other.steeringAngleCommand, steeringAngleCommand));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...tractionWheelsPosition,
        ...tractionWheelsVelocity,
        ...steerPositions,
        ...linearVelocityCommand,
        ...steeringAngleCommand,
      ]);

  @override
  String toString() => 'SteeringControllerStatus(${toJson()})';
}

/// `control_msgs/msg/VDA5050SafetyState`
final class VDA5050SafetyState implements RosMessage {
  const VDA5050SafetyState({
    this.eStop = '',
    this.fieldViolation = false,
  });

  factory VDA5050SafetyState.fromJson(Map<String, Object?> json) =>
      VDA5050SafetyState(
        eStop: Field.stringAt(json, 'e_stop'),
        fieldViolation: Field.boolAt(json, 'field_violation'),
      );

  static const String autoAck = 'autoAck';
  static const String manual = 'manual';
  static const String remote = 'remote';
  static const String none = 'none';

  /// Enum {autoAck, manual, remote, none} Acknowledge-Type of eStop:
  final String eStop;

  /// Protective field violation. True: field is violated False: field is not violated
  final bool fieldViolation;

  @override
  String get rosType => 'control_msgs/msg/VDA5050SafetyState';

  @override
  Map<String, Object?> toJson() => {
        'e_stop': eStop,
        'field_violation': fieldViolation,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VDA5050SafetyState &&
          other.eStop == eStop &&
          other.fieldViolation == fieldViolation);

  @override
  int get hashCode => Object.hashAll([
        eStop,
        fieldViolation,
      ]);

  @override
  String toString() => 'VDA5050SafetyState(${toJson()})';
}

/// `control_msgs/msg/QueryCalibrationState_Request`
final class QueryCalibrationStateRequest implements RosMessage {
  const QueryCalibrationStateRequest();

  factory QueryCalibrationStateRequest.fromJson(Map<String, Object?> json) =>
      QueryCalibrationStateRequest();

  @override
  String get rosType => 'control_msgs/msg/QueryCalibrationState_Request';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is QueryCalibrationStateRequest;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'QueryCalibrationStateRequest(${toJson()})';
}

/// `control_msgs/msg/QueryCalibrationState_Response`
final class QueryCalibrationStateResponse implements RosMessage {
  const QueryCalibrationStateResponse({
    this.isCalibrated = false,
  });

  factory QueryCalibrationStateResponse.fromJson(Map<String, Object?> json) =>
      QueryCalibrationStateResponse(
        isCalibrated: Field.boolAt(json, 'is_calibrated'),
      );

  final bool isCalibrated;

  @override
  String get rosType => 'control_msgs/msg/QueryCalibrationState_Response';

  @override
  Map<String, Object?> toJson() => {
        'is_calibrated': isCalibrated,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueryCalibrationStateResponse &&
          other.isCalibrated == isCalibrated);

  @override
  int get hashCode => Object.hashAll([
        isCalibrated,
      ]);

  @override
  String toString() => 'QueryCalibrationStateResponse(${toJson()})';
}

/// `control_msgs/msg/QueryTrajectoryState_Request`
final class QueryTrajectoryStateRequest implements RosMessage {
  QueryTrajectoryStateRequest({
    ros2.RosTime? time,
  }) : time = time ?? ros2.RosTime();

  factory QueryTrajectoryStateRequest.fromJson(Map<String, Object?> json) =>
      QueryTrajectoryStateRequest(
        time: Field.asMessage(json['time'], ros2.RosTime.fromJson),
      );

  final ros2.RosTime time;

  @override
  String get rosType => 'control_msgs/msg/QueryTrajectoryState_Request';

  @override
  Map<String, Object?> toJson() => {
        'time': time.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueryTrajectoryStateRequest && other.time == time);

  @override
  int get hashCode => Object.hashAll([
        time,
      ]);

  @override
  String toString() => 'QueryTrajectoryStateRequest(${toJson()})';
}

/// `control_msgs/msg/QueryTrajectoryState_Response`
final class QueryTrajectoryStateResponse implements RosMessage {
  QueryTrajectoryStateResponse({
    this.success = false,
    this.message = '',
    this.name = const [],
    Float64List? position,
    Float64List? velocity,
    Float64List? acceleration,
  })  : position = position ?? Float64List(0),
        velocity = velocity ?? Float64List(0),
        acceleration = acceleration ?? Float64List(0);

  factory QueryTrajectoryStateResponse.fromJson(Map<String, Object?> json) =>
      QueryTrajectoryStateResponse(
        success: Field.boolAt(json, 'success'),
        message: Field.stringAt(json, 'message'),
        name: Field.asStringList(json['name']),
        position: json['position'] == null
            ? null
            : Field.asFloat64List(json['position']),
        velocity: json['velocity'] == null
            ? null
            : Field.asFloat64List(json['velocity']),
        acceleration: json['acceleration'] == null
            ? null
            : Field.asFloat64List(json['acceleration']),
      );

  /// indicate successful run of triggered service
  final bool success;

  /// informational, e.g. for error messages
  final String message;
  final List<String> name;
  final Float64List position;
  final Float64List velocity;
  final Float64List acceleration;

  @override
  String get rosType => 'control_msgs/msg/QueryTrajectoryState_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
        'message': message,
        'name': name,
        'position': Field.encodeNumbers(position),
        'velocity': Field.encodeNumbers(velocity),
        'acceleration': Field.encodeNumbers(acceleration),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueryTrajectoryStateResponse &&
          other.success == success &&
          other.message == message &&
          _listEquals(other.name, name) &&
          _listEquals(other.position, position) &&
          _listEquals(other.velocity, velocity) &&
          _listEquals(other.acceleration, acceleration));

  @override
  int get hashCode => Object.hashAll([
        success,
        message,
        ...name,
        ...position,
        ...velocity,
        ...acceleration,
      ]);

  @override
  String toString() => 'QueryTrajectoryStateResponse(${toJson()})';
}

/// `control_msgs/msg/SetOdometry_Request`
final class SetOdometryRequest implements RosMessage {
  const SetOdometryRequest({
    this.x = 0,
    this.y = 0,
    this.z = 0,
    this.roll = 0,
    this.pitch = 0,
    this.yaw = 0,
  });

  factory SetOdometryRequest.fromJson(Map<String, Object?> json) =>
      SetOdometryRequest(
        x: Field.doubleAt(json, 'x'),
        y: Field.doubleAt(json, 'y'),
        z: Field.doubleAt(json, 'z'),
        roll: Field.doubleAt(json, 'roll'),
        pitch: Field.doubleAt(json, 'pitch'),
        yaw: Field.doubleAt(json, 'yaw'),
      );

  final double x;
  final double y;
  final double z;
  final double roll;
  final double pitch;
  final double yaw;

  @override
  String get rosType => 'control_msgs/msg/SetOdometry_Request';

  @override
  Map<String, Object?> toJson() => {
        'x': x,
        'y': y,
        'z': z,
        'roll': roll,
        'pitch': pitch,
        'yaw': yaw,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetOdometryRequest &&
          other.x == x &&
          other.y == y &&
          other.z == z &&
          other.roll == roll &&
          other.pitch == pitch &&
          other.yaw == yaw);

  @override
  int get hashCode => Object.hashAll([
        x,
        y,
        z,
        roll,
        pitch,
        yaw,
      ]);

  @override
  String toString() => 'SetOdometryRequest(${toJson()})';
}

/// `control_msgs/msg/SetOdometry_Response`
final class SetOdometryResponse implements RosMessage {
  const SetOdometryResponse({
    this.success = false,
    this.message = '',
  });

  factory SetOdometryResponse.fromJson(Map<String, Object?> json) =>
      SetOdometryResponse(
        success: Field.boolAt(json, 'success'),
        message: Field.stringAt(json, 'message'),
      );

  final bool success;
  final String message;

  @override
  String get rosType => 'control_msgs/msg/SetOdometry_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
        'message': message,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetOdometryResponse &&
          other.success == success &&
          other.message == message);

  @override
  int get hashCode => Object.hashAll([
        success,
        message,
      ]);

  @override
  String toString() => 'SetOdometryResponse(${toJson()})';
}

/// A list of MotionPrimitive messages that are executed in sequence. They don't have to be of the
/// same type, as long as the robot supports executing them one after another.
///
/// `control_msgs/msg/ExecuteMotionPrimitiveSequence_Goal`
final class ExecuteMotionPrimitiveSequenceGoal implements RosMessage {
  ExecuteMotionPrimitiveSequenceGoal({
    MotionPrimitiveSequence? trajectory,
  }) : trajectory = trajectory ?? MotionPrimitiveSequence();

  factory ExecuteMotionPrimitiveSequenceGoal.fromJson(
          Map<String, Object?> json) =>
      ExecuteMotionPrimitiveSequenceGoal(
        trajectory: Field.asMessage(
            json['trajectory'], MotionPrimitiveSequence.fromJson),
      );

  final MotionPrimitiveSequence trajectory;

  @override
  String get rosType => 'control_msgs/msg/ExecuteMotionPrimitiveSequence_Goal';

  @override
  Map<String, Object?> toJson() => {
        'trajectory': trajectory.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExecuteMotionPrimitiveSequenceGoal &&
          other.trajectory == trajectory);

  @override
  int get hashCode => Object.hashAll([
        trajectory,
      ]);

  @override
  String toString() => 'ExecuteMotionPrimitiveSequenceGoal(${toJson()})';
}

/// `control_msgs/msg/ExecuteMotionPrimitiveSequence_Result`
final class ExecuteMotionPrimitiveSequenceResult implements RosMessage {
  const ExecuteMotionPrimitiveSequenceResult({
    this.errorCode = 0,
    this.errorString = '',
  });

  factory ExecuteMotionPrimitiveSequenceResult.fromJson(
          Map<String, Object?> json) =>
      ExecuteMotionPrimitiveSequenceResult(
        errorCode: Field.intAt(json, 'error_code'),
        errorString: Field.stringAt(json, 'error_string'),
      );

  static const int successful = 0;
  static const int invalidGoal = -1;
  static const int oldHeaderTimestamp = -3;

  final int errorCode;
  final String errorString;

  @override
  String get rosType =>
      'control_msgs/msg/ExecuteMotionPrimitiveSequence_Result';

  @override
  Map<String, Object?> toJson() => {
        'error_code': errorCode,
        'error_string': errorString,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExecuteMotionPrimitiveSequenceResult &&
          other.errorCode == errorCode &&
          other.errorString == errorString);

  @override
  int get hashCode => Object.hashAll([
        errorCode,
        errorString,
      ]);

  @override
  String toString() => 'ExecuteMotionPrimitiveSequenceResult(${toJson()})';
}

/// Index of the currently executed motion primitive in the sequence.
///
/// `control_msgs/msg/ExecuteMotionPrimitiveSequence_Feedback`
final class ExecuteMotionPrimitiveSequenceFeedback implements RosMessage {
  const ExecuteMotionPrimitiveSequenceFeedback({
    this.currentPrimitiveIndex = 0,
  });

  factory ExecuteMotionPrimitiveSequenceFeedback.fromJson(
          Map<String, Object?> json) =>
      ExecuteMotionPrimitiveSequenceFeedback(
        currentPrimitiveIndex: Field.intAt(json, 'current_primitive_index'),
      );

  final int currentPrimitiveIndex;

  @override
  String get rosType =>
      'control_msgs/msg/ExecuteMotionPrimitiveSequence_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'current_primitive_index': currentPrimitiveIndex,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExecuteMotionPrimitiveSequenceFeedback &&
          other.currentPrimitiveIndex == currentPrimitiveIndex);

  @override
  int get hashCode => Object.hashAll([
        currentPrimitiveIndex,
      ]);

  @override
  String toString() => 'ExecuteMotionPrimitiveSequenceFeedback(${toJson()})';
}

/// The trajectory for all revolute, continuous or prismatic joints
///
/// `control_msgs/msg/FollowJointTrajectory_Goal`
final class FollowJointTrajectoryGoal implements RosMessage {
  FollowJointTrajectoryGoal({
    JointTrajectory? trajectory,
    MultiDOFJointTrajectory? multiDofTrajectory,
    this.pathTolerance = const [],
    this.componentPathTolerance = const [],
    this.goalTolerance = const [],
    this.componentGoalTolerance = const [],
    ros2.RosDuration? goalTimeTolerance,
  })  : trajectory = trajectory ?? JointTrajectory(),
        multiDofTrajectory = multiDofTrajectory ?? MultiDOFJointTrajectory(),
        goalTimeTolerance = goalTimeTolerance ?? ros2.RosDuration();

  factory FollowJointTrajectoryGoal.fromJson(Map<String, Object?> json) =>
      FollowJointTrajectoryGoal(
        trajectory:
            Field.asMessage(json['trajectory'], JointTrajectory.fromJson),
        multiDofTrajectory: Field.asMessage(
            json['multi_dof_trajectory'], MultiDOFJointTrajectory.fromJson),
        pathTolerance: Field.asList<JointTolerance>(
            json['path_tolerance'], JointTolerance.fromJson),
        componentPathTolerance: Field.asList<JointComponentTolerance>(
            json['component_path_tolerance'], JointComponentTolerance.fromJson),
        goalTolerance: Field.asList<JointTolerance>(
            json['goal_tolerance'], JointTolerance.fromJson),
        componentGoalTolerance: Field.asList<JointComponentTolerance>(
            json['component_goal_tolerance'], JointComponentTolerance.fromJson),
        goalTimeTolerance: Field.asMessage(
            json['goal_time_tolerance'], ros2.RosDuration.fromJson),
      );

  final JointTrajectory trajectory;
  final MultiDOFJointTrajectory multiDofTrajectory;
  final List<JointTolerance> pathTolerance;
  final List<JointComponentTolerance> componentPathTolerance;
  final List<JointTolerance> goalTolerance;
  final List<JointComponentTolerance> componentGoalTolerance;
  final ros2.RosDuration goalTimeTolerance;

  @override
  String get rosType => 'control_msgs/msg/FollowJointTrajectory_Goal';

  @override
  Map<String, Object?> toJson() => {
        'trajectory': trajectory.toJson(),
        'multi_dof_trajectory': multiDofTrajectory.toJson(),
        'path_tolerance':
            pathTolerance.map((JointTolerance e) => e.toJson()).toList(),
        'component_path_tolerance': componentPathTolerance
            .map((JointComponentTolerance e) => e.toJson())
            .toList(),
        'goal_tolerance':
            goalTolerance.map((JointTolerance e) => e.toJson()).toList(),
        'component_goal_tolerance': componentGoalTolerance
            .map((JointComponentTolerance e) => e.toJson())
            .toList(),
        'goal_time_tolerance': goalTimeTolerance.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowJointTrajectoryGoal &&
          other.trajectory == trajectory &&
          other.multiDofTrajectory == multiDofTrajectory &&
          _listEquals(other.pathTolerance, pathTolerance) &&
          _listEquals(other.componentPathTolerance, componentPathTolerance) &&
          _listEquals(other.goalTolerance, goalTolerance) &&
          _listEquals(other.componentGoalTolerance, componentGoalTolerance) &&
          other.goalTimeTolerance == goalTimeTolerance);

  @override
  int get hashCode => Object.hashAll([
        trajectory,
        multiDofTrajectory,
        ...pathTolerance,
        ...componentPathTolerance,
        ...goalTolerance,
        ...componentGoalTolerance,
        goalTimeTolerance,
      ]);

  @override
  String toString() => 'FollowJointTrajectoryGoal(${toJson()})';
}

/// `control_msgs/msg/FollowJointTrajectory_Result`
final class FollowJointTrajectoryResult implements RosMessage {
  const FollowJointTrajectoryResult({
    this.errorCode = 0,
    this.errorString = '',
  });

  factory FollowJointTrajectoryResult.fromJson(Map<String, Object?> json) =>
      FollowJointTrajectoryResult(
        errorCode: Field.intAt(json, 'error_code'),
        errorString: Field.stringAt(json, 'error_string'),
      );

  static const int successful = 0;
  static const int invalidGoal = -1;
  static const int invalidJoints = -2;
  static const int oldHeaderTimestamp = -3;
  static const int pathToleranceViolated = -4;
  static const int goalToleranceViolated = -5;

  final int errorCode;
  final String errorString;

  @override
  String get rosType => 'control_msgs/msg/FollowJointTrajectory_Result';

  @override
  Map<String, Object?> toJson() => {
        'error_code': errorCode,
        'error_string': errorString,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowJointTrajectoryResult &&
          other.errorCode == errorCode &&
          other.errorString == errorString);

  @override
  int get hashCode => Object.hashAll([
        errorCode,
        errorString,
      ]);

  @override
  String toString() => 'FollowJointTrajectoryResult(${toJson()})';
}

/// `control_msgs/msg/FollowJointTrajectory_Feedback`
final class FollowJointTrajectoryFeedback implements RosMessage {
  FollowJointTrajectoryFeedback({
    ros2.Header? header,
    this.jointNames = const [],
    JointTrajectoryPoint? desired,
    JointTrajectoryPoint? actual,
    JointTrajectoryPoint? error,
    this.multiDofJointNames = const [],
    MultiDOFJointTrajectoryPoint? multiDofDesired,
    MultiDOFJointTrajectoryPoint? multiDofActual,
    MultiDOFJointTrajectoryPoint? multiDofError,
  })  : header = header ?? ros2.Header(),
        desired = desired ?? JointTrajectoryPoint(),
        actual = actual ?? JointTrajectoryPoint(),
        error = error ?? JointTrajectoryPoint(),
        multiDofDesired = multiDofDesired ?? MultiDOFJointTrajectoryPoint(),
        multiDofActual = multiDofActual ?? MultiDOFJointTrajectoryPoint(),
        multiDofError = multiDofError ?? MultiDOFJointTrajectoryPoint();

  factory FollowJointTrajectoryFeedback.fromJson(Map<String, Object?> json) =>
      FollowJointTrajectoryFeedback(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        jointNames: Field.asStringList(json['joint_names']),
        desired:
            Field.asMessage(json['desired'], JointTrajectoryPoint.fromJson),
        actual: Field.asMessage(json['actual'], JointTrajectoryPoint.fromJson),
        error: Field.asMessage(json['error'], JointTrajectoryPoint.fromJson),
        multiDofJointNames: Field.asStringList(json['multi_dof_joint_names']),
        multiDofDesired: Field.asMessage(
            json['multi_dof_desired'], MultiDOFJointTrajectoryPoint.fromJson),
        multiDofActual: Field.asMessage(
            json['multi_dof_actual'], MultiDOFJointTrajectoryPoint.fromJson),
        multiDofError: Field.asMessage(
            json['multi_dof_error'], MultiDOFJointTrajectoryPoint.fromJson),
      );

  final ros2.Header header;
  final List<String> jointNames;
  final JointTrajectoryPoint desired;
  final JointTrajectoryPoint actual;
  final JointTrajectoryPoint error;
  final List<String> multiDofJointNames;
  final MultiDOFJointTrajectoryPoint multiDofDesired;
  final MultiDOFJointTrajectoryPoint multiDofActual;
  final MultiDOFJointTrajectoryPoint multiDofError;

  @override
  String get rosType => 'control_msgs/msg/FollowJointTrajectory_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'joint_names': jointNames,
        'desired': desired.toJson(),
        'actual': actual.toJson(),
        'error': error.toJson(),
        'multi_dof_joint_names': multiDofJointNames,
        'multi_dof_desired': multiDofDesired.toJson(),
        'multi_dof_actual': multiDofActual.toJson(),
        'multi_dof_error': multiDofError.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowJointTrajectoryFeedback &&
          other.header == header &&
          _listEquals(other.jointNames, jointNames) &&
          other.desired == desired &&
          other.actual == actual &&
          other.error == error &&
          _listEquals(other.multiDofJointNames, multiDofJointNames) &&
          other.multiDofDesired == multiDofDesired &&
          other.multiDofActual == multiDofActual &&
          other.multiDofError == multiDofError);

  @override
  int get hashCode => Object.hashAll([
        header,
        ...jointNames,
        desired,
        actual,
        error,
        ...multiDofJointNames,
        multiDofDesired,
        multiDofActual,
        multiDofError,
      ]);

  @override
  String toString() => 'FollowJointTrajectoryFeedback(${toJson()})';
}

/// `control_msgs/msg/GripperCommand_Goal`
final class GripperCommandGoal implements RosMessage {
  GripperCommandGoal({
    GripperCommand? command,
  }) : command = command ?? GripperCommand();

  factory GripperCommandGoal.fromJson(Map<String, Object?> json) =>
      GripperCommandGoal(
        command: Field.asMessage(json['command'], GripperCommand.fromJson),
      );

  final GripperCommand command;

  @override
  String get rosType => 'control_msgs/msg/GripperCommand_Goal';

  @override
  Map<String, Object?> toJson() => {
        'command': command.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GripperCommandGoal && other.command == command);

  @override
  int get hashCode => Object.hashAll([
        command,
      ]);

  @override
  String toString() => 'GripperCommandGoal(${toJson()})';
}

/// `control_msgs/msg/GripperCommand_Result`
final class GripperCommandResult implements RosMessage {
  const GripperCommandResult({
    this.position = 0,
    this.effort = 0,
    this.stalled = false,
    this.reachedGoal = false,
  });

  factory GripperCommandResult.fromJson(Map<String, Object?> json) =>
      GripperCommandResult(
        position: Field.doubleAt(json, 'position'),
        effort: Field.doubleAt(json, 'effort'),
        stalled: Field.boolAt(json, 'stalled'),
        reachedGoal: Field.boolAt(json, 'reached_goal'),
      );

  /// The current gripper gap size (in meters)
  final double position;

  /// The current effort exerted (in Newtons)
  final double effort;

  /// True iff the gripper is exerting max effort and not moving
  final bool stalled;

  /// True iff the gripper position has reached the commanded setpoint
  final bool reachedGoal;

  @override
  String get rosType => 'control_msgs/msg/GripperCommand_Result';

  @override
  Map<String, Object?> toJson() => {
        'position': position,
        'effort': effort,
        'stalled': stalled,
        'reached_goal': reachedGoal,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GripperCommandResult &&
          other.position == position &&
          other.effort == effort &&
          other.stalled == stalled &&
          other.reachedGoal == reachedGoal);

  @override
  int get hashCode => Object.hashAll([
        position,
        effort,
        stalled,
        reachedGoal,
      ]);

  @override
  String toString() => 'GripperCommandResult(${toJson()})';
}

/// `control_msgs/msg/GripperCommand_Feedback`
final class GripperCommandFeedback implements RosMessage {
  const GripperCommandFeedback({
    this.position = 0,
    this.effort = 0,
    this.stalled = false,
    this.reachedGoal = false,
  });

  factory GripperCommandFeedback.fromJson(Map<String, Object?> json) =>
      GripperCommandFeedback(
        position: Field.doubleAt(json, 'position'),
        effort: Field.doubleAt(json, 'effort'),
        stalled: Field.boolAt(json, 'stalled'),
        reachedGoal: Field.boolAt(json, 'reached_goal'),
      );

  /// The current gripper gap size (in meters)
  final double position;

  /// The current effort exerted (in Newtons)
  final double effort;

  /// True iff the gripper is exerting max effort and not moving
  final bool stalled;

  /// True iff the gripper position has reached the commanded setpoint
  final bool reachedGoal;

  @override
  String get rosType => 'control_msgs/msg/GripperCommand_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'position': position,
        'effort': effort,
        'stalled': stalled,
        'reached_goal': reachedGoal,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GripperCommandFeedback &&
          other.position == position &&
          other.effort == effort &&
          other.stalled == stalled &&
          other.reachedGoal == reachedGoal);

  @override
  int get hashCode => Object.hashAll([
        position,
        effort,
        stalled,
        reachedGoal,
      ]);

  @override
  String toString() => 'GripperCommandFeedback(${toJson()})';
}

/// `control_msgs/msg/JointTrajectory_Goal`
final class JointTrajectoryGoal implements RosMessage {
  JointTrajectoryGoal({
    JointTrajectory? trajectory,
  }) : trajectory = trajectory ?? JointTrajectory();

  factory JointTrajectoryGoal.fromJson(Map<String, Object?> json) =>
      JointTrajectoryGoal(
        trajectory:
            Field.asMessage(json['trajectory'], JointTrajectory.fromJson),
      );

  final JointTrajectory trajectory;

  @override
  String get rosType => 'control_msgs/msg/JointTrajectory_Goal';

  @override
  Map<String, Object?> toJson() => {
        'trajectory': trajectory.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JointTrajectoryGoal && other.trajectory == trajectory);

  @override
  int get hashCode => Object.hashAll([
        trajectory,
      ]);

  @override
  String toString() => 'JointTrajectoryGoal(${toJson()})';
}

/// `control_msgs/msg/JointTrajectory_Result`
final class JointTrajectoryResult implements RosMessage {
  const JointTrajectoryResult();

  factory JointTrajectoryResult.fromJson(Map<String, Object?> json) =>
      JointTrajectoryResult();

  @override
  String get rosType => 'control_msgs/msg/JointTrajectory_Result';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is JointTrajectoryResult;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'JointTrajectoryResult(${toJson()})';
}

/// `control_msgs/msg/JointTrajectory_Feedback`
final class JointTrajectoryFeedback implements RosMessage {
  const JointTrajectoryFeedback();

  factory JointTrajectoryFeedback.fromJson(Map<String, Object?> json) =>
      JointTrajectoryFeedback();

  @override
  String get rosType => 'control_msgs/msg/JointTrajectory_Feedback';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is JointTrajectoryFeedback;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'JointTrajectoryFeedback(${toJson()})';
}

/// Parallel grippers refer to an end effector where two opposing fingers grasp an object from opposite sides.
///
/// `control_msgs/msg/ParallelGripperCommand_Goal`
final class ParallelGripperCommandGoal implements RosMessage {
  ParallelGripperCommandGoal({
    ros2.JointState? command,
  }) : command = command ?? ros2.JointState.fromJson(const {});

  factory ParallelGripperCommandGoal.fromJson(Map<String, Object?> json) =>
      ParallelGripperCommandGoal(
        command: Field.asMessage(json['command'], ros2.JointState.fromJson),
      );

  final ros2.JointState command;

  @override
  String get rosType => 'control_msgs/msg/ParallelGripperCommand_Goal';

  @override
  Map<String, Object?> toJson() => {
        'command': command.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParallelGripperCommandGoal && other.command == command);

  @override
  int get hashCode => Object.hashAll([
        command,
      ]);

  @override
  String toString() => 'ParallelGripperCommandGoal(${toJson()})';
}

/// `control_msgs/msg/ParallelGripperCommand_Result`
final class ParallelGripperCommandResult implements RosMessage {
  ParallelGripperCommandResult({
    ros2.JointState? state,
    this.stalled = false,
    this.reachedGoal = false,
  }) : state = state ?? ros2.JointState.fromJson(const {});

  factory ParallelGripperCommandResult.fromJson(Map<String, Object?> json) =>
      ParallelGripperCommandResult(
        state: Field.asMessage(json['state'], ros2.JointState.fromJson),
        stalled: Field.boolAt(json, 'stalled'),
        reachedGoal: Field.boolAt(json, 'reached_goal'),
      );

  /// The current gripper state.
  final ros2.JointState state;

  /// True if the gripper is exerting max effort and not moving
  final bool stalled;

  /// True if the gripper position has reached the commanded setpoint
  final bool reachedGoal;

  @override
  String get rosType => 'control_msgs/msg/ParallelGripperCommand_Result';

  @override
  Map<String, Object?> toJson() => {
        'state': state.toJson(),
        'stalled': stalled,
        'reached_goal': reachedGoal,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParallelGripperCommandResult &&
          other.state == state &&
          other.stalled == stalled &&
          other.reachedGoal == reachedGoal);

  @override
  int get hashCode => Object.hashAll([
        state,
        stalled,
        reachedGoal,
      ]);

  @override
  String toString() => 'ParallelGripperCommandResult(${toJson()})';
}

/// `control_msgs/msg/ParallelGripperCommand_Feedback`
final class ParallelGripperCommandFeedback implements RosMessage {
  ParallelGripperCommandFeedback({
    ros2.JointState? state,
  }) : state = state ?? ros2.JointState.fromJson(const {});

  factory ParallelGripperCommandFeedback.fromJson(Map<String, Object?> json) =>
      ParallelGripperCommandFeedback(
        state: Field.asMessage(json['state'], ros2.JointState.fromJson),
      );

  /// The current gripper state.
  final ros2.JointState state;

  @override
  String get rosType => 'control_msgs/msg/ParallelGripperCommand_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'state': state.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParallelGripperCommandFeedback && other.state == state);

  @override
  int get hashCode => Object.hashAll([
        state,
      ]);

  @override
  String toString() => 'ParallelGripperCommandFeedback(${toJson()})';
}

/// `control_msgs/msg/PointHead_Goal`
final class PointHeadGoal implements RosMessage {
  PointHeadGoal({
    PointStamped? target,
    ros2.Vector3? pointingAxis,
    this.pointingFrame = '',
    ros2.RosDuration? minDuration,
    this.maxVelocity = 0,
  })  : target = target ?? PointStamped(),
        pointingAxis = pointingAxis ?? ros2.Vector3(),
        minDuration = minDuration ?? ros2.RosDuration();

  factory PointHeadGoal.fromJson(Map<String, Object?> json) => PointHeadGoal(
        target: Field.asMessage(json['target'], PointStamped.fromJson),
        pointingAxis:
            Field.asMessage(json['pointing_axis'], ros2.Vector3.fromJson),
        pointingFrame: Field.stringAt(json, 'pointing_frame'),
        minDuration:
            Field.asMessage(json['min_duration'], ros2.RosDuration.fromJson),
        maxVelocity: Field.doubleAt(json, 'max_velocity'),
      );

  final PointStamped target;
  final ros2.Vector3 pointingAxis;
  final String pointingFrame;
  final ros2.RosDuration minDuration;
  final double maxVelocity;

  @override
  String get rosType => 'control_msgs/msg/PointHead_Goal';

  @override
  Map<String, Object?> toJson() => {
        'target': target.toJson(),
        'pointing_axis': pointingAxis.toJson(),
        'pointing_frame': pointingFrame,
        'min_duration': minDuration.toJson(),
        'max_velocity': maxVelocity,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PointHeadGoal &&
          other.target == target &&
          other.pointingAxis == pointingAxis &&
          other.pointingFrame == pointingFrame &&
          other.minDuration == minDuration &&
          other.maxVelocity == maxVelocity);

  @override
  int get hashCode => Object.hashAll([
        target,
        pointingAxis,
        pointingFrame,
        minDuration,
        maxVelocity,
      ]);

  @override
  String toString() => 'PointHeadGoal(${toJson()})';
}

/// `control_msgs/msg/PointHead_Result`
final class PointHeadResult implements RosMessage {
  const PointHeadResult();

  factory PointHeadResult.fromJson(Map<String, Object?> json) =>
      PointHeadResult();

  @override
  String get rosType => 'control_msgs/msg/PointHead_Result';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PointHeadResult;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'PointHeadResult(${toJson()})';
}

/// `control_msgs/msg/PointHead_Feedback`
final class PointHeadFeedback implements RosMessage {
  const PointHeadFeedback({
    this.pointingAngleError = 0,
  });

  factory PointHeadFeedback.fromJson(Map<String, Object?> json) =>
      PointHeadFeedback(
        pointingAngleError: Field.doubleAt(json, 'pointing_angle_error'),
      );

  final double pointingAngleError;

  @override
  String get rosType => 'control_msgs/msg/PointHead_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'pointing_angle_error': pointingAngleError,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PointHeadFeedback &&
          other.pointingAngleError == pointingAngleError);

  @override
  int get hashCode => Object.hashAll([
        pointingAngleError,
      ]);

  @override
  String toString() => 'PointHeadFeedback(${toJson()})';
}

/// `control_msgs/msg/SingleJointPosition_Goal`
final class SingleJointPositionGoal implements RosMessage {
  SingleJointPositionGoal({
    this.position = 0,
    ros2.RosDuration? minDuration,
    this.maxVelocity = 0,
  }) : minDuration = minDuration ?? ros2.RosDuration();

  factory SingleJointPositionGoal.fromJson(Map<String, Object?> json) =>
      SingleJointPositionGoal(
        position: Field.doubleAt(json, 'position'),
        minDuration:
            Field.asMessage(json['min_duration'], ros2.RosDuration.fromJson),
        maxVelocity: Field.doubleAt(json, 'max_velocity'),
      );

  final double position;
  final ros2.RosDuration minDuration;
  final double maxVelocity;

  @override
  String get rosType => 'control_msgs/msg/SingleJointPosition_Goal';

  @override
  Map<String, Object?> toJson() => {
        'position': position,
        'min_duration': minDuration.toJson(),
        'max_velocity': maxVelocity,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SingleJointPositionGoal &&
          other.position == position &&
          other.minDuration == minDuration &&
          other.maxVelocity == maxVelocity);

  @override
  int get hashCode => Object.hashAll([
        position,
        minDuration,
        maxVelocity,
      ]);

  @override
  String toString() => 'SingleJointPositionGoal(${toJson()})';
}

/// `control_msgs/msg/SingleJointPosition_Result`
final class SingleJointPositionResult implements RosMessage {
  const SingleJointPositionResult();

  factory SingleJointPositionResult.fromJson(Map<String, Object?> json) =>
      SingleJointPositionResult();

  @override
  String get rosType => 'control_msgs/msg/SingleJointPosition_Result';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SingleJointPositionResult;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'SingleJointPositionResult(${toJson()})';
}

/// `control_msgs/msg/SingleJointPosition_Feedback`
final class SingleJointPositionFeedback implements RosMessage {
  SingleJointPositionFeedback({
    ros2.Header? header,
    this.position = 0,
    this.velocity = 0,
    this.error = 0,
  }) : header = header ?? ros2.Header();

  factory SingleJointPositionFeedback.fromJson(Map<String, Object?> json) =>
      SingleJointPositionFeedback(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        position: Field.doubleAt(json, 'position'),
        velocity: Field.doubleAt(json, 'velocity'),
        error: Field.doubleAt(json, 'error'),
      );

  final ros2.Header header;
  final double position;
  final double velocity;
  final double error;

  @override
  String get rosType => 'control_msgs/msg/SingleJointPosition_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'position': position,
        'velocity': velocity,
        'error': error,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SingleJointPositionFeedback &&
          other.header == header &&
          other.position == position &&
          other.velocity == velocity &&
          other.error == error);

  @override
  int get hashCode => Object.hashAll([
        header,
        position,
        velocity,
        error,
      ]);

  @override
  String toString() => 'SingleJointPositionFeedback(${toJson()})';
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

/// Registers every message in `control_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerControlMsgs() {
  MessageRegistry.register(const MessageCodec<AdmittanceControllerState>(
    rosType: 'control_msgs/msg/AdmittanceControllerState',
    fromJson: AdmittanceControllerState.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<BatteryStateArray>(
    rosType: 'control_msgs/msg/BatteryStateArray',
    fromJson: BatteryStateArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DynamicInterfaceGroupValues>(
    rosType: 'control_msgs/msg/DynamicInterfaceGroupValues',
    fromJson: DynamicInterfaceGroupValues.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DynamicInterfaceValues>(
    rosType: 'control_msgs/msg/DynamicInterfaceValues',
    fromJson: DynamicInterfaceValues.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DynamicJointState>(
    rosType: 'control_msgs/msg/DynamicJointState',
    fromJson: DynamicJointState.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Float64Values>(
    rosType: 'control_msgs/msg/Float64Values',
    fromJson: Float64Values.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GripperCommand>(
    rosType: 'control_msgs/msg/GripperCommand',
    fromJson: GripperCommand.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<InterfaceValue>(
    rosType: 'control_msgs/msg/InterfaceValue',
    fromJson: InterfaceValue.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<JointComponentTolerance>(
    rosType: 'control_msgs/msg/JointComponentTolerance',
    fromJson: JointComponentTolerance.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<JointControllerState>(
    rosType: 'control_msgs/msg/JointControllerState',
    fromJson: JointControllerState.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<JointJog>(
    rosType: 'control_msgs/msg/JointJog',
    fromJson: JointJog.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<JointTolerance>(
    rosType: 'control_msgs/msg/JointTolerance',
    fromJson: JointTolerance.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<JointTrajectoryControllerState>(
    rosType: 'control_msgs/msg/JointTrajectoryControllerState',
    fromJson: JointTrajectoryControllerState.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Keys>(
    rosType: 'control_msgs/msg/Keys',
    fromJson: Keys.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MecanumDriveControllerState>(
    rosType: 'control_msgs/msg/MecanumDriveControllerState',
    fromJson: MecanumDriveControllerState.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MotionArgument>(
    rosType: 'control_msgs/msg/MotionArgument',
    fromJson: MotionArgument.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MotionPrimitive>(
    rosType: 'control_msgs/msg/MotionPrimitive',
    fromJson: MotionPrimitive.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MotionPrimitiveSequence>(
    rosType: 'control_msgs/msg/MotionPrimitiveSequence',
    fromJson: MotionPrimitiveSequence.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MultiDOFCommand>(
    rosType: 'control_msgs/msg/MultiDOFCommand',
    fromJson: MultiDOFCommand.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MultiDOFStateStamped>(
    rosType: 'control_msgs/msg/MultiDOFStateStamped',
    fromJson: MultiDOFStateStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<PidState>(
    rosType: 'control_msgs/msg/PidState',
    fromJson: PidState.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SingleDOFState>(
    rosType: 'control_msgs/msg/SingleDOFState',
    fromJson: SingleDOFState.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SingleDOFStateStamped>(
    rosType: 'control_msgs/msg/SingleDOFStateStamped',
    fromJson: SingleDOFStateStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SpeedScalingFactor>(
    rosType: 'control_msgs/msg/SpeedScalingFactor',
    fromJson: SpeedScalingFactor.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SteeringControllerStatus>(
    rosType: 'control_msgs/msg/SteeringControllerStatus',
    fromJson: SteeringControllerStatus.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<VDA5050SafetyState>(
    rosType: 'control_msgs/msg/VDA5050SafetyState',
    fromJson: VDA5050SafetyState.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<QueryCalibrationStateRequest>(
    rosType: 'control_msgs/msg/QueryCalibrationState_Request',
    fromJson: QueryCalibrationStateRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<QueryCalibrationStateResponse>(
    rosType: 'control_msgs/msg/QueryCalibrationState_Response',
    fromJson: QueryCalibrationStateResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<QueryTrajectoryStateRequest>(
    rosType: 'control_msgs/msg/QueryTrajectoryState_Request',
    fromJson: QueryTrajectoryStateRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<QueryTrajectoryStateResponse>(
    rosType: 'control_msgs/msg/QueryTrajectoryState_Response',
    fromJson: QueryTrajectoryStateResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SetOdometryRequest>(
    rosType: 'control_msgs/msg/SetOdometry_Request',
    fromJson: SetOdometryRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SetOdometryResponse>(
    rosType: 'control_msgs/msg/SetOdometry_Response',
    fromJson: SetOdometryResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(
      const MessageCodec<ExecuteMotionPrimitiveSequenceGoal>(
    rosType: 'control_msgs/msg/ExecuteMotionPrimitiveSequence_Goal',
    fromJson: ExecuteMotionPrimitiveSequenceGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(
      const MessageCodec<ExecuteMotionPrimitiveSequenceResult>(
    rosType: 'control_msgs/msg/ExecuteMotionPrimitiveSequence_Result',
    fromJson: ExecuteMotionPrimitiveSequenceResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(
      const MessageCodec<ExecuteMotionPrimitiveSequenceFeedback>(
    rosType: 'control_msgs/msg/ExecuteMotionPrimitiveSequence_Feedback',
    fromJson: ExecuteMotionPrimitiveSequenceFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowJointTrajectoryGoal>(
    rosType: 'control_msgs/msg/FollowJointTrajectory_Goal',
    fromJson: FollowJointTrajectoryGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowJointTrajectoryResult>(
    rosType: 'control_msgs/msg/FollowJointTrajectory_Result',
    fromJson: FollowJointTrajectoryResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowJointTrajectoryFeedback>(
    rosType: 'control_msgs/msg/FollowJointTrajectory_Feedback',
    fromJson: FollowJointTrajectoryFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GripperCommandGoal>(
    rosType: 'control_msgs/msg/GripperCommand_Goal',
    fromJson: GripperCommandGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GripperCommandResult>(
    rosType: 'control_msgs/msg/GripperCommand_Result',
    fromJson: GripperCommandResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GripperCommandFeedback>(
    rosType: 'control_msgs/msg/GripperCommand_Feedback',
    fromJson: GripperCommandFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<JointTrajectoryGoal>(
    rosType: 'control_msgs/msg/JointTrajectory_Goal',
    fromJson: JointTrajectoryGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<JointTrajectoryResult>(
    rosType: 'control_msgs/msg/JointTrajectory_Result',
    fromJson: JointTrajectoryResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<JointTrajectoryFeedback>(
    rosType: 'control_msgs/msg/JointTrajectory_Feedback',
    fromJson: JointTrajectoryFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ParallelGripperCommandGoal>(
    rosType: 'control_msgs/msg/ParallelGripperCommand_Goal',
    fromJson: ParallelGripperCommandGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ParallelGripperCommandResult>(
    rosType: 'control_msgs/msg/ParallelGripperCommand_Result',
    fromJson: ParallelGripperCommandResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ParallelGripperCommandFeedback>(
    rosType: 'control_msgs/msg/ParallelGripperCommand_Feedback',
    fromJson: ParallelGripperCommandFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<PointHeadGoal>(
    rosType: 'control_msgs/msg/PointHead_Goal',
    fromJson: PointHeadGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<PointHeadResult>(
    rosType: 'control_msgs/msg/PointHead_Result',
    fromJson: PointHeadResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<PointHeadFeedback>(
    rosType: 'control_msgs/msg/PointHead_Feedback',
    fromJson: PointHeadFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SingleJointPositionGoal>(
    rosType: 'control_msgs/msg/SingleJointPosition_Goal',
    fromJson: SingleJointPositionGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SingleJointPositionResult>(
    rosType: 'control_msgs/msg/SingleJointPosition_Result',
    fromJson: SingleJointPositionResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SingleJointPositionFeedback>(
    rosType: 'control_msgs/msg/SingleJointPosition_Feedback',
    fromJson: SingleJointPositionFeedback.fromJson,
    toJson: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<QueryCalibrationStateRequest,
      QueryCalibrationStateResponse>(
    serviceType: 'control_msgs/srv/QueryCalibrationState',
    encodeRequest: _toJson,
    decodeResponse: QueryCalibrationStateResponse.fromJson,
    decodeRequest: QueryCalibrationStateRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<QueryTrajectoryStateRequest,
      QueryTrajectoryStateResponse>(
    serviceType: 'control_msgs/srv/QueryTrajectoryState',
    encodeRequest: _toJson,
    decodeResponse: QueryTrajectoryStateResponse.fromJson,
    decodeRequest: QueryTrajectoryStateRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<SetOdometryRequest, SetOdometryResponse>(
    serviceType: 'control_msgs/srv/SetOdometry',
    encodeRequest: _toJson,
    decodeResponse: SetOdometryResponse.fromJson,
    decodeRequest: SetOdometryRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ActionRegistry.register(const ActionCodec<
      ExecuteMotionPrimitiveSequenceGoal,
      ExecuteMotionPrimitiveSequenceFeedback,
      ExecuteMotionPrimitiveSequenceResult>(
    actionType: 'control_msgs/action/ExecuteMotionPrimitiveSequence',
    encodeGoal: _toJson,
    decodeFeedback: ExecuteMotionPrimitiveSequenceFeedback.fromJson,
    decodeResult: ExecuteMotionPrimitiveSequenceResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<FollowJointTrajectoryGoal,
      FollowJointTrajectoryFeedback, FollowJointTrajectoryResult>(
    actionType: 'control_msgs/action/FollowJointTrajectory',
    encodeGoal: _toJson,
    decodeFeedback: FollowJointTrajectoryFeedback.fromJson,
    decodeResult: FollowJointTrajectoryResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<GripperCommandGoal,
      GripperCommandFeedback, GripperCommandResult>(
    actionType: 'control_msgs/action/GripperCommand',
    encodeGoal: _toJson,
    decodeFeedback: GripperCommandFeedback.fromJson,
    decodeResult: GripperCommandResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<JointTrajectoryGoal,
      JointTrajectoryFeedback, JointTrajectoryResult>(
    actionType: 'control_msgs/action/JointTrajectory',
    encodeGoal: _toJson,
    decodeFeedback: JointTrajectoryFeedback.fromJson,
    decodeResult: JointTrajectoryResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<ParallelGripperCommandGoal,
      ParallelGripperCommandFeedback, ParallelGripperCommandResult>(
    actionType: 'control_msgs/action/ParallelGripperCommand',
    encodeGoal: _toJson,
    decodeFeedback: ParallelGripperCommandFeedback.fromJson,
    decodeResult: ParallelGripperCommandResult.fromJson,
  ));
  ActionRegistry.register(
      const ActionCodec<PointHeadGoal, PointHeadFeedback, PointHeadResult>(
    actionType: 'control_msgs/action/PointHead',
    encodeGoal: _toJson,
    decodeFeedback: PointHeadFeedback.fromJson,
    decodeResult: PointHeadResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<SingleJointPositionGoal,
      SingleJointPositionFeedback, SingleJointPositionResult>(
    actionType: 'control_msgs/action/SingleJointPosition',
    encodeGoal: _toJson,
    decodeFeedback: SingleJointPositionFeedback.fromJson,
    decodeResult: SingleJointPositionResult.fromJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
