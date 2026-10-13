/// Pre-generated Dart classes for the common ROS 2 interface packages, so most
/// apps never need to run the generator.
///
/// This library exposes only the registration entry points. It deliberately
/// re-exports no message classes: ROS reuses type names across packages
/// (`geometry_msgs/Polygon` and `shape_msgs/Mesh` are fine together, but
/// `nav2_msgs/SpeedLimit` and a vendor's own `SpeedLimit` are not), and a
/// single barrel cannot export both. Import the package you need, from the
/// directory for your robot's distro:
///
/// ```dart
/// import 'package:ros2_client/ros2_client.dart';
/// import 'package:ros2_msgs_common/ros2_msgs_common.dart';
/// import 'package:ros2_msgs_common/jazzy/nav2_msgs.dart';
///
/// void main() {
///   registerStandardMessages();
///   registerJazzyMessages();
///   ...
/// }
/// ```
///
/// **Use one distro per app.** The distros disagree on the wire: Jazzy's
/// `NavigateToPose` result reports an `error_code` that Humble's lacks, and
/// rosbridge refuses a published message carrying a field its own distro does
/// not define. Both sets register under the same ROS type names, so
/// registering both leaves whichever ran last.
///
/// The core types — `Twist`, `Pose`, `LaserScan`, `RosImage`, `Header` — come
/// from `ros2_client` itself and are **not** duplicated here. The
/// `geometry_msgs` and `std_msgs` libraries in this package hold only the
/// types the client does not already bundle.
library;

import 'src/humble/generated.dart' as humble;
import 'src/jazzy/generated.dart' as jazzy;

/// Registers every message, service and action in the ROS 2 Humble set, the
/// types in `package:ros2_msgs_common/humble/...`.
///
/// Call once at startup, after `registerStandardMessages()` and before the
/// first subscribe, advertise, service call or action goal.
void registerHumbleMessages() => humble.registerGeneratedMessages();

/// Registers every message, service and action in the ROS 2 Jazzy set, the
/// types in `package:ros2_msgs_common/jazzy/...`.
///
/// Call once at startup, after `registerStandardMessages()` and before the
/// first subscribe, advertise, service call or action goal.
void registerJazzyMessages() => jazzy.registerGeneratedMessages();

/// Registers the ROS 2 Humble set: the same as [registerHumbleMessages].
///
/// Kept from before the per-distro libraries, alongside the unprefixed
/// imports such as `package:ros2_msgs_common/nav2_msgs.dart`, which are also
/// Humble.
void registerCommonMessages() => registerHumbleMessages();
