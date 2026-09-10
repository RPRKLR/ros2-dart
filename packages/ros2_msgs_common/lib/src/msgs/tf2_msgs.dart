// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package tf2_msgs

import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;

/// `tf2_msgs/msg/TF2Error`
final class TF2Error implements RosMessage {
  const TF2Error({
    this.error = 0,
    this.errorString = '',
  });

  factory TF2Error.fromJson(Map<String, Object?> json) => TF2Error(
        error: Field.asInt(json['error']),
        errorString: Field.asString(json['error_string']),
      );

  static const int noError = 0;
  static const int lookupError = 1;
  static const int connectivityError = 2;
  static const int extrapolationError = 3;
  static const int invalidArgumentError = 4;
  static const int timeoutError = 5;
  static const int transformError = 6;

  final int error;
  final String errorString;

  @override
  String get rosType => 'tf2_msgs/msg/TF2Error';

  @override
  Map<String, Object?> toJson() => {
        'error': error,
        'error_string': errorString,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TF2Error &&
          other.error == error &&
          other.errorString == errorString);

  @override
  int get hashCode => Object.hashAll([
        error,
        errorString,
      ]);

  @override
  String toString() => 'TF2Error(${toJson()})';
}

/// `tf2_msgs/msg/FrameGraph_Request`
final class FrameGraphRequest implements RosMessage {
  const FrameGraphRequest();

  factory FrameGraphRequest.fromJson(Map<String, Object?> json) =>
      FrameGraphRequest();

  @override
  String get rosType => 'tf2_msgs/msg/FrameGraph_Request';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FrameGraphRequest;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'FrameGraphRequest(${toJson()})';
}

/// `tf2_msgs/msg/FrameGraph_Response`
final class FrameGraphResponse implements RosMessage {
  const FrameGraphResponse({
    this.frameYaml = '',
  });

  factory FrameGraphResponse.fromJson(Map<String, Object?> json) =>
      FrameGraphResponse(
        frameYaml: Field.asString(json['frame_yaml']),
      );

  final String frameYaml;

  @override
  String get rosType => 'tf2_msgs/msg/FrameGraph_Response';

  @override
  Map<String, Object?> toJson() => {
        'frame_yaml': frameYaml,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FrameGraphResponse && other.frameYaml == frameYaml);

  @override
  int get hashCode => Object.hashAll([
        frameYaml,
      ]);

  @override
  String toString() => 'FrameGraphResponse(${toJson()})';
}

/// Simple API
///
/// `tf2_msgs/msg/LookupTransform_Goal`
final class LookupTransformGoal implements RosMessage {
  LookupTransformGoal({
    this.targetFrame = '',
    this.sourceFrame = '',
    ros2.RosTime? sourceTime,
    ros2.RosDuration? timeout,
    ros2.RosTime? targetTime,
    this.fixedFrame = '',
    this.advanced = false,
  })  : sourceTime = sourceTime ?? ros2.RosTime(),
        timeout = timeout ?? ros2.RosDuration(),
        targetTime = targetTime ?? ros2.RosTime();

  factory LookupTransformGoal.fromJson(Map<String, Object?> json) =>
      LookupTransformGoal(
        targetFrame: Field.asString(json['target_frame']),
        sourceFrame: Field.asString(json['source_frame']),
        sourceTime: Field.asMessage(json['source_time'], ros2.RosTime.fromJson),
        timeout: Field.asMessage(json['timeout'], ros2.RosDuration.fromJson),
        targetTime: Field.asMessage(json['target_time'], ros2.RosTime.fromJson),
        fixedFrame: Field.asString(json['fixed_frame']),
        advanced: Field.asBool(json['advanced']),
      );

  final String targetFrame;
  final String sourceFrame;
  final ros2.RosTime sourceTime;
  final ros2.RosDuration timeout;
  final ros2.RosTime targetTime;
  final String fixedFrame;
  final bool advanced;

  @override
  String get rosType => 'tf2_msgs/msg/LookupTransform_Goal';

