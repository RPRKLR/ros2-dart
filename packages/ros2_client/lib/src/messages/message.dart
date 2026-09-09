import 'package:meta/meta.dart';

/// Marker for a generated (or hand-written) ROS 2 message type.
///
/// Implementations are value types: immutable, with structural equality, so
/// they can be compared, cached and used as Flutter widget inputs safely.
abstract interface class RosMessage {
  /// The fully qualified ROS type name, e.g. `geometry_msgs/msg/Twist`.
  String get rosType;

  /// The rosbridge JSON representation of this message.
  Map<String, Object?> toJson();
}

/// Bidirectional converter between a Dart type [T] and the rosbridge wire form.
///
/// One codec is registered per message type; [MessageRegistry] resolves them
/// either by Dart [Type] (for the type-safe API) or by ROS type name (for
/// dynamically discovered topics).
@immutable
final class MessageCodec<T> {
  const MessageCodec({
    required this.rosType,
    required this.fromJson,
    required this.toJson,
  });

  /// Fully qualified ROS type name, e.g. `sensor_msgs/msg/Image`.
  final String rosType;

  final T Function(Map<String, Object?> json) fromJson;
  final Map<String, Object?> Function(T value) toJson;

  @override
  String toString() => 'MessageCodec<$T>($rosType)';
}

/// Thrown when a message type is used before its codec has been registered.
final class UnknownMessageTypeError extends Error {
  UnknownMessageTypeError(this.description);
  final String description;

  @override
  String toString() => 'UnknownMessageTypeError: $description\n'
      'Register it with MessageRegistry.register(...), import the generated '
      'package that defines it, or use the dynamic API '
      '(subscribeJson / publishJson) instead.';
}

/// Global registry of message codecs.
///
/// Generated message libraries register themselves on import via a top-level
/// `registerXxxMsgs()` call, so the common case needs no user setup.
abstract final class MessageRegistry {
  static final Map<Type, MessageCodec<Object?>> _byDartType = {};
  static final Map<String, MessageCodec<Object?>> _byRosType = {};

  /// Registers [codec] for Dart type [T]. Idempotent for identical types.
  static void register<T>(MessageCodec<T> codec) {
    _byDartType[T] = codec as MessageCodec<Object?>;
    _byRosType[codec.rosType] = codec as MessageCodec<Object?>;
    // ROS 1-style names (`std_msgs/String`) still appear in the wild and in
    // some rosbridge responses; accept them as aliases.
    final short = _shortName(codec.rosType);
    if (short != null) {
      _byRosType.putIfAbsent(short, () => codec as MessageCodec<Object?>);
    }
  }

  /// Resolves the codec for Dart type [T].
  ///
  /// Throws [UnknownMessageTypeError] if [T] has not been registered.
  static MessageCodec<T> of<T>() {
    final codec = _byDartType[T];
    if (codec == null) {
      throw UnknownMessageTypeError('No codec registered for Dart type `$T`.');
    }
    return codec as MessageCodec<T>;
  }

  /// Resolves the codec for a ROS type name, or `null` if unregistered.
  static MessageCodec<Object?>? byRosType(String rosType) =>
      _byRosType[rosType] ?? _byRosType[_shortName(rosType) ?? rosType];

  /// True if Dart type [T] has a registered codec.
  static bool has<T>() => _byDartType.containsKey(T);

  /// All registered ROS type names.
  static Iterable<String> get knownTypes => _byRosType.keys;

  /// Drops all registrations. Test-only.
  @visibleForTesting
  static void reset() {
    _byDartType.clear();
    _byRosType.clear();
  }

  /// `geometry_msgs/msg/Twist` -> `geometry_msgs/Twist`.
  static String? _shortName(String rosType) {
    final parts = rosType.split('/');
    if (parts.length != 3) return null;
    return '${parts[0]}/${parts[2]}';
  }
}

/// An untyped message: a plain rosbridge JSON map.
///
/// Returned by the dynamic API when a topic's type is discovered at runtime and
/// no generated Dart class exists for it.
@immutable
final class JsonMessage implements RosMessage {
  const JsonMessage(this.rosType, this.data);

  @override
  final String rosType;

  /// The raw decoded message body.
  final Map<String, Object?> data;

  Object? operator [](String key) => data[key];

  @override
  Map<String, Object?> toJson() => data;

  @override
  String toString() => 'JsonMessage($rosType, $data)';
}
