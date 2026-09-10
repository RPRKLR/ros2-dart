// GENERATED CODE - DO NOT EDIT BY HAND.

import 'action_msgs.dart';
import 'control_msgs.dart';
import 'diagnostic_msgs.dart';
import 'geometry_msgs.dart';
import 'lifecycle_msgs.dart';
import 'nav2_msgs.dart';
import 'shape_msgs.dart';
import 'std_msgs.dart';
import 'tf2_msgs.dart';
import 'trajectory_msgs.dart';
import 'unique_identifier_msgs.dart';
import 'visualization_msgs.dart';

/// Registers every generated message, service and action.
///
/// Call once at startup, before the first subscribe, advertise,
/// service call or action goal. This barrel intentionally does
/// not re-export the types: import the individual libraries
/// listed below, since ROS packages reuse type names.
///
/// * `action_msgs.dart`
/// * `control_msgs.dart`
/// * `diagnostic_msgs.dart`
/// * `geometry_msgs.dart`
/// * `lifecycle_msgs.dart`
/// * `nav2_msgs.dart`
/// * `shape_msgs.dart`
/// * `std_msgs.dart`
/// * `tf2_msgs.dart`
/// * `trajectory_msgs.dart`
/// * `unique_identifier_msgs.dart`
/// * `visualization_msgs.dart`
void registerGeneratedMessages() {
  registerActionMsgs();
  registerControlMsgs();
  registerDiagnosticMsgs();
  registerGeometryMsgs();
  registerLifecycleMsgs();
  registerNav2Msgs();
  registerShapeMsgs();
  registerStdMsgs();
  registerTf2Msgs();
  registerTrajectoryMsgs();
  registerUniqueIdentifierMsgs();
  registerVisualizationMsgs();
}
