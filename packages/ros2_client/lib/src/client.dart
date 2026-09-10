import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import 'encoding/wire_codec.dart';
import 'messages/action.dart';
import 'messages/message.dart';
import 'messages/service.dart';
import 'protocol/backpressure.dart';
import 'protocol/opcodes.dart';
import 'protocol/qos.dart';
import 'transport/transport.dart';
import 'transport/websocket_transport.dart';

/// A diagnostic message emitted by the rosbridge server.
@immutable
final class RosStatus {
  const RosStatus(this.level, this.message, {this.id});
  final StatusLevel level;
  final String message;
  final String? id;

  @override
  String toString() => '[${level.name}] $message';
}

/// A handle to an in-flight action goal.
final class GoalHandle<Feedback, Result> {
  GoalHandle._(
      this._client, this.actionName, this.goalId, this._feedback, this._result);

  final Ros2Client _client;
  final String actionName;

  /// The rosbridge id correlating every message for this goal.
  final String goalId;

  final StreamController<Feedback> _feedback;
  final Completer<Result> _result;
  Timer? _timeoutTimer;

  /// Feedback published while the goal runs. Closes when the goal finishes.
  Stream<Feedback> get feedback => _feedback.stream;

  /// Completes with the result, or throws [ActionFailedException] if the goal
  /// was aborted, rejected or cancelled.
  Future<Result> get result => _result.future;

  bool get isDone => _result.isCompleted;

  /// Requests cancellation. The goal is not cancelled until the server agrees;
  /// await [result] and catch [ActionFailedException] to observe the outcome.
  void cancel() {
    if (isDone) return;
    _timeoutTimer?.cancel();
    _client._send({
      'op': Op.cancelActionGoal,
      'id': goalId,
      'action': actionName,
    });
  }
}

/// A typed publisher bound to one topic.
final class RosPublisher<T> {
  RosPublisher._(this._client, this.topic, this._codec, this._qos, this._latch,
      this._perishable);

  final Ros2Client _client;
  final String topic;
  final MessageCodec<T> _codec;
  final QosProfile _qos;
  final bool _latch;

  /// Whether a message sent while offline is dropped rather than queued.
  final bool _perishable;
  bool _closed = false;

  String get rosType => _codec.rosType;

  /// Publishes [message].
  ///
  /// Buffered while reconnecting and replayed on the next connect, unless the
  /// publisher was advertised with `perishable: true`, in which case a message
  /// sent while offline is dropped.
  void publish(T message) {
    if (_closed) {
      throw StateError('Publisher for $topic is closed.');
    }
    _client._send(
      {
        'op': Op.publish,
        'topic': topic,
        'msg': _codec.toJson(message),
        if (_latch) 'latch': true,
        'qos': _qos.toWire(),
      },
      perishable: _perishable,
    );
  }

  /// Unadvertises the topic.
  void close() {
    if (_closed) return;
    _closed = true;
    _client._unadvertise(topic);
  }
}

/// A ROS 2 client speaking the rosbridge v2 protocol.
///
/// ```dart
/// final ros = Ros2Client(Uri.parse('ws://192.168.1.10:9090'));
/// await ros.connect();
///
/// ros.subscribe<LaserScan>('/scan', qos: QosProfile.sensorData)
///    .listen((scan) => print(scan.ranges.length));
///
/// final cmd = ros.advertise<Twist>('/cmd_vel');
/// cmd.publish(Twist(linear: Vector3(x: 0.2)));
/// ```
final class Ros2Client {
  Ros2Client(
    this.uri, {
    this.reconnectPolicy = const ReconnectPolicy(),
    this.defaultCompression = Compression.cbor,
    this.statusLevel = StatusLevel.warning,
    this.sendSetLevel = false,
    RosTransport Function(Uri uri)? transportFactory,
  }) : _transportFactory = transportFactory ?? WebSocketTransport.new;

  final Uri uri;
  final ReconnectPolicy reconnectPolicy;

  /// Wire encoding used for subscriptions that do not override it.
  ///
  /// Defaults to [Compression.cbor], which is a correctness choice as much as
  /// a performance one: rosbridge serialises every non-finite float as JSON
  /// `null`, so over [Compression.none] an out-of-range lidar reading (`inf`)
  /// and an invalid one (`nan`) both arrive as `NaN` and become
  /// indistinguishable. CBOR round-trips them exactly, and measures ~26%
  /// smaller on the wire because it does not base64-encode `uint8[]`.
  ///
  /// Set [Compression.none] if you need to read frames in a WebSocket
  /// inspector, or are talking to a bridge without CBOR support.
  final Compression defaultCompression;

  /// Minimum severity of server [status] messages to forward.
  /// Requested verbosity for `set_level`, if [sendSetLevel] is on.
  final StatusLevel statusLevel;

  /// Whether to send the `set_level` op on connect.
  ///
  /// Off by default, because **rosbridge does not implement it**. There is no
  /// `set_level` capability in `rosbridge_protocol.py`, so a real bridge
  /// answers with `Unknown operation: set_level` on the robot's own console,
  /// once per connect. Some forks and older bridges do support it; turn this
  /// on for those.
  final bool sendSetLevel;

  final RosTransport Function(Uri uri) _transportFactory;

  RosTransport? _transport;
  StreamSubscription<Object>? _incomingSub;

  final _stateController = StreamController<RosConnectionState>.broadcast();
  RosConnectionState _state = RosConnectionState.disconnected;