  @override
  Map<String, Object?> toJson() => {
        'target_frame': targetFrame,
        'source_frame': sourceFrame,
        'source_time': sourceTime.toJson(),
        'timeout': timeout.toJson(),
        'target_time': targetTime.toJson(),
        'fixed_frame': fixedFrame,
        'advanced': advanced,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LookupTransformGoal &&
          other.targetFrame == targetFrame &&
          other.sourceFrame == sourceFrame &&
          other.sourceTime == sourceTime &&
          other.timeout == timeout &&
          other.targetTime == targetTime &&
          other.fixedFrame == fixedFrame &&
          other.advanced == advanced);

  @override
  int get hashCode => Object.hashAll([
        targetFrame,
        sourceFrame,
        sourceTime,
        timeout,
        targetTime,
        fixedFrame,
        advanced,
      ]);

  @override
  String toString() => 'LookupTransformGoal(${toJson()})';
}

/// `tf2_msgs/msg/LookupTransform_Result`
final class LookupTransformResult implements RosMessage {
  LookupTransformResult({
    ros2.RosTransformStamped? transform,
    TF2Error? error,
  })  : transform = transform ?? ros2.RosTransformStamped(),
        error = error ?? TF2Error();

  factory LookupTransformResult.fromJson(Map<String, Object?> json) =>
      LookupTransformResult(
        transform: Field.asMessage(
            json['transform'], ros2.RosTransformStamped.fromJson),
        error: Field.asMessage(json['error'], TF2Error.fromJson),
      );

  final ros2.RosTransformStamped transform;
  final TF2Error error;

  @override
  String get rosType => 'tf2_msgs/msg/LookupTransform_Result';

  @override
  Map<String, Object?> toJson() => {
        'transform': transform.toJson(),
        'error': error.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LookupTransformResult &&
          other.transform == transform &&
          other.error == error);

  @override
  int get hashCode => Object.hashAll([
        transform,
        error,
      ]);

  @override
  String toString() => 'LookupTransformResult(${toJson()})';
}

/// `tf2_msgs/msg/LookupTransform_Feedback`
final class LookupTransformFeedback implements RosMessage {
  const LookupTransformFeedback();

  factory LookupTransformFeedback.fromJson(Map<String, Object?> json) =>
      LookupTransformFeedback();

  @override
  String get rosType => 'tf2_msgs/msg/LookupTransform_Feedback';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LookupTransformFeedback;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'LookupTransformFeedback(${toJson()})';
}

/// Registers every message in `tf2_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerTf2Msgs() {
  MessageRegistry.register(const MessageCodec<TF2Error>(
    rosType: 'tf2_msgs/msg/TF2Error',
    fromJson: TF2Error.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FrameGraphRequest>(
    rosType: 'tf2_msgs/msg/FrameGraph_Request',
    fromJson: FrameGraphRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FrameGraphResponse>(
    rosType: 'tf2_msgs/msg/FrameGraph_Response',
    fromJson: FrameGraphResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<LookupTransformGoal>(
    rosType: 'tf2_msgs/msg/LookupTransform_Goal',
    fromJson: LookupTransformGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<LookupTransformResult>(
    rosType: 'tf2_msgs/msg/LookupTransform_Result',
    fromJson: LookupTransformResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<LookupTransformFeedback>(
    rosType: 'tf2_msgs/msg/LookupTransform_Feedback',
    fromJson: LookupTransformFeedback.fromJson,
    toJson: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<FrameGraphRequest, FrameGraphResponse>(
    serviceType: 'tf2_msgs/srv/FrameGraph',
    encodeRequest: _toJson,
    decodeResponse: FrameGraphResponse.fromJson,
    decodeRequest: FrameGraphRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ActionRegistry.register(const ActionCodec<LookupTransformGoal,
      LookupTransformFeedback, LookupTransformResult>(
    actionType: 'tf2_msgs/action/LookupTransform',
    encodeGoal: _toJson,
    decodeFeedback: LookupTransformFeedback.fromJson,
    decodeResult: LookupTransformResult.fromJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
