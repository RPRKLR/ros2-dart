/// A type-safe, streaming ROS 2 client for Dart and Flutter.
///
/// Speaks the rosbridge v2 protocol over WebSockets, so it runs everywhere
/// Dart runs — Android, iOS, Linux, macOS, Windows and the browser — without
/// needing a ROS installation on the client.
///
/// ```dart
/// final ros = Ros2Client(Uri.parse('ws://192.168.1.10:9090'));
/// await ros.connect();
///
/// ros.subscribe<LaserScan>('/scan', qos: QosProfile.sensorData)
///    .listen((scan) => print('${scan.ranges.length} beams'));
///
/// final cmdVel = ros.advertise<Twist>('/cmd_vel');
/// cmdVel.publish(Twist.drive(forward: 0.2, turn: 0.1));
/// ```
library;

export 'src/client.dart' show GoalHandle, Ros2Client, RosPublisher, RosStatus;
export 'src/encoding/wire_codec.dart' show WireCodec;
export 'src/introspection/introspection.dart'
    show NodeInfo, Ros2Introspection, TopicInfo;
export 'src/messages/action.dart'
    show ActionCodec, ActionFailedException, ActionRegistry, GoalStatus;
export 'src/messages/conversions.dart' show Field;
export 'src/messages/geometry_msgs.dart';
export 'src/messages/message.dart'
    show
        JsonMessage,
        MessageCodec,
        MessageRegistry,
        RosMessage,
        UnknownMessageTypeError;
export 'src/messages/nav_msgs.dart';
export 'src/messages/registry.dart' show registerStandardMessages;
export 'src/messages/point_cloud_reader.dart'
    show PointCloudReader, PointCloudFormatException;
export 'src/messages/sensor_msgs.dart';
export 'src/messages/service.dart'
    show ServiceCallException, ServiceCodec, ServiceRegistry;
export 'src/messages/std_msgs.dart';
export 'src/protocol/opcodes.dart' show Compression, StatusLevel;
export 'src/protocol/backpressure.dart' show Backpressure;
export 'src/protocol/qos.dart'
    show Durability, History, Liveliness, QosProfile, Reliability;
export 'src/tf/tf_buffer.dart' show TfBuffer, TfException;
export 'src/tf/tf_listener.dart' show TfListener;
export 'src/tf/transform_math.dart'
    show PointMath, QuaternionMath, TransformMath, Vector3Math;
export 'src/transport/transport.dart'
    show RosConnectionState, ReconnectPolicy, RosTransport;
export 'src/transport/websocket_transport.dart' show WebSocketTransport;