  final _statusController = StreamController<RosStatus>.broadcast();

  var _idCounter = 0;
  int _reconnectAttempt = 0;
  Timer? _reconnectTimer;
  DateTime? _connectedAt;
  Completer<void>? _connecting;

  /// Live subscriptions, keyed by topic. A topic may have several listeners.
  final Map<String, List<_Listener<Object?>>> _listeners = {};

  /// Advertised topics and their ref counts.
  final Map<String, _AdvertisedTopic> _advertised = {};

  final Map<String, Completer<Map<String, Object?>>> _pendingCalls = {};
  final Map<String, _ActiveGoal> _activeGoals = {};
  final Map<String, _FragmentBuffer> _fragments = {};

  /// Commands queued while disconnected, replayed on reconnect.
  final List<Map<String, Object?>> _outbox = [];

  /// Commands buffered while offline, for tests that assert what survives an
  /// outage and in what order.
  @visibleForTesting
  List<Map<String, Object?>> get debugOutbox => List.unmodifiable(_outbox);

  /// Maximum number of commands buffered while offline.
  static const int maxOutbox = 256;

  /// Set once, so an interleaved fragment stream warns rather than spams.
  bool _warnedFragmentCollision = false;

  /// Set once per outage, so a full buffer warns rather than spams.
  bool _outboxOverflowed = false;

  /// Upper bound on a single message's fragment count, to reject nonsense
  /// before allocating.
  static const int maxFragments = 100000;

  /// How many incomplete fragment groups to hold before discarding them all.
  static const int maxPendingFragmentGroups = 64;

  // ---------------------------------------------------------------- lifecycle

  RosConnectionState get state => _state;

  /// Connection state changes. Emits the current state to new listeners.
  ///
  /// Deliberately not `async*` with a leading `yield`: that subscribes to the
  /// underlying controller several microtasks after `listen()` returns, and
  /// every state added in between is lost. A `StreamBuilder` built in the same
  /// frame as `connect()` would miss the `connected` transition and sit on
  /// "connecting" forever against a healthy client.
  Stream<RosConnectionState> get states {
    late StreamController<RosConnectionState> controller;
    StreamSubscription<RosConnectionState>? sub;
    controller = StreamController<RosConnectionState>(
      onListen: () {
        // Both in the same turn, so no state can slip between them.
        controller.add(_state);
        sub = _stateController.stream
            .listen(controller.add, onDone: controller.close);
      },
      onCancel: () => sub?.cancel(),
    );
    return controller.stream;
  }

  bool get isConnected => _state == RosConnectionState.connected;

  /// Client-side diagnostics: connection errors, malformed frames, dropped
  /// fragments, buffer overflows.
  ///
  /// **This does not carry server-side errors**, however much the rosbridge
  /// protocol document implies otherwise. rosbridge 2.x has no `status`
  /// capability — `rosbridge_protocol.py` registers none, and `Protocol.log`
  /// writes to the robot's own ROS logger and nowhere else. So a type
  /// mismatch on advertise, an unknown topic, or a rejected QoS profile is
  /// visible only on the robot's console, and the operation is silently
  /// inert on this end.
  ///
  /// Worth listening to in development regardless: everything this client
  /// itself can tell you arrives here.
  Stream<RosStatus> get status => _statusController.stream;

  /// Opens the connection. Completes when the socket is ready.
  Future<void> connect() async {
    if (_state == RosConnectionState.closed) {
      throw StateError('Client is closed; construct a new Ros2Client.');
    }
    if (isConnected) return;
    if (_connecting != null) return _connecting!.future;

    final completer = Completer<void>();
    // Only awaited when a second connect() overlaps the first; without this a
    // failure with no concurrent caller surfaces as an unhandled async error.
    completer.future.ignore();
    _connecting = completer;
    _setState(_reconnectAttempt == 0
        ? RosConnectionState.connecting
        : RosConnectionState.reconnecting);

    try {
      final transport = _transportFactory(uri);
      _transport = transport;
      _incomingSub = transport.incoming.listen(
        _onFrame,
        onError: _onTransportError,
      );
      await transport.connect();

      // The backoff counter is not reset here. A server that accepts a
      // connection and immediately drops it would otherwise be retried at the
      // initial delay forever. Instead the connection's age is checked on
      // disconnect, in _scheduleReconnect.
      // close() may have run while transport.connect() was in flight. It has
      // already torn everything down, so completing successfully here would
      // hand the caller a connected-looking client that is permanently closed.
      if (_state == RosConnectionState.closed) {
        await transport.close();
        // Thrown, not completed: connect() is async, so the caller holds
        // this function's own future. Completing `completer` alone would
        // leave the caller seeing success while the error went unhandled.
        throw StateError('Client was closed while connecting.');
      }

      _connectedAt = DateTime.now();
      _setState(RosConnectionState.connected);
      if (sendSetLevel) {
        _send({'op': Op.setLevel, 'level': statusLevel.wireName});
      }
      _resubscribeAll();
      _flushOutbox();
      completer.complete();
    } catch (e, s) {
      completer.completeError(e, s);
      _connecting = null;
      _scheduleReconnect();
      rethrow;
    } finally {
      _connecting = null;
    }
  }

