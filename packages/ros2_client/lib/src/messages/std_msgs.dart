import 'package:meta/meta.dart';

import 'conversions.dart';
import 'message.dart';

/// `builtin_interfaces/msg/Time`.
@immutable
final class RosTime implements RosMessage {
  const RosTime({this.sec = 0, this.nanosec = 0});

  factory RosTime.fromJson(Map<String, Object?> json) => RosTime(
        sec: Field.asInt(json['sec']),
        nanosec: Field.asInt(json['nanosec']),
      );

  factory RosTime.fromDateTime(DateTime t) => RosTime(
        sec: t.millisecondsSinceEpoch ~/ 1000,
        nanosec: (t.microsecondsSinceEpoch % 1000000) * 1000,
      );

  final int sec;
  final int nanosec;

  DateTime toDateTime() =>
      DateTime.fromMicrosecondsSinceEpoch(sec * 1000000 + nanosec ~/ 1000);

  Duration get sinceEpoch =>
      Duration(seconds: sec, microseconds: nanosec ~/ 1000);

  @override
  String get rosType => 'builtin_interfaces/msg/Time';

  @override
  Map<String, Object?> toJson() => {'sec': sec, 'nanosec': nanosec};

  @override
  bool operator ==(Object other) =>
      other is RosTime && other.sec == sec && other.nanosec == nanosec;

  @override
  int get hashCode => Object.hash(sec, nanosec);

  @override
  String toString() => 'RosTime($sec.${nanosec.toString().padLeft(9, '0')})';
}

/// `builtin_interfaces/msg/Duration`.
@immutable
final class RosDuration implements RosMessage {
  const RosDuration({this.sec = 0, this.nanosec = 0});

  factory RosDuration.fromJson(Map<String, Object?> json) => RosDuration(
        sec: Field.asInt(json['sec']),
        nanosec: Field.asInt(json['nanosec']),
      );

  factory RosDuration.fromDart(Duration d) => RosDuration(
        sec: d.inSeconds,
        nanosec: (d.inMicroseconds % 1000000) * 1000,
      );

  final int sec;
  final int nanosec;

  Duration toDart() => Duration(seconds: sec, microseconds: nanosec ~/ 1000);

  @override
  String get rosType => 'builtin_interfaces/msg/Duration';

  @override
  Map<String, Object?> toJson() => {'sec': sec, 'nanosec': nanosec};

  @override
  bool operator ==(Object other) =>
      other is RosDuration && other.sec == sec && other.nanosec == nanosec;

  @override
  int get hashCode => Object.hash(sec, nanosec);
}

/// `std_msgs/msg/Header`.
@immutable
final class Header implements RosMessage {
  const Header({this.stamp = const RosTime(), this.frameId = ''});

  factory Header.fromJson(Map<String, Object?> json) => Header(
        stamp: Field.asMessage(json['stamp'], RosTime.fromJson),
        frameId: Field.asString(json['frame_id']),
      );

  final RosTime stamp;
  final String frameId;

  @override
  String get rosType => 'std_msgs/msg/Header';

  @override
  Map<String, Object?> toJson() =>
      {'stamp': stamp.toJson(), 'frame_id': frameId};

  @override
  bool operator ==(Object other) =>
      other is Header && other.stamp == stamp && other.frameId == frameId;

  @override
  int get hashCode => Object.hash(stamp, frameId);

  @override
  String toString() => 'Header($frameId, $stamp)';
}

/// `std_msgs/msg/String`.
@immutable
final class StringMsg implements RosMessage {
  const StringMsg([this.data = '']);

  factory StringMsg.fromJson(Map<String, Object?> json) =>
      StringMsg(Field.asString(json['data']));

  final String data;

  @override
  String get rosType => 'std_msgs/msg/String';

  @override
  Map<String, Object?> toJson() => {'data': data};

  @override
  bool operator ==(Object other) => other is StringMsg && other.data == data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'StringMsg($data)';
}

