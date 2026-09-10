/// Flutter widgets for ROS 2, built on `package:ros2_client`.
///
/// Wrap your app in a [RosConnection] and the rest of the widgets find the
/// client automatically:
///
/// ```dart
/// RosConnection(
///   uri: Uri.parse('ws://192.168.1.10:9090'),
///   child: Scaffold(
///     body: Column(children: [
///       const Expanded(child: RosLaserScanView()),
///       RosTopicBuilder<BatteryState>(
///         topic: '/battery_state',
///         builder: (context, b) =>
///             Text(b == null ? '—' : '${(b.percentage * 100).round()}%'),
///       ),
///       const TeleopJoystick(),
///     ]),
///   ),
/// )
/// ```
library;

export 'package:ros2_client/ros2_client.dart';

export 'src/ros_connection.dart'
    show RosConnection, RosConnectionBuilder;
export 'src/ros_stream_builder.dart' show RosTopicBuilder;
export 'src/widgets/camera_view.dart' show RosCameraView, RosRawImageView;
export 'src/widgets/laser_scan_view.dart' show RosLaserScanView;
export 'src/widgets/teleop_joystick.dart' show TeleopJoystick, TeleopPad;
export 'src/widgets/tf_frame_builder.dart' show TfFrameBuilder;