  /// Closes the connection permanently and releases all resources.
  Future<void> close() async {
    _setState(RosConnectionState.closed);
    _reconnectTimer?.cancel();
    await _incomingSub?.cancel();
    await _transport?.close();

    for (final call in _pendingCalls.values) {
      if (!call.isCompleted) {
        call.completeError(ServiceCallException('<closed>', 'Client closed'));
      }
    }
    _pendingCalls.clear();

    // Copy first: failing a goal runs its completion callback, which removes
    // itself from _activeGoals and would otherwise mutate during iteration.
    final goals = List<_ActiveGoal>.of(_activeGoals.values);
    _activeGoals.clear();
    for (final goal in goals) {
      goal.fail(ActionFailedException(
          goal.actionName, GoalStatus.unknown, 'Client closed'));
    }

    final listeners = [
      for (final list in _listeners.values) ...list,
    ];
    _listeners.clear();
    for (final l in listeners) {
      // Not awaited: close() completes only once the listener drains the done
      // event, which a paused or slow consumer can delay indefinitely.
      unawaited(l.controller.close());
    }
    _advertised.clear();
    _outbox.clear();

    await _stateController.close();
    await _statusController.close();
  }

  // ------------------------------------------------------------------- topics

  /// Subscribes to [topic], decoding each message as [T].
  ///
  /// [T] must have a registered [MessageCodec]; generated message packages
  /// register themselves on import. Cancelling the returned stream's
  /// subscription unsubscribes from the bridge.
  ///
  /// Set [qos] to [QosProfile.sensorData] for camera/lidar/IMU topics — the
  /// default reliable profile will not match a best-effort publisher and you
  /// will silently receive nothing.
  Stream<T> subscribe<T>(
    String topic, {
    QosProfile qos = QosProfile.default_,
    Compression? compression,
    int? throttleRate,
    int? queueLength,
    int? fragmentSize,
    Backpressure backpressure = Backpressure.buffer,
    MessageCodec<T>? codec,
  }) {
    final resolved = codec ?? MessageRegistry.of<T>();
    return _subscribeInternal<T>(
      topic,
      rosType: resolved.rosType,
      decode: resolved.fromJson,
      qos: qos,
      compression: compression,
      throttleRate: throttleRate,
      queueLength: queueLength,
      fragmentSize: fragmentSize,
      backpressure: backpressure,
    );
  }

  /// Subscribes without a generated Dart type, yielding raw JSON maps.
  ///
  /// Useful for topics discovered at runtime, or message types you have not
  /// generated bindings for.
  Stream<JsonMessage> subscribeJson(
    String topic, {
    String? type,
    QosProfile qos = QosProfile.default_,
    Compression? compression,
    int? throttleRate,
    int? queueLength,
    int? fragmentSize,
    Backpressure backpressure = Backpressure.buffer,
  }) {
    return _subscribeInternal<JsonMessage>(
      topic,
      rosType: type,
      decode: (json) => JsonMessage(type ?? '', json),
      qos: qos,
      compression: compression,
      throttleRate: throttleRate,
      queueLength: queueLength,
      fragmentSize: fragmentSize,
      backpressure: backpressure,
    );
  }

  Stream<T> _subscribeInternal<T>(
    String topic, {
    required String? rosType,
    required T Function(Map<String, Object?>) decode,
    required QosProfile qos,
    Compression? compression,
    int? throttleRate,
    int? queueLength,
    int? fragmentSize,
    Backpressure backpressure = Backpressure.buffer,
  }) {
    final effectiveCompression = compression ?? defaultCompression;
    _rejectFragmentedBinary(topic, effectiveCompression, fragmentSize);
    _rejectUndecodableRaw<T>(topic, effectiveCompression);
    _warnAboutSharedTopicSettings(
        topic, effectiveCompression, throttleRate, queueLength);

    final id = _nextId('subscribe');
    late final _Listener<T> listener;
    late final StreamController<T> controller;

    controller = StreamController<T>(
      onListen: () {
        _listeners
            .putIfAbsent(topic, () => [])
            .add(listener as _Listener<Object?>);
        _send(listener.subscribeCommand);
      },
      // A paused subscription is the only signal Dart gives that the consumer
      // is behind, and it is the one `await for` and StreamBuilder both
      // produce. While paused, messages are held as raw bodies and never
      // decoded; on resume only the survivors are.
      onResume: () => listener.flushBacklog(),
      onCancel: () {
        _listeners[topic]?.remove(listener);
        if (_listeners[topic]?.isEmpty ?? false) _listeners.remove(topic);
        _send({'op': Op.unsubscribe, 'id': id, 'topic': topic});
        // Deliberately does not close `controller`: Dart already tears the
        // stream down after onCancel, and awaiting close() here deadlocks
        // against the very cancel that triggered it.
      },
    );

    listener = _Listener<T>(
      id: id,
      topic: topic,
      controller: controller,
      decode: decode,
      backpressure: backpressure,
      subscribeCommand: {
        'op': Op.subscribe,
        'id': id,
        'topic': topic,
        if (rosType != null) 'type': rosType,
        'compression': effectiveCompression.wireName,
        if (throttleRate != null) 'throttle_rate': throttleRate,
        if (queueLength != null) 'queue_length': queueLength,
        if (fragmentSize != null) 'fragment_size': fragmentSize,
        'qos': qos.toWire(),
      },
    );

    return controller.stream;
  }

