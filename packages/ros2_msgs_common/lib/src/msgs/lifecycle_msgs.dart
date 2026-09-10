// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package lifecycle_msgs

import 'package:ros2_client/codegen_support.dart';

/// Primary state definitions as depicted in:
/// http://design.ros2.org/articles/node_lifecycle.html
///
/// `lifecycle_msgs/msg/State`
final class State implements RosMessage {
  const State({
    this.id = 0,
    this.label = '',
  });

  factory State.fromJson(Map<String, Object?> json) => State(
        id: Field.asInt(json['id']),
        label: Field.asString(json['label']),
      );

  static const int primaryStateUnknown = 0;
  static const int primaryStateUnconfigured = 1;
  static const int primaryStateInactive = 2;
  static const int primaryStateActive = 3;
  static const int primaryStateFinalized = 4;
  static const int transitionStateConfiguring = 10;
  static const int transitionStateCleaningup = 11;
  static const int transitionStateShuttingdown = 12;
  static const int transitionStateActivating = 13;
  static const int transitionStateDeactivating = 14;
  static const int transitionStateErrorprocessing = 15;

  final int id;
  final String label;

  @override
  String get rosType => 'lifecycle_msgs/msg/State';

  @override
  Map<String, Object?> toJson() => {
        'id': id,
        'label': label,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is State && other.id == id && other.label == label);

  @override
  int get hashCode => Object.hashAll([
        id,
        label,
      ]);

  @override
  String toString() => 'State(${toJson()})';
}

/// Default values for transitions as described in:
/// http://design.ros2.org/articles/node_lifecycle.html
///
/// `lifecycle_msgs/msg/Transition`
final class Transition implements RosMessage {
  const Transition({
    this.id = 0,
    this.label = '',
  });

  factory Transition.fromJson(Map<String, Object?> json) => Transition(
        id: Field.asInt(json['id']),
        label: Field.asString(json['label']),
      );

  static const int transitionCreate = 0;
  static const int transitionConfigure = 1;
  static const int transitionCleanup = 2;
  static const int transitionActivate = 3;
  static const int transitionDeactivate = 4;
  static const int transitionUnconfiguredShutdown = 5;
  static const int transitionInactiveShutdown = 6;
  static const int transitionActiveShutdown = 7;
  static const int transitionDestroy = 8;
  static const int transitionOnConfigureSuccess = 10;
  static const int transitionOnConfigureFailure = 11;
  static const int transitionOnConfigureError = 12;
  static const int transitionOnCleanupSuccess = 20;
  static const int transitionOnCleanupFailure = 21;
  static const int transitionOnCleanupError = 22;
  static const int transitionOnActivateSuccess = 30;
  static const int transitionOnActivateFailure = 31;
  static const int transitionOnActivateError = 32;
  static const int transitionOnDeactivateSuccess = 40;
  static const int transitionOnDeactivateFailure = 41;
  static const int transitionOnDeactivateError = 42;
  static const int transitionOnShutdownSuccess = 50;
  static const int transitionOnShutdownFailure = 51;
  static const int transitionOnShutdownError = 52;
  static const int transitionOnErrorSuccess = 60;
  static const int transitionOnErrorFailure = 61;
  static const int transitionOnErrorError = 62;
  static const int transitionCallbackSuccess = 97;
  static const int transitionCallbackFailure = 98;
  static const int transitionCallbackError = 99;

  final int id;
  final String label;

  @override
  String get rosType => 'lifecycle_msgs/msg/Transition';

  @override
  Map<String, Object?> toJson() => {
        'id': id,
        'label': label,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transition && other.id == id && other.label == label);

  @override
  int get hashCode => Object.hashAll([
        id,
        label,
      ]);

  @override
  String toString() => 'Transition(${toJson()})';
}

/// The transition id and label of this description.
///
/// `lifecycle_msgs/msg/TransitionDescription`
final class TransitionDescription implements RosMessage {
  TransitionDescription({
    Transition? transition,
    State? startState,
    State? goalState,
  })  : transition = transition ?? Transition(),
        startState = startState ?? State(),
        goalState = goalState ?? State();

  factory TransitionDescription.fromJson(Map<String, Object?> json) =>
      TransitionDescription(
        transition: Field.asMessage(json['transition'], Transition.fromJson),
        startState: Field.asMessage(json['start_state'], State.fromJson),
        goalState: Field.asMessage(json['goal_state'], State.fromJson),
      );

  final Transition transition;
  final State startState;
  final State goalState;

  @override
  String get rosType => 'lifecycle_msgs/msg/TransitionDescription';

  @override
  Map<String, Object?> toJson() => {
        'transition': transition.toJson(),
        'start_state': startState.toJson(),
        'goal_state': goalState.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransitionDescription &&
          other.transition == transition &&
          other.startState == startState &&
          other.goalState == goalState);

  @override
  int get hashCode => Object.hashAll([
        transition,
        startState,
        goalState,
      ]);

  @override
  String toString() => 'TransitionDescription(${toJson()})';
}

