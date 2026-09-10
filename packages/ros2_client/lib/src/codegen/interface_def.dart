/// Parsed representation of a ROS 2 interface definition.
library;

import 'package:meta/meta.dart';

/// How an array field is bounded.
enum ArrayKind {
  /// Not an array.
  none,

  /// `T[]` — any length.
  unbounded,

  /// `T[N]` — exactly N elements.
  fixed,

  /// `T[<=N]` — at most N elements.
  bounded,
}

/// A single field in a message.
@immutable
final class FieldDef {
  const FieldDef({
    required this.type,
    required this.name,
    this.arrayKind = ArrayKind.none,
    this.arraySize,
    this.defaultValue,
    this.stringBound,
    this.comment,
  });

  /// The ROS type, e.g. `float64`, `string`, `geometry_msgs/Pose`.
  final String type;

  /// The field name as written, in snake_case.
  final String name;

  final ArrayKind arrayKind;

  /// Element count for [ArrayKind.fixed] and [ArrayKind.bounded].
  final int? arraySize;

  /// Raw default value text, if the definition supplied one.
  final String? defaultValue;

  /// Upper bound from `string<=N`.
  final int? stringBound;

  /// Trailing `#` comment, used as the generated doc comment.
  final String? comment;

  bool get isArray => arrayKind != ArrayKind.none;

  @override
  String toString() =>
      'FieldDef($type${isArray ? '[]' : ''} $name${defaultValue == null ? '' : ' = $defaultValue'})';
}

/// A `TYPE NAME=value` constant.
@immutable
final class ConstantDef {
  const ConstantDef({
    required this.type,
    required this.name,
    required this.value,
    this.comment,
  });

  final String type;
  final String name;
  final String value;
  final String? comment;

  @override
  String toString() => 'ConstantDef($type $name = $value)';
}

/// One message body: its fields and constants.
@immutable
final class MessageDef {
  const MessageDef({
    required this.package,
    required this.name,
    required this.fields,
    required this.constants,
    this.docComment,
  });

  /// e.g. `sensor_msgs`.
  final String package;

  /// e.g. `LaserScan`, or `NavigateToPose_Goal` for an action part.
  final String name;

  final List<FieldDef> fields;
  final List<ConstantDef> constants;

  /// Leading `#` block from the top of the file.
  final String? docComment;

  /// Fully qualified ROS type name, e.g. `sensor_msgs/msg/LaserScan`.
  String get rosType => '$package/msg/$name';

  @override
  String toString() =>
      'MessageDef($rosType, ${fields.length} fields, ${constants.length} constants)';
}

/// A service: a request and a response message.
@immutable
final class ServiceDef {
  const ServiceDef({
    required this.package,
    required this.name,
    required this.request,
    required this.response,
  });

  final String package;
  final String name;
  final MessageDef request;
  final MessageDef response;

  String get rosType => '$package/srv/$name';

  @override
  String toString() => 'ServiceDef($rosType)';
}

/// An action: goal, result and feedback messages.
@immutable
final class ActionDef {
  const ActionDef({
    required this.package,
    required this.name,
    required this.goal,
    required this.result,
    required this.feedback,
  });

  final String package;
  final String name;
  final MessageDef goal;
  final MessageDef result;
  final MessageDef feedback;

  String get rosType => '$package/action/$name';

  @override
  String toString() => 'ActionDef($rosType)';
}
