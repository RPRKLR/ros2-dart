/// Pre-generated Dart classes for the common ROS 2 interface packages, so most
/// apps never need to run the generator.
///
/// This library exposes only the registration entry point. It deliberately
/// re-exports no message classes: ROS reuses type names across packages
/// (`geometry_msgs/Polygon` and `shape_msgs/Mesh` are fine together, but
/// `nav2_msgs/SpeedLimit` and a vendor's own `SpeedLimit` are not), and a
/// single barrel cannot export both. Import the package you need:
///
/// ```dart
/// import 'package:ros2_client/ros2_client.dart';
/// import 'package:ros2_msgs_common/ros2_msgs_common.dart';
/// import 'package:ros2_msgs_common/nav2_msgs.dart';
///
/// void main() {
///   registerStandardMessages();
///   registerCommonMessages();
///   ...
/// }
/// ```
///
/// The core types — `Twist`, `Pose`, `LaserScan`, `RosImage`, `Header` — come
/// from `ros2_client` itself and are **not** duplicated here. The
/// `geometry_msgs` and `std_msgs` libraries in this package hold only the
/// types the client does not already bundle.
library;

import 'src/msgs/generated.dart' as generated;

/// Registers every message, service and action in this package.
///
/// Call once at startup, after `registerStandardMessages()` and before the
/// first subscribe, advertise, service call or action goal.
void registerCommonMessages() => generated.registerGeneratedMessages();