/// The time point at which this event occurred.
///
/// `lifecycle_msgs/msg/TransitionEvent`
final class TransitionEvent implements RosMessage {
  TransitionEvent({
    this.timestamp = 0,
    Transition? transition,
    State? startState,
    State? goalState,
  })  : transition = transition ?? Transition(),
        startState = startState ?? State(),
        goalState = goalState ?? State();

  factory TransitionEvent.fromJson(Map<String, Object?> json) =>
      TransitionEvent(
        timestamp: Field.asInt(json['timestamp']),
        transition: Field.asMessage(json['transition'], Transition.fromJson),
        startState: Field.asMessage(json['start_state'], State.fromJson),
        goalState: Field.asMessage(json['goal_state'], State.fromJson),
      );

  final int timestamp;
  final Transition transition;
  final State startState;
  final State goalState;

  @override
  String get rosType => 'lifecycle_msgs/msg/TransitionEvent';

  @override
  Map<String, Object?> toJson() => {
        'timestamp': timestamp,
        'transition': transition.toJson(),
        'start_state': startState.toJson(),
        'goal_state': goalState.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransitionEvent &&
          other.timestamp == timestamp &&
          other.transition == transition &&
          other.startState == startState &&
          other.goalState == goalState);

  @override
  int get hashCode => Object.hashAll([
        timestamp,
        transition,
        startState,
        goalState,
      ]);

  @override
  String toString() => 'TransitionEvent(${toJson()})';
}

/// The requested transition.
///
/// This change state service will fail if the transition is not possible.
///
/// `lifecycle_msgs/msg/ChangeState_Request`
final class ChangeStateRequest implements RosMessage {
  ChangeStateRequest({
    Transition? transition,
  }) : transition = transition ?? Transition();

  factory ChangeStateRequest.fromJson(Map<String, Object?> json) =>
      ChangeStateRequest(
        transition: Field.asMessage(json['transition'], Transition.fromJson),
      );

  final Transition transition;

  @override
  String get rosType => 'lifecycle_msgs/msg/ChangeState_Request';

  @override
  Map<String, Object?> toJson() => {
        'transition': transition.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeStateRequest && other.transition == transition);

  @override
  int get hashCode => Object.hashAll([
        transition,
      ]);

  @override
  String toString() => 'ChangeStateRequest(${toJson()})';
}

/// Indicates whether the service was able to initiate the state transition
///
/// `lifecycle_msgs/msg/ChangeState_Response`
final class ChangeStateResponse implements RosMessage {
  const ChangeStateResponse({
    this.success = false,
  });

  factory ChangeStateResponse.fromJson(Map<String, Object?> json) =>
      ChangeStateResponse(
        success: Field.asBool(json['success']),
      );

  final bool success;

  @override
  String get rosType => 'lifecycle_msgs/msg/ChangeState_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeStateResponse && other.success == success);

  @override
  int get hashCode => Object.hashAll([
        success,
      ]);

  @override
  String toString() => 'ChangeStateResponse(${toJson()})';
}

/// `lifecycle_msgs/msg/GetAvailableStates_Request`
final class GetAvailableStatesRequest implements RosMessage {
  const GetAvailableStatesRequest();

  factory GetAvailableStatesRequest.fromJson(Map<String, Object?> json) =>
      GetAvailableStatesRequest();

  @override
  String get rosType => 'lifecycle_msgs/msg/GetAvailableStates_Request';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GetAvailableStatesRequest;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'GetAvailableStatesRequest(${toJson()})';
}

/// Array of possible states that can be transitioned to.
///
/// `lifecycle_msgs/msg/GetAvailableStates_Response`
final class GetAvailableStatesResponse implements RosMessage {
  const GetAvailableStatesResponse({
    this.availableStates = const [],
  });

  factory GetAvailableStatesResponse.fromJson(Map<String, Object?> json) =>
      GetAvailableStatesResponse(
        availableStates:
            Field.asList<State>(json['available_states'], State.fromJson),
      );

  final List<State> availableStates;

  @override
  String get rosType => 'lifecycle_msgs/msg/GetAvailableStates_Response';