  /// Advertises [topic] and returns a typed publisher.
  ///
  /// Call [RosPublisher.close] when done. Advertising the same topic twice
  /// returns independent publishers sharing one bridge advertisement.
  /// Set [perishable] for command topics such as `/cmd_vel`.
  ///
  /// The outbox exists so a publish during a brief reconnect is not lost, and
  /// for state that is still true a minute later — a goal pose, a mode change
  /// — that is right. For a motion command it is dangerous: a stalled link
  /// fills the buffer with velocity commands, and the moment it recovers the
  /// robot is handed seconds of stale motion in one burst, after the operator
  /// has already let go. A perishable publisher drops instead of queueing.
  RosPublisher<T> advertise<T>(
    String topic, {
    QosProfile qos = QosProfile.default_,
    bool latch = false,
    bool perishable = false,
    MessageCodec<T>? codec,
  }) {
    final resolved = codec ?? MessageRegistry.of<T>();
    // rosbridge's `latch` flag is documented as "ignored if qos is provided",
    // and this client always provides qos -- so the flag alone has never done
    // anything. Latching in ROS 2 *is* transient-local durability, so express
    // it there. An explicitly transient-local profile is left alone.
    final effectiveQos = latch && qos.durability == Durability.volatile
        ? qos.copyWith(durability: Durability.transientLocal)
        : qos;
    final existing = _advertised[topic];
    if (existing == null) {
      final command = <String, Object?>{
        'op': Op.advertise,
        'id': _nextId('advertise'),
        'topic': topic,
        'type': resolved.rosType,
        'qos': effectiveQos.toWire(),
        if (latch) 'latch': true,
      };
      _advertised[topic] = _AdvertisedTopic(command);
      _send(command);
    } else {
      existing.refCount++;
      // The bridge only ever saw the first advertise for this topic, and
      // PublisherManager fixes the QoS at first registration. A second caller
      // asking for something different gets the original, silently.
      final first = existing.command['qos'];
      if (first != null && '$first' != '${effectiveQos.toWire()}') {
        _emitStatus(RosStatus(
            StatusLevel.warning,
            'Topic "$topic" is already advertised with a different QoS '
            'profile; rosbridge fixes it at first registration, so this '
            'publisher will use the original.'));
      }
    }
    return RosPublisher<T>._(
        this, topic, resolved, effectiveQos, latch, perishable);
  }

  /// One-shot publish to a topic without holding a publisher.
  ///
  /// Advertises, publishes and unadvertises. Convenient for rare commands;
  /// prefer [advertise] for anything periodic.
  void publishOnce<T>(String topic, T message,
      {QosProfile qos = QosProfile.default_, MessageCodec<T>? codec}) {
    // Offline, advertise and unadvertise are dropped by the outbox -- they are
    // rebuilt from live state on reconnect instead -- while the publish is
    // queued. The replay would then be a publish to a topic this client never
    // advertised, arriving after the matching unadvertise had already been
    // forgotten. Dropping it is the honest outcome, and it is said out loud.
    if (!isConnected) {
      _emitStatus(RosStatus(
          StatusLevel.warning,
          'publishOnce to "$topic" was discarded: the client is offline, and '
          'a one-shot publish cannot be replayed without its advertisement. '
          'Hold a publisher from advertise() if the message must survive a '
          'reconnect.'));
      return;
    }
    final publisher = advertise<T>(topic, qos: qos, codec: codec);
    publisher.publish(message);
    publisher.close();
  }

  void _unadvertise(String topic) {
    final entry = _advertised[topic];
    if (entry == null) return;
    if (--entry.refCount > 0) return;
    _advertised.remove(topic);
    _send({'op': Op.unadvertise, 'topic': topic});
  }

  // ----------------------------------------------------------------- services

  /// Calls a ROS 2 service with a registered [ServiceCodec].
  Future<Res> callService<Req, Res>(
    String service,
    Req request, {
    Duration timeout = const Duration(seconds: 10),
    ServiceCodec<Req, Res>? codec,
  }) async {
    final resolved = codec ?? ServiceRegistry.of<Req, Res>();
    final values = await callServiceJson(
      service,
      resolved.encodeRequest(request),
      type: resolved.serviceType,
      timeout: timeout,
    );
    return resolved.decodeResponse(values);
  }

  /// Calls a service with raw JSON arguments.
  Future<Map<String, Object?>> callServiceJson(
    String service,
    Map<String, Object?> args, {
    String? type,
    Duration timeout = const Duration(seconds: 10),
  }) {
    final id = _nextId('call');
    final completer = Completer<Map<String, Object?>>();
    _pendingCalls[id] = completer;

    _send({
      'op': Op.callService,
      'id': id,
      'service': service,
      'args': args,
      if (type != null) 'type': type,
    });

    return completer.future.timeout(timeout, onTimeout: () {
      _pendingCalls.remove(id);
      throw TimeoutException(
          'Service $service did not respond within $timeout', timeout);
    }).whenComplete(() => _pendingCalls.remove(id));
  }

  // ------------------------------------------------------------------ actions

