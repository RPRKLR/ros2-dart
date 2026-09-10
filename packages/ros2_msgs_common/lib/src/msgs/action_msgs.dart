// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package action_msgs

import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;
import 'unique_identifier_msgs.dart';

/// Goal ID
///
/// `action_msgs/msg/GoalInfo`
final class GoalInfo implements RosMessage {
  GoalInfo({
    UUID? goalId,
    ros2.RosTime? stamp,
  })  : goalId = goalId ?? UUID(),
        stamp = stamp ?? ros2.RosTime();

  factory GoalInfo.fromJson(Map<String, Object?> json) => GoalInfo(
        goalId: Field.asMessage(json['goal_id'], UUID.fromJson),
        stamp: Field.asMessage(json['stamp'], ros2.RosTime.fromJson),
      );

  final UUID goalId;
  final ros2.RosTime stamp;

  @override
  String get rosType => 'action_msgs/msg/GoalInfo';

  @override
  Map<String, Object?> toJson() => {
        'goal_id': goalId.toJson(),
        'stamp': stamp.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalInfo && other.goalId == goalId && other.stamp == stamp);

  @override
  int get hashCode => Object.hashAll([
        goalId,
        stamp,
      ]);

  @override
  String toString() => 'GoalInfo(${toJson()})';
}

/// An action goal can be in one of these states after it is accepted by an action
/// server.
///
/// For more information, see http://design.ros2.org/articles/actions.html
///
/// `action_msgs/msg/GoalStatus`
final class GoalStatus implements RosMessage {
  GoalStatus({
    GoalInfo? goalInfo,
    this.status = 0,
  }) : goalInfo = goalInfo ?? GoalInfo();

  factory GoalStatus.fromJson(Map<String, Object?> json) => GoalStatus(
        goalInfo: Field.asMessage(json['goal_info'], GoalInfo.fromJson),
        status: Field.asInt(json['status']),
      );

  static const int statusUnknown = 0;
  static const int statusAccepted = 1;
  static const int statusExecuting = 2;
  static const int statusCanceling = 3;
  static const int statusSucceeded = 4;
  static const int statusCanceled = 5;
  static const int statusAborted = 6;

  final GoalInfo goalInfo;
  final int status;

  @override
  String get rosType => 'action_msgs/msg/GoalStatus';

  @override
  Map<String, Object?> toJson() => {
        'goal_info': goalInfo.toJson(),
        'status': status,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalStatus &&
          other.goalInfo == goalInfo &&
          other.status == status);

  @override
  int get hashCode => Object.hashAll([
        goalInfo,
        status,
      ]);

  @override
  String toString() => 'GoalStatus(${toJson()})';
}

/// An array of goal statuses.
///
/// `action_msgs/msg/GoalStatusArray`
final class GoalStatusArray implements RosMessage {
  const GoalStatusArray({
    this.statusList = const [],
  });

  factory GoalStatusArray.fromJson(Map<String, Object?> json) =>
      GoalStatusArray(
        statusList:
            Field.asList<GoalStatus>(json['status_list'], GoalStatus.fromJson),
      );

  final List<GoalStatus> statusList;

  @override
  String get rosType => 'action_msgs/msg/GoalStatusArray';

  @override
  Map<String, Object?> toJson() => {
        'status_list': statusList.map((GoalStatus e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalStatusArray && _listEquals(other.statusList, statusList));

  @override
  int get hashCode => Object.hashAll([
        ...statusList,
      ]);

  @override
  String toString() => 'GoalStatusArray(${toJson()})';
}

/// Cancel one or more goals with the following policy:
///
/// - If the goal ID is zero and timestamp is zero, cancel all goals.
/// - If the goal ID is zero and timestamp is not zero, cancel all goals accepted
/// at or before the timestamp.
/// - If the goal ID is not zero and timestamp is zero, cancel the goal with the
/// given ID regardless of the time it was accepted.
/// - If the goal ID is not zero and timestamp is not zero, cancel the goal with
/// the given ID and all goals accepted at or before the timestamp.
///
/// `action_msgs/msg/CancelGoal_Request`
final class CancelGoalRequest implements RosMessage {
  CancelGoalRequest({
    GoalInfo? goalInfo,
  }) : goalInfo = goalInfo ?? GoalInfo();

  factory CancelGoalRequest.fromJson(Map<String, Object?> json) =>
      CancelGoalRequest(
        goalInfo: Field.asMessage(json['goal_info'], GoalInfo.fromJson),
      );

  final GoalInfo goalInfo;

  @override
  String get rosType => 'action_msgs/msg/CancelGoal_Request';

  @override
  Map<String, Object?> toJson() => {
        'goal_info': goalInfo.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CancelGoalRequest && other.goalInfo == goalInfo);

  @override
  int get hashCode => Object.hashAll([
        goalInfo,
      ]);

  @override
  String toString() => 'CancelGoalRequest(${toJson()})';
}

/// #
/// # Return codes.
/// #
///
/// `action_msgs/msg/CancelGoal_Response`
final class CancelGoalResponse implements RosMessage {
  const CancelGoalResponse({
    this.returnCode = 0,
    this.goalsCanceling = const [],
  });

  factory CancelGoalResponse.fromJson(Map<String, Object?> json) =>
      CancelGoalResponse(
        returnCode: Field.asInt(json['return_code']),
        goalsCanceling:
            Field.asList<GoalInfo>(json['goals_canceling'], GoalInfo.fromJson),
      );

  static const int errorNone = 0;
  static const int errorRejected = 1;
  static const int errorUnknownGoalId = 2;
  static const int errorGoalTerminated = 3;

  final int returnCode;
  final List<GoalInfo> goalsCanceling;

  @override
  String get rosType => 'action_msgs/msg/CancelGoal_Response';

  @override
  Map<String, Object?> toJson() => {
        'return_code': returnCode,
        'goals_canceling':
            goalsCanceling.map((GoalInfo e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CancelGoalResponse &&
          other.returnCode == returnCode &&
          _listEquals(other.goalsCanceling, goalsCanceling));

  @override
  int get hashCode => Object.hashAll([
        returnCode,
        ...goalsCanceling,
      ]);

  @override
  String toString() => 'CancelGoalResponse(${toJson()})';
}

/// Element-wise list comparison used by generated `==`.
bool _listEquals(List<Object?> a, List<Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Registers every message in `action_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerActionMsgs() {
  MessageRegistry.register(const MessageCodec<GoalInfo>(
    rosType: 'action_msgs/msg/GoalInfo',
    fromJson: GoalInfo.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GoalStatus>(
    rosType: 'action_msgs/msg/GoalStatus',
    fromJson: GoalStatus.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GoalStatusArray>(
    rosType: 'action_msgs/msg/GoalStatusArray',
    fromJson: GoalStatusArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<CancelGoalRequest>(
    rosType: 'action_msgs/msg/CancelGoal_Request',
    fromJson: CancelGoalRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<CancelGoalResponse>(
    rosType: 'action_msgs/msg/CancelGoal_Response',
    fromJson: CancelGoalResponse.fromJson,
    toJson: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<CancelGoalRequest, CancelGoalResponse>(
    serviceType: 'action_msgs/srv/CancelGoal',
    encodeRequest: _toJson,
    decodeResponse: CancelGoalResponse.fromJson,
    decodeRequest: CancelGoalRequest.fromJson,
    encodeResponse: _toJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
