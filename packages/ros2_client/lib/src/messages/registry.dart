import 'geometry_msgs.dart';
import 'nav_msgs.dart';
import 'sensor_msgs.dart';
import 'std_msgs.dart';

/// Registers codecs for the bundled `std_msgs`, `geometry_msgs`,
/// `sensor_msgs` and `nav_msgs` types.
///
/// Call once at startup, before the first `subscribe<T>()` or `advertise<T>()`.
/// It is idempotent, so calling it again — from a test, or a second isolate —
/// is harmless.
void registerStandardMessages() {
  registerStdMsgs();
  registerGeometryMsgs();
  registerSensorMsgs();
  registerNavMsgs();
}