  /// Sends a goal to a ROS 2 action server.
  ///
  /// Requires `rosbridge_suite` >= 2.0.0 on the robot; earlier versions reject
  /// `send_action_goal` with an "Unknown operation" status.
  /// A goal sent to an action server that does not exist gets no reply of any
  /// kind — rosbridge does not report unroutable goals — so [timeout] is the
  /// only thing standing between that and a future that never completes.
  /// It defaults to `null` because real goals legitimately run for minutes;
  /// set it for anything that should be bounded.
  GoalHandle<Feedback, Result> sendGoal<Goal, Feedback, Result>(
    String actionName,
    Goal goal, {
    bool withFeedback = true,
    Duration? timeout,
    ActionCodec<Goal, Feedback, Result>? codec,
  }) {
    final resolved = codec ?? ActionRegistry.of<Goal, Feedback, Result>();
    final id = _nextId('goal');

    final feedbackController = StreamController<Feedback>.broadcast();
    final resultCompleter = Completer<Result>();
    // A fire-and-forget goal is legitimate: `sendGoal(...)` without awaiting
    // `.result` is the natural way to say "go there". Marking the future as
    // handled stops a later failure (an abort, or the client closing) from
    // surfacing as an unhandled async error and tearing down the app. Callers
    // that do await `.result` still receive the error normally.
    resultCompleter.future.ignore();
    final handle = GoalHandle<Feedback, Result>._(
        this, actionName, id, feedbackController, resultCompleter);

    _activeGoals[id] = _ActiveGoal(
      actionName: actionName,
      onFeedback: (json) {
        if (!feedbackController.isClosed) {
          feedbackController.add(resolved.decodeFeedback(json));
        }
      },
      onResult: (json, status, ok) {
        if (resultCompleter.isCompleted) return;
        if (ok && status.isTerminal && status == GoalStatus.succeeded) {
          resultCompleter.complete(resolved.decodeResult(json));
        } else if (ok && status == GoalStatus.unknown) {
          // Servers that omit status on success still deliver a result.
          resultCompleter.complete(resolved.decodeResult(json));
        } else {
          resultCompleter.completeError(ActionFailedException(
              actionName, status, 'Goal ended as ${status.name}'));
        }
        handle._timeoutTimer?.cancel();
        unawaited(feedbackController.close());
        _activeGoals.remove(id);
      },
      onError: (error) {
        if (!resultCompleter.isCompleted) resultCompleter.completeError(error);
        handle._timeoutTimer?.cancel();
        unawaited(feedbackController.close());
        _activeGoals.remove(id);
      },
    );

    _send({
      'op': Op.sendActionGoal,
      'id': id,
      'action': actionName,
      'action_type': resolved.actionType,
      'args': resolved.encodeGoal(goal),
      'feedback': withFeedback,
    });

    if (timeout != null) {
      handle._timeoutTimer = Timer(timeout, () {
        final active = _activeGoals.remove(id);
        if (active == null || resultCompleter.isCompleted) return;
        active.fail(ActionFailedException(
            actionName, GoalStatus.unknown, 'No result within $timeout'));
      });
    }

    return handle;
  }

  // --------------------------------------------------------------- internals

  String _nextId(String prefix) => '$prefix:${_idCounter++}';

  /// Opcodes rebuilt from live state by [_resubscribeAll] on every connect.
  ///
  /// Queuing these in the outbox as well would send each one twice: once from
  /// the replay and once from the flush.
  static const Set<String> _replayedOps = {
    Op.advertise,
    Op.subscribe,
    Op.unadvertise,
    Op.unsubscribe,
  };

  void _send(Map<String, Object?> command, {bool perishable = false}) {
    if (_state == RosConnectionState.closed) return;
    final transport = _transport;
    if (transport == null || !isConnected) {
      if (!perishable) _enqueue(command);
      return;
    }
    try {
      transport.send(WireCodec.encode(command));
    } catch (_) {
      if (!perishable) _enqueue(command);
    }
  }

  void _enqueue(Map<String, Object?> command) {
    if (_replayedOps.contains(command['op'])) return;
    // Drop the oldest, not the newest. Keeping the first 256 commands of an
    // outage and discarding everything after it is backwards: the newest
    // command is the one that reflects what the operator wants now, and a stop
    // issued during the outage is exactly the one that must survive.
    if (_outbox.length >= maxOutbox) {
      _outbox.removeAt(0);
      if (!_outboxOverflowed) {
        _outboxOverflowed = true;
        _emitStatus(const RosStatus(
            StatusLevel.warning,
            'Outbox full while offline; dropping the oldest buffered '
            'commands. Publishers of perishable data (velocities, joystick '
            'input) should advertise with perishable: true.'));
      }
    }
    _outbox.add(command);
  }

  void _flushOutbox() {
    _outboxOverflowed = false;
    final pending = List<Map<String, Object?>>.from(_outbox);
    _outbox.clear();
    for (final command in pending) {
      _send(command);
    }
  }

  /// Re-issues advertisements and subscriptions after a reconnect, so callers
  /// never have to rebuild their streams when the robot restarts.
  void _resubscribeAll() {
    for (final entry in _advertised.values) {
      _sendDirect(entry.command);
    }
    for (final list in _listeners.values) {
      for (final listener in list) {
        _sendDirect(listener.subscribeCommand);
      }
    }
  }

  void _sendDirect(Map<String, Object?> command) {
    try {
      _transport?.send(WireCodec.encode(command));
    } catch (_) {
      // Will be retried on the next successful connect.
    }
  }

  void _setState(RosConnectionState next) {
    if (_state == next || _state == RosConnectionState.closed) return;
    _state = next;
    if (!_stateController.isClosed) _stateController.add(next);
  }

