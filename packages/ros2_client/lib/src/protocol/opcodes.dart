/// Opcodes of the rosbridge v2 protocol.
///
/// See https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md
abstract final class Op {
  // Topics
  static const advertise = 'advertise';
  static const unadvertise = 'unadvertise';
  static const publish = 'publish';
  static const subscribe = 'subscribe';
  static const unsubscribe = 'unsubscribe';

  // Services
  static const callService = 'call_service';
  static const serviceResponse = 'service_response';
  static const advertiseService = 'advertise_service';
  static const unadvertiseService = 'unadvertise_service';

  // Actions (rosbridge_suite >= 2.0.0)
  static const advertiseAction = 'advertise_action';
  static const unadvertiseAction = 'unadvertise_action';
  static const sendActionGoal = 'send_action_goal';
  static const cancelActionGoal = 'cancel_action_goal';
  static const actionFeedback = 'action_feedback';
  static const actionResult = 'action_result';

  // Transport-level
  static const fragment = 'fragment';
  static const png = 'png';
  static const status = 'status';
  static const setLevel = 'set_level';
  static const auth = 'auth';
}

/// Wire compression for subscriptions.
enum Compression {
  /// Plain JSON. Universally supported, slowest for binary payloads.
  none('none'),

  /// PNG-encoded binary blob.
  ///
  /// rosbridge PNG-compresses the *entire JSON message string* into an RGB
  /// image, so the win depends on how repetitive the JSON is: large for a
  /// mostly-empty occupancy grid, small for camera data whose base64 payload
  /// is already high-entropy. Decoding requires a full PNG + zlib decoder, so
  /// this client does not implement it — subscribing with [png] will log a
  /// status message and drop the frame. Prefer [cbor].
  png('png'),

  /// CBOR with RFC 8746 typed arrays. Best choice for images/point clouds.
  cbor('cbor'),

  /// CBOR envelope wrapping the raw CDR-serialised ROS 2 message.
  ///
  /// Requires a CDR decoder to interpret; [Ros2Client] surfaces it as bytes.
  cborRaw('cbor-raw');

  const Compression(this.wireName);
  final String wireName;
}

/// Severity levels emitted by rosbridge `status` messages.
enum StatusLevel {
  none('none'),
  error('error'),
  warning('warning'),
  info('info');

  const StatusLevel(this.wireName);
  final String wireName;

  static StatusLevel parse(String s) => StatusLevel.values
      .firstWhere((l) => l.wireName == s, orElse: () => StatusLevel.info);
}
