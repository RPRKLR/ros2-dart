/// The minimal surface generated message libraries depend on.
///
/// Generated code imports this rather than the full `ros2_client.dart` barrel,
/// so a generated `sensor_msgs/msg/Image` does not collide with the bundled
/// one. Nothing here exports a message class.
library;

export 'src/messages/conversions.dart' show Field;
export 'src/messages/action.dart' show ActionCodec, ActionRegistry;
export 'src/messages/message.dart'
    show MessageCodec, MessageRegistry, RosMessage;
export 'src/messages/service.dart' show ServiceCodec, ServiceRegistry;