  /// Fails every request that cannot survive losing the socket.
  ///
  /// The bridge forgets a client's goals and in-flight service calls the
  /// moment the connection drops, so nothing will ever answer them. Leaving
  /// them pending means `await handle.result` hangs for the life of the
  /// process with nothing on `status` or `states` to explain it. `close()` has
  /// always failed them; a reconnect has to do the same.
  void _failInFlight() {
    for (final call in _pendingCalls.values) {
      if (!call.isCompleted) {
        call.completeError(ServiceCallException(
            '<disconnected>', 'Connection lost before the service responded'));
      }
    }
    _pendingCalls.clear();

    // Copied first: failing a goal runs a callback that removes it from the
    // map, which would otherwise mutate it during iteration.
    final goals = List<_ActiveGoal>.of(_activeGoals.values);
    _activeGoals.clear();
    for (final goal in goals) {
      goal.fail(ActionFailedException(goal.actionName, GoalStatus.unknown,
          'Connection lost before the goal finished'));
    }
  }

  void _onTransportError(Object error, StackTrace stack) {
    if (_state == RosConnectionState.closed) return;
    // Without this the reason a link died -- TLS failure, refused connection,
    // a peer that vanished -- is unreachable: the reconnect loop swallows it
    // and only the state change is observable.
    _emitStatus(RosStatus(StatusLevel.error, 'Connection error: $error'));
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_state == RosConnectionState.closed) return;
    _reconnectTimer?.cancel();
    // Partial fragments cannot be completed across a reconnect.
    _fragments.clear();
    _failInFlight();
    unawaited(_incomingSub?.cancel());
    _incomingSub = null;
    unawaited(_transport?.close());
    _transport = null;

    // Only a connection that survived the stability window counts as healthy
    // enough to clear the backoff; a link that flaps keeps backing off.
    final connectedAt = _connectedAt;
    _connectedAt = null;
    if (connectedAt != null &&
        DateTime.now().difference(connectedAt) >=
            reconnectPolicy.stabilityWindow) {
      _reconnectAttempt = 0;
    }

    if (!reconnectPolicy.shouldRetry(_reconnectAttempt)) {
      _setState(RosConnectionState.disconnected);
      return;
    }