/// `std_msgs/msg/Bool`.
@immutable
final class BoolMsg implements RosMessage {
  const BoolMsg([this.data = false]);
  factory BoolMsg.fromJson(Map<String, Object?> json) =>
      BoolMsg(Field.asBool(json['data']));
  final bool data;
  @override
  String get rosType => 'std_msgs/msg/Bool';
  @override
  Map<String, Object?> toJson() => {'data': data};
  @override
  bool operator ==(Object other) => other is BoolMsg && other.data == data;
  @override
  int get hashCode => data.hashCode;
}

/// `std_msgs/msg/Int32`.
@immutable
final class Int32Msg implements RosMessage {
  const Int32Msg([this.data = 0]);
  factory Int32Msg.fromJson(Map<String, Object?> json) =>
      Int32Msg(Field.asInt(json['data']));
  final int data;
  @override
  String get rosType => 'std_msgs/msg/Int32';
  @override
  Map<String, Object?> toJson() => {'data': data};
  @override
  bool operator ==(Object other) => other is Int32Msg && other.data == data;
  @override
  int get hashCode => data.hashCode;
}

/// `std_msgs/msg/Float64`.
@immutable
final class Float64Msg implements RosMessage {
  const Float64Msg([this.data = 0]);
  factory Float64Msg.fromJson(Map<String, Object?> json) =>
      Float64Msg(Field.asDouble(json['data']));
  final double data;
  @override
  String get rosType => 'std_msgs/msg/Float64';
  @override
  Map<String, Object?> toJson() => {'data': data};
  @override
  bool operator ==(Object other) => other is Float64Msg && other.data == data;
  @override
  int get hashCode => data.hashCode;
}

/// `std_msgs/msg/Empty`.
@immutable
final class EmptyMsg implements RosMessage {
  const EmptyMsg();
  factory EmptyMsg.fromJson(Map<String, Object?> _) => const EmptyMsg();
  @override
  String get rosType => 'std_msgs/msg/Empty';
  @override
  Map<String, Object?> toJson() => const {};
  @override
  bool operator ==(Object other) => other is EmptyMsg;
  @override
  int get hashCode => 0;
}

/// `std_msgs/msg/ColorRGBA`.
@immutable
final class ColorRGBA implements RosMessage {
  const ColorRGBA({this.r = 0, this.g = 0, this.b = 0, this.a = 1});
  factory ColorRGBA.fromJson(Map<String, Object?> json) => ColorRGBA(
        r: Field.asDouble(json['r']),
        g: Field.asDouble(json['g']),
        b: Field.asDouble(json['b']),
        a: Field.asDouble(json['a']),
      );
  final double r, g, b, a;
  @override
  String get rosType => 'std_msgs/msg/ColorRGBA';
  @override
  Map<String, Object?> toJson() => {'r': r, 'g': g, 'b': b, 'a': a};
  @override
  bool operator ==(Object other) =>
      other is ColorRGBA &&
      other.r == r &&
      other.g == g &&
      other.b == b &&
      other.a == a;
  @override
  int get hashCode => Object.hash(r, g, b, a);
}

/// Registers every `std_msgs` / `builtin_interfaces` codec.
///
/// Called automatically by [registerStandardMessages].
void registerStdMsgs() {
  MessageRegistry.register(const MessageCodec<RosTime>(
      rosType: 'builtin_interfaces/msg/Time',
      fromJson: RosTime.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<RosDuration>(
      rosType: 'builtin_interfaces/msg/Duration',
      fromJson: RosDuration.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<Header>(
      rosType: 'std_msgs/msg/Header',
      fromJson: Header.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<StringMsg>(
      rosType: 'std_msgs/msg/String',
      fromJson: StringMsg.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<BoolMsg>(
      rosType: 'std_msgs/msg/Bool',
      fromJson: BoolMsg.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<Int32Msg>(
      rosType: 'std_msgs/msg/Int32',
      fromJson: Int32Msg.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<Float64Msg>(
      rosType: 'std_msgs/msg/Float64',
      fromJson: Float64Msg.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<EmptyMsg>(
      rosType: 'std_msgs/msg/Empty',
      fromJson: EmptyMsg.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<ColorRGBA>(
      rosType: 'std_msgs/msg/ColorRGBA',
      fromJson: ColorRGBA.fromJson,
      toJson: _toJson));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
