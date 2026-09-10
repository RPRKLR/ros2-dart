import 'package:meta/meta.dart';

import 'message.dart';

/// Terminal status of an action goal, mirroring `action_msgs/msg/GoalStatus`.
enum GoalStatus {
  unknown(0),
  accepted(1),
  executing(2),
  canceling(3),
  succeeded(4),
  canceled(5),
  aborted(6);

  const GoalStatus(this.value);
  final int value;

  bool get isTerminal =>
      this == succeeded || this == canceled || this == aborted;

  static GoalStatus fromValue(int? value) => GoalStatus.values
      .firstWhere((s) => s.value == value, orElse: () => GoalStatus.unknown);
}

/// Converter for a ROS 2 action's goal/feedback/result triple.
///
/// Keyed by the Dart goal type.
@immutable
final class ActionCodec<Goal, Feedback, Result> {
  const ActionCodec({
    required this.actionType,
    required this.encodeGoal,
    required this.decodeFeedback,
    required this.decodeResult,
  });

  /// e.g. `nav2_msgs/action/NavigateToPose`.
  final String actionType;

  final Map<String, Object?> Function(Goal goal) encodeGoal;
  final Feedback Function(Map<String, Object?> json) decodeFeedback;
  final Result Function(Map<String, Object?> json) decodeResult;

  @override
  String toString() => 'ActionCodec<$Goal>($actionType)';
}

/// Registry of action codecs, keyed by Dart goal type.
abstract final class ActionRegistry {
  static final Map<Type, ActionCodec<Object?, Object?, Object?>> _byGoalType =
      {};

  static void register<Goal, Feedback, Result>(
      ActionCodec<Goal, Feedback, Result> codec) {
    _byGoalType[Goal] = codec as ActionCodec<Object?, Object?, Object?>;
  }

  static ActionCodec<Goal, Feedback, Result> of<Goal, Feedback, Result>() {
    final codec = _byGoalType[Goal];
    if (codec == null) {
      throw UnknownMessageTypeError(
          'No action codec registered for goal type `$Goal`.');
    }
    return codec as ActionCodec<Goal, Feedback, Result>;
  }

  @visibleForTesting
  static void reset() => _byGoalType.clear();
}

/// Thrown when an action goal is rejected or ends in a non-success state.
final class ActionFailedException implements Exception {
  ActionFailedException(this.action, this.status, this.message);
  final String action;
  final GoalStatus status;
  final String message;

  @override
  String toString() =>
      'ActionFailedException($action, ${status.name}): $message';
}