    _setState(RosConnectionState.reconnecting);
    final delay = reconnectPolicy.delayFor(_reconnectAttempt);
    _reconnectAttempt++;
    _reconnectTimer = Timer(delay, () {
      if (_state == RosConnectionState.closed) return;
      connect().catchError((Object error) {
        // The first connect() surfaces its failure to its caller; every retry
        // after that has nowhere else to report.
        _emitStatus(RosStatus(StatusLevel.error,
            'Reconnect attempt $_reconnectAttempt failed: $error'));
      });
    });
  }

  void _onFrame(Object frame) {
    final Map<String, Object?> message;
    try {
      message = WireCodec.decode(frame);
    } catch (e) {
      _emitStatus(RosStatus(StatusLevel.error, 'Malformed frame: $e'));
      return;
    }
    // Dispatch is guarded too: a well-formed frame with a wrong-typed field
    // (`"topic": 123`) throws deep in a handler, and an uncaught async error
    // in the host app's zone is a worse outcome than a status event.
    try {
      _dispatch(message);
    } catch (e) {
      _emitStatus(RosStatus(
          StatusLevel.error, 'Failed to handle a ${message['op']} frame: $e'));
    }
  }

  void _dispatch(Map<String, Object?> message) {
    switch (message['op']) {
      case Op.publish:
        _handlePublish(message);
      case Op.serviceResponse:
        _handleServiceResponse(message);
      case Op.actionFeedback:
        _handleActionFeedback(message);
      case Op.actionResult:
        _handleActionResult(message);
      case Op.fragment:
        _handleFragment(message);
      case Op.png:
        _emitStatus(const RosStatus(
            StatusLevel.error,
            'Received a PNG-compressed frame, which this client cannot decode. '
            'Subscribe with Compression.cbor (or .none) instead.'));
      case Op.status:
        _handleStatus(message);
      default:
        _emitStatus(RosStatus(
            StatusLevel.warning, 'Unhandled opcode `${message['op']}`'));
    }
  }

  void _handlePublish(Map<String, Object?> message) {
    final topic = message['topic'] as String?;
    if (topic == null) return;
    final listeners = _listeners[topic];
    if (listeners == null || listeners.isEmpty) return;

    final body = message['msg'];
    if (body is! Map<String, Object?>) return;

    // Copy: a listener cancelling mid-dispatch must not mutate the iteration.
    for (final listener in List<_Listener<Object?>>.from(listeners)) {
      listener.deliver(body, _emitStatus);
    }
  }

  void _handleServiceResponse(Map<String, Object?> message) {
    final id = message['id'] as String?;
    if (id == null) return;
    final completer = _pendingCalls.remove(id);
    if (completer == null || completer.isCompleted) return;

    final ok = message['result'];
    if (ok == false) {
      completer.completeError(ServiceCallException(
        message['service'] as String? ?? '<unknown>',
        '${message['values'] ?? 'call failed'}',
      ));
      return;
    }
    final values = message['values'];
    completer.complete(values is Map<String, Object?> ? values : const {});
  }

  void _handleActionFeedback(Map<String, Object?> message) {
    final goal = _activeGoals[message['id']];
    final values = message['values'];
    if (goal != null && values is Map<String, Object?>) {
      goal.onFeedback(values);
    }
  }

  void _handleActionResult(Map<String, Object?> message) {
    final goal = _activeGoals[message['id']];
    if (goal == null) return;
    final values = message['values'];
    goal.onResult(
      values is Map<String, Object?> ? values : const {},
      GoalStatus.fromValue(message['status'] as int?),
      message['result'] != false,
    );
  }

  /// Rejects `fragment_size` combined with a binary compression.
  ///
  /// rosbridge cannot do both. `Fragmentation.fragment` re-serialises the
  /// already-encoded CBOR payload with `json.dumps`, which refuses it —
  /// "reject_bytes is on and '...' is bytes" — and the bridge then sends
  /// *nothing at all*, logging the failure only on its own console. Verified
  /// against rosbridge 2.0.7: the subscription is accepted and simply never
  /// delivers a message.
  ///
  /// Failing here turns a silent hang into a message that names the cause.
  static void _rejectFragmentedBinary(
      String topic, Compression compression, int? fragmentSize) {
    if (fragmentSize == null) return;
    if (compression != Compression.cbor &&
        compression != Compression.cborRaw) {
      return;
    }
    throw ArgumentError.value(
      fragmentSize,
      'fragmentSize',
      'rosbridge cannot fragment ${compression.wireName} messages: it '
          're-serialises the encoded payload as JSON, fails, and silently '
          'delivers nothing for "$topic". Use fragmentSize with '
          'Compression.none, or drop fragmentSize and keep '
          '${compression.wireName} — a CBOR payload is already far smaller '
          'than the JSON it replaces.',
    );
  }

  /// Rejects `cbor-raw` for a typed subscription.
  ///
  /// `cbor-raw` does not compress the message — it *replaces* it. `subscribe.py`
  /// substitutes `msg` with `{secs, nsecs, bytes}`, where `bytes` is the raw
  /// CDR serialisation. This client has no CDR decoder (that arrives with the
  /// Foxglove transport), so a generated decoder finds none of its fields and
  /// `Field.as*` returns type defaults: a steady stream of all-zero messages,
  /// forever, with no error anywhere.
  ///
  /// [subscribeJson] can still ask for it and read `bytes` directly.
  static void _rejectUndecodableRaw<T>(String topic, Compression compression) {
    if (compression != Compression.cborRaw || T == JsonMessage) return;
    throw ArgumentError.value(
      'cbor-raw',
      'compression',
      'Compression.cborRaw replaces the message body with a raw CDR blob, '
          'which this client cannot decode into $T. Every field of "$topic" '
          'would silently read back as its type default. Use '
          'Compression.cbor for a typed subscription, or subscribeJson to '
          'read the raw bytes yourself.',
    );
  }

  /// Warns when a subscription silently changes what other listeners get.
  ///
  /// rosbridge merges every client's options for a topic rather than honouring
  /// them per subscription: `throttle_rate` and `queue_length` become the
  /// `min()` across all listeners, and compression becomes the maximum, with
  /// `cbor-raw` beating `cbor` beating `png`. So a second, unthrottled
  /// subscriber turns throttling off for the widget that asked for it, and one
  /// listener asking for `cbor-raw` hands every other listener on that topic an
  /// undecodable blob.
  void _warnAboutSharedTopicSettings(String topic, Compression compression,
      int? throttleRate, int? queueLength) {
    final existing = _listeners[topic];
    if (existing == null || existing.isEmpty) return;

    for (final listener in existing) {
      final command = listener.subscribeCommand;
      if (command['compression'] != compression.wireName) {
        _emitStatus(RosStatus(
            StatusLevel.warning,
            'Topic "$topic" already has a listener using '
            '${command['compression']}; rosbridge applies one compression per '
            'topic, so both listeners will receive '
            '${_strongerCompression(compression.wireName, '${command['compression']}')}.'));
        break;
      }
    }

    void checkMin(String field, int? requested) {
      if (requested == null) return;
      for (final listener in existing) {
        final other = listener.subscribeCommand[field] as int? ?? 0;
        if (other < requested) {
          _emitStatus(RosStatus(
              StatusLevel.warning,
              'Topic "$topic" already has a listener with $field $other; '
              'rosbridge takes the minimum across listeners, so the '
              'requested $requested will not apply.'));
          return;
        }
      }
    }

    checkMin('throttle_rate', throttleRate);
    checkMin('queue_length', queueLength);
  }

  /// The compression rosbridge would settle on for two listeners.
  static String _strongerCompression(String a, String b) {
    const order = ['none', 'png', 'cbor', 'cbor-raw'];
    return order.indexOf(a) >= order.indexOf(b) ? a : b;
  }

  /// Reassembles a message split by the bridge's `fragment_size`.
  void _handleFragment(Map<String, Object?> message) {
    final id = message['id'] as String?;
    final total = message['total'] as int?;
    final num = message['num'] as int?;
    final data = message['data'] as String?;
    if (id == null || total == null || num == null || data == null) return;

    if (total <= 0 || total > maxFragments || num < 0 || num >= total) {
      _emitStatus(RosStatus(StatusLevel.error,
          'Ignoring fragment $id with num=$num of total=$total'));
      return;
    }

    var buffer = _fragments[id];
    // An id can be reused while an earlier group is still incomplete. Reusing
    // the stale buffer would silently swallow the new message, so a differing
    // total means this is a new group.
    if (buffer == null || buffer.total != total) {
      if (_fragments.length >= maxPendingFragmentGroups) {
        _fragments.clear();
        _emitStatus(const RosStatus(
            StatusLevel.warning,
            'Dropped incomplete fragment groups; the bridge is sending '
            'fragments that never complete.'));
      }
      buffer = _FragmentBuffer(total);
      _fragments[id] = buffer;
    }
    if (buffer.add(num, data) && !_warnedFragmentCollision) {
      _warnedFragmentCollision = true;
      _emitStatus(const RosStatus(
          StatusLevel.warning,
          'Fragments from two messages arrived under the same id. rosbridge '
          'labels every fragmented message "0", so concurrent fragmented '
          'topics cannot be told apart; the partial message was discarded '
          'rather than spliced. Raise max_message_size on the bridge, or '
          'subscribe to fewer large topics at once.'));
    }
    if (!buffer.isComplete) return;

    _fragments.remove(id);
    try {
      _dispatch(WireCodec.decode(buffer.join()));
    } catch (e) {
      _emitStatus(RosStatus(
          StatusLevel.error, 'Failed to reassemble fragment $id: $e'));
    }
  }

  void _handleStatus(Map<String, Object?> message) {
    _emitStatus(RosStatus(
      StatusLevel.parse(message['level'] as String? ?? 'info'),
      message['msg'] as String? ?? '',
      id: message['id'] as String?,
    ));
  }

  void _emitStatus(RosStatus status) {
    if (!_statusController.isClosed) _statusController.add(status);
  }
}

