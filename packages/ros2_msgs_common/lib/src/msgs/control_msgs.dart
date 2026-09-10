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

/// `control_msgs/msg/GripperCommand`
final class GripperCommand implements RosMessage {
  const GripperCommand({
    this.position = 0,
    this.maxEffort = 0,
  });

  factory GripperCommand.fromJson(Map<String, Object?> json) => GripperCommand(
        position: Field.asDouble(json['position']),
        maxEffort: Field.asDouble(json['max_effort']),
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
        values: Field.asFloat64List(json['values']),
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
        jointName: Field.asString(json['joint_name']),
        component: Field.asInt(json['component']),
        position: Field.asDouble(json['position']),
        velocity: Field.asDouble(json['velocity']),
        acceleration: Field.asDouble(json['acceleration']),
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
        setPoint: Field.asDouble(json['set_point']),
        processValue: Field.asDouble(json['process_value']),
        processValueDot: Field.asDouble(json['process_value_dot']),
        error: Field.asDouble(json['error']),
        timeStep: Field.asDouble(json['time_step']),
        command: Field.asDouble(json['command']),
        p: Field.asDouble(json['p']),
        i: Field.asDouble(json['i']),
        d: Field.asDouble(json['d']),
        iClamp: Field.asDouble(json['i_clamp']),
        antiwindup: Field.asBool(json['antiwindup']),
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
        displacements: Field.asFloat64List(json['displacements']),
        velocities: Field.asFloat64List(json['velocities']),
        duration: Field.asDouble(json['duration']),
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
        name: Field.asString(json['name']),
        position: Field.asDouble(json['position']),
        velocity: Field.asDouble(json['velocity']),
        acceleration: Field.asDouble(json['acceleration']),
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
    JointTrajectoryPoint? desired,
    JointTrajectoryPoint? actual,
    this.multiDofJointNames = const [],
    MultiDOFJointTrajectoryPoint? multiDofReference,
    MultiDOFJointTrajectoryPoint? multiDofFeedback,
    MultiDOFJointTrajectoryPoint? multiDofError,
    MultiDOFJointTrajectoryPoint? multiDofOutput,
    MultiDOFJointTrajectoryPoint? multiDofDesired,
    MultiDOFJointTrajectoryPoint? multiDofActual,
  })  : header = header ?? ros2.Header(),
        reference = reference ?? JointTrajectoryPoint(),
        feedback = feedback ?? JointTrajectoryPoint(),
        error = error ?? JointTrajectoryPoint(),
        output = output ?? JointTrajectoryPoint(),
        desired = desired ?? JointTrajectoryPoint(),
        actual = actual ?? JointTrajectoryPoint(),
        multiDofReference = multiDofReference ?? MultiDOFJointTrajectoryPoint(),
        multiDofFeedback = multiDofFeedback ?? MultiDOFJointTrajectoryPoint(),
        multiDofError = multiDofError ?? MultiDOFJointTrajectoryPoint(),
        multiDofOutput = multiDofOutput ?? MultiDOFJointTrajectoryPoint(),
        multiDofDesired = multiDofDesired ?? MultiDOFJointTrajectoryPoint(),
        multiDofActual = multiDofActual ?? MultiDOFJointTrajectoryPoint();

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
        desired:
            Field.asMessage(json['desired'], JointTrajectoryPoint.fromJson),
        actual: Field.asMessage(json['actual'], JointTrajectoryPoint.fromJson),
        multiDofJointNames: Field.asStringList(json['multi_dof_joint_names']),
        multiDofReference: Field.asMessage(
            json['multi_dof_reference'], MultiDOFJointTrajectoryPoint.fromJson),
        multiDofFeedback: Field.asMessage(
            json['multi_dof_feedback'], MultiDOFJointTrajectoryPoint.fromJson),
        multiDofError: Field.asMessage(
            json['multi_dof_error'], MultiDOFJointTrajectoryPoint.fromJson),
        multiDofOutput: Field.asMessage(
            json['multi_dof_output'], MultiDOFJointTrajectoryPoint.fromJson),
        multiDofDesired: Field.asMessage(
            json['multi_dof_desired'], MultiDOFJointTrajectoryPoint.fromJson),
        multiDofActual: Field.asMessage(
            json['multi_dof_actual'], MultiDOFJointTrajectoryPoint.fromJson),
      );

  final ros2.Header header;
  final List<String> jointNames;
  final JointTrajectoryPoint reference;
  final JointTrajectoryPoint feedback;
  final JointTrajectoryPoint error;
  final JointTrajectoryPoint output;
  final JointTrajectoryPoint desired;
  final JointTrajectoryPoint actual;
  final List<String> multiDofJointNames;
  final MultiDOFJointTrajectoryPoint multiDofReference;
  final MultiDOFJointTrajectoryPoint multiDofFeedback;
  final MultiDOFJointTrajectoryPoint multiDofError;
  final MultiDOFJointTrajectoryPoint multiDofOutput;
  final MultiDOFJointTrajectoryPoint multiDofDesired;
  final MultiDOFJointTrajectoryPoint multiDofActual;

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
        'desired': desired.toJson(),
        'actual': actual.toJson(),
        'multi_dof_joint_names': multiDofJointNames,
        'multi_dof_reference': multiDofReference.toJson(),
        'multi_dof_feedback': multiDofFeedback.toJson(),
        'multi_dof_error': multiDofError.toJson(),
        'multi_dof_output': multiDofOutput.toJson(),
        'multi_dof_desired': multiDofDesired.toJson(),
        'multi_dof_actual': multiDofActual.toJson(),
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
          other.desired == desired &&
          other.actual == actual &&
          _listEquals(other.multiDofJointNames, multiDofJointNames) &&
          other.multiDofReference == multiDofReference &&
          other.multiDofFeedback == multiDofFeedback &&
          other.multiDofError == multiDofError &&
          other.multiDofOutput == multiDofOutput &&
          other.multiDofDesired == multiDofDesired &&
          other.multiDofActual == multiDofActual);

  @override
  int get hashCode => Object.hashAll([
        header,
        ...jointNames,
        reference,
        feedback,
        error,
        output,
        desired,
        actual,
        ...multiDofJointNames,
        multiDofReference,
        multiDofFeedback,
        multiDofError,
        multiDofOutput,
        multiDofDesired,
        multiDofActual,
      ]);

  @override
  String toString() => 'JointTrajectoryControllerState(${toJson()})';
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
            Field.asDouble(json['front_left_wheel_velocity']),
        backLeftWheelVelocity: Field.asDouble(json['back_left_wheel_velocity']),
        backRightWheelVelocity:
            Field.asDouble(json['back_right_wheel_velocity']),
        frontRightWheelVelocity:
            Field.asDouble(json['front_right_wheel_velocity']),
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
        values: Field.asFloat64List(json['values']),
        valuesDot: Field.asFloat64List(json['values_dot']),
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
        error: Field.asDouble(json['error']),
        errorDot: Field.asDouble(json['error_dot']),
        pError: Field.asDouble(json['p_error']),
        iError: Field.asDouble(json['i_error']),
        dError: Field.asDouble(json['d_error']),
        pTerm: Field.asDouble(json['p_term']),
        iTerm: Field.asDouble(json['i_term']),
        dTerm: Field.asDouble(json['d_term']),
        iMax: Field.asDouble(json['i_max']),
        iMin: Field.asDouble(json['i_min']),
        output: Field.asDouble(json['output']),
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
        name: Field.asString(json['name']),
        reference: Field.asDouble(json['reference']),
        feedback: Field.asDouble(json['feedback']),
        feedbackDot: Field.asDouble(json['feedback_dot']),
        error: Field.asDouble(json['error']),
        errorDot: Field.asDouble(json['error_dot']),
        timeStep: Field.asDouble(json['time_step']),
        output: Field.asDouble(json['output']),
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
        tractionWheelsPosition:
            Field.asFloat64List(json['traction_wheels_position']),
        tractionWheelsVelocity:
            Field.asFloat64List(json['traction_wheels_velocity']),
        steerPositions: Field.asFloat64List(json['steer_positions']),
        linearVelocityCommand:
            Field.asFloat64List(json['linear_velocity_command']),
        steeringAngleCommand:
            Field.asFloat64List(json['steering_angle_command']),
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
        isCalibrated: Field.asBool(json['is_calibrated']),
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
        success: Field.asBool(json['success']),
        message: Field.asString(json['message']),
        name: Field.asStringList(json['name']),
        position: Field.asFloat64List(json['position']),
        velocity: Field.asFloat64List(json['velocity']),
        acceleration: Field.asFloat64List(json['acceleration']),
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
        errorCode: Field.asInt(json['error_code']),
        errorString: Field.asString(json['error_string']),
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
        position: Field.asDouble(json['position']),
        effort: Field.asDouble(json['effort']),
        stalled: Field.asBool(json['stalled']),
        reachedGoal: Field.asBool(json['reached_goal']),
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
        position: Field.asDouble(json['position']),
        effort: Field.asDouble(json['effort']),
        stalled: Field.asBool(json['stalled']),
        reachedGoal: Field.asBool(json['reached_goal']),
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
        stalled: Field.asBool(json['stalled']),
        reachedGoal: Field.asBool(json['reached_goal']),
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
        pointingFrame: Field.asString(json['pointing_frame']),
        minDuration:
            Field.asMessage(json['min_duration'], ros2.RosDuration.fromJson),
        maxVelocity: Field.asDouble(json['max_velocity']),
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
        pointingAngleError: Field.asDouble(json['pointing_angle_error']),
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
        position: Field.asDouble(json['position']),
        minDuration:
            Field.asMessage(json['min_duration'], ros2.RosDuration.fromJson),
        maxVelocity: Field.asDouble(json['max_velocity']),
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
        position: Field.asDouble(json['position']),
        velocity: Field.asDouble(json['velocity']),
        error: Field.asDouble(json['error']),
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
  MessageRegistry.register(const MessageCodec<DynamicInterfaceGroupValues>(
    rosType: 'control_msgs/msg/DynamicInterfaceGroupValues',
    fromJson: DynamicInterfaceGroupValues.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DynamicJointState>(
    rosType: 'control_msgs/msg/DynamicJointState',
    fromJson: DynamicJointState.fromJson,
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
  MessageRegistry.register(const MessageCodec<MecanumDriveControllerState>(
    rosType: 'control_msgs/msg/MecanumDriveControllerState',
    fromJson: MecanumDriveControllerState.fromJson,
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
  MessageRegistry.register(const MessageCodec<SteeringControllerStatus>(
    rosType: 'control_msgs/msg/SteeringControllerStatus',
    fromJson: SteeringControllerStatus.fromJson,
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