  @override
  Map<String, Object?> toJson() => {
        'available_states':
            availableStates.map((State e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetAvailableStatesResponse &&
          _listEquals(other.availableStates, availableStates));

  @override
  int get hashCode => Object.hashAll([
        ...availableStates,
      ]);

  @override
  String toString() => 'GetAvailableStatesResponse(${toJson()})';
}

/// `lifecycle_msgs/msg/GetAvailableTransitions_Request`
final class GetAvailableTransitionsRequest implements RosMessage {
  const GetAvailableTransitionsRequest();

  factory GetAvailableTransitionsRequest.fromJson(Map<String, Object?> json) =>
      GetAvailableTransitionsRequest();

  @override
  String get rosType => 'lifecycle_msgs/msg/GetAvailableTransitions_Request';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GetAvailableTransitionsRequest;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'GetAvailableTransitionsRequest(${toJson()})';
}

/// An array of the possible start_state-goal_state transitions
///
/// `lifecycle_msgs/msg/GetAvailableTransitions_Response`
final class GetAvailableTransitionsResponse implements RosMessage {
  const GetAvailableTransitionsResponse({
    this.availableTransitions = const [],
  });

  factory GetAvailableTransitionsResponse.fromJson(Map<String, Object?> json) =>
      GetAvailableTransitionsResponse(
        availableTransitions: Field.asList<TransitionDescription>(
            json['available_transitions'], TransitionDescription.fromJson),
      );

  final List<TransitionDescription> availableTransitions;

  @override
  String get rosType => 'lifecycle_msgs/msg/GetAvailableTransitions_Response';

  @override
  Map<String, Object?> toJson() => {
        'available_transitions': availableTransitions
            .map((TransitionDescription e) => e.toJson())
            .toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetAvailableTransitionsResponse &&
          _listEquals(other.availableTransitions, availableTransitions));

  @override
  int get hashCode => Object.hashAll([
        ...availableTransitions,
      ]);

  @override
  String toString() => 'GetAvailableTransitionsResponse(${toJson()})';
}

/// `lifecycle_msgs/msg/GetState_Request`
final class GetStateRequest implements RosMessage {
  const GetStateRequest();

  factory GetStateRequest.fromJson(Map<String, Object?> json) =>
      GetStateRequest();

  @override
  String get rosType => 'lifecycle_msgs/msg/GetState_Request';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GetStateRequest;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'GetStateRequest(${toJson()})';
}

/// The current state-machine state of the node.
///
/// `lifecycle_msgs/msg/GetState_Response`
final class GetStateResponse implements RosMessage {
  GetStateResponse({
    State? currentState,
  }) : currentState = currentState ?? State();

  factory GetStateResponse.fromJson(Map<String, Object?> json) =>
      GetStateResponse(
        currentState: Field.asMessage(json['current_state'], State.fromJson),
      );

  final State currentState;

  @override
  String get rosType => 'lifecycle_msgs/msg/GetState_Response';

  @override
  Map<String, Object?> toJson() => {
        'current_state': currentState.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetStateResponse && other.currentState == currentState);

  @override
  int get hashCode => Object.hashAll([
        currentState,
      ]);

  @override
  String toString() => 'GetStateResponse(${toJson()})';
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

/// Registers every message in `lifecycle_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerLifecycleMsgs() {
  MessageRegistry.register(const MessageCodec<State>(
    rosType: 'lifecycle_msgs/msg/State',
    fromJson: State.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Transition>(
    rosType: 'lifecycle_msgs/msg/Transition',
    fromJson: Transition.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<TransitionDescription>(
    rosType: 'lifecycle_msgs/msg/TransitionDescription',
    fromJson: TransitionDescription.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<TransitionEvent>(
    rosType: 'lifecycle_msgs/msg/TransitionEvent',
    fromJson: TransitionEvent.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ChangeStateRequest>(
    rosType: 'lifecycle_msgs/msg/ChangeState_Request',
    fromJson: ChangeStateRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ChangeStateResponse>(
    rosType: 'lifecycle_msgs/msg/ChangeState_Response',
    fromJson: ChangeStateResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetAvailableStatesRequest>(
    rosType: 'lifecycle_msgs/msg/GetAvailableStates_Request',
    fromJson: GetAvailableStatesRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetAvailableStatesResponse>(
    rosType: 'lifecycle_msgs/msg/GetAvailableStates_Response',
    fromJson: GetAvailableStatesResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetAvailableTransitionsRequest>(
    rosType: 'lifecycle_msgs/msg/GetAvailableTransitions_Request',
    fromJson: GetAvailableTransitionsRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetAvailableTransitionsResponse>(
    rosType: 'lifecycle_msgs/msg/GetAvailableTransitions_Response',
    fromJson: GetAvailableTransitionsResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetStateRequest>(
    rosType: 'lifecycle_msgs/msg/GetState_Request',
    fromJson: GetStateRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetStateResponse>(
    rosType: 'lifecycle_msgs/msg/GetState_Response',
    fromJson: GetStateResponse.fromJson,
    toJson: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<ChangeStateRequest, ChangeStateResponse>(
    serviceType: 'lifecycle_msgs/srv/ChangeState',
    encodeRequest: _toJson,
    decodeResponse: ChangeStateResponse.fromJson,
    decodeRequest: ChangeStateRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<GetAvailableStatesRequest, GetAvailableStatesResponse>(
    serviceType: 'lifecycle_msgs/srv/GetAvailableStates',
    encodeRequest: _toJson,
    decodeResponse: GetAvailableStatesResponse.fromJson,
    decodeRequest: GetAvailableStatesRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<GetAvailableTransitionsRequest,
      GetAvailableTransitionsResponse>(
    serviceType: 'lifecycle_msgs/srv/GetAvailableTransitions',
    encodeRequest: _toJson,
    decodeResponse: GetAvailableTransitionsResponse.fromJson,
    decodeRequest: GetAvailableTransitionsRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<GetStateRequest, GetStateResponse>(
    serviceType: 'lifecycle_msgs/srv/GetState',
    encodeRequest: _toJson,
    decodeResponse: GetStateResponse.fromJson,
    decodeRequest: GetStateRequest.fromJson,
    encodeResponse: _toJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