/// One local listener on a topic.
final class _Listener<T> {
  _Listener({
    required this.id,
    required this.topic,
    required this.controller,
    required this.decode,
    required this.subscribeCommand,
    this.backpressure = Backpressure.buffer,
  });

  final String id;
  final String topic;
  final StreamController<T> controller;
  final T Function(Map<String, Object?>) decode;
  final Map<String, Object?> subscribeCommand;
  final Backpressure backpressure;

  /// Raw bodies received while the consumer was paused, still undecoded.
  final List<Map<String, Object?>> _backlog = [];

  /// Messages discarded since the last delivery, for diagnostics.
  int droppedCount = 0;

  void deliver(Map<String, Object?> body, void Function(RosStatus) onError) {
    if (controller.isClosed) return;

    // `isPaused` is true whenever the consumer has not asked for more: an
    // `await for` body still running, a StreamBuilder between frames, an
    // explicit pause(). Delivering anyway just grows Dart's own buffer, which
    // is the thing backpressure exists to bound.
    if (!backpressure.isBuffered && controller.isPaused) {
      _backlog.add(body);
      final limit = backpressure.maxBuffered;
      while (_backlog.length > limit) {
        _backlog.removeAt(0);
        droppedCount++;
      }
      return;
    }
    _emit(body, onError);
  }

  /// Delivers whatever survived the pause. Decoding happens here, so messages
  /// dropped while paused cost nothing beyond the bytes already received.
  void flushBacklog([void Function(RosStatus)? onError]) {
    if (_backlog.isEmpty) return;
    final pending = List<Map<String, Object?>>.of(_backlog);
    _backlog.clear();
    for (final body in pending) {
      if (controller.isClosed || controller.isPaused) {
        // Paused again mid-flush; keep the rest under the same policy.
        _backlog.add(body);
        continue;
      }
      _emit(body, onError ?? (_) {});
    }
  }

  void _emit(Map<String, Object?> body, void Function(RosStatus) onError) {
    try {
      controller.add(decode(body));
    } catch (e) {
      // A single malformed message must not tear down the subscription: robots
      // publish surprising things, and a dead stream is worse than a dropped
      // frame.
      onError(RosStatus(
          StatusLevel.error, 'Failed to decode a message on $topic: $e'));
    }
  }
}

final class _AdvertisedTopic {
  _AdvertisedTopic(this.command);
  final Map<String, Object?> command;
  int refCount = 1;
}

final class _ActiveGoal {
  _ActiveGoal({
    required this.actionName,
    required this.onFeedback,
    required this.onResult,
    required this.onError,
  });

  final String actionName;
  final void Function(Map<String, Object?>) onFeedback;
  final void Function(Map<String, Object?>, GoalStatus, bool) onResult;
  final void Function(Object) onError;

  void fail(Object error) => onError(error);
}

final class _FragmentBuffer {
  _FragmentBuffer(this.total) : _parts = List<String?>.filled(total, null);

  final int total;
  final List<String?> _parts;
  int _received = 0;

  /// Adds a fragment, reporting whether it collided with one already held.
  ///
  /// rosbridge gives *every* fragmented message the id `"0"`:
  /// `fragmentation_seed` is a class attribute, the increment writes an
  /// instance attribute, and `protocol.py` builds a fresh `Fragmentation` per
  /// send — so the counter is read as 0 forever. Two topics fragmenting
  /// concurrently therefore interleave under one id. A repeated index is the
  /// signal, and the only safe reading of it is that a new message has begun:
  /// splicing the two together yields a corrupt reassembly, which is worse
  /// than losing one message.
  bool add(int index, String data) {
    if (index < 0 || index >= total) return false;
    final collided = _parts[index] != null;
    if (collided) {
      _parts.fillRange(0, total, null);
      _received = 0;
    }
    _parts[index] = data;
    _received++;
    return collided;
  }

  bool get isComplete => _received == total;

  String join() => _parts.map((p) => p ?? '').join();
}

/// Keeps [jsonEncode] reachable for consumers building raw commands.
const JsonCodec rosJson = json;
