import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import 'encoding/wire_codec.dart';
import 'messages/action.dart';
import 'messages/message.dart';
import 'messages/service.dart';
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
  RosPublisher._(this._client, this.topic, this._codec, this._qos, this._latch);

  final Ros2Client _client;
  final String topic;
  final MessageCodec<T> _codec;
  final QosProfile _qos;
  final bool _latch;
  bool _closed = false;

  String get rosType => _codec.rosType;

  /// Publishes [message]. Silently buffered by the client while reconnecting.
  void publish(T message) {
    if (_closed) {
      throw StateError('Publisher for $topic is closed.');
    }
    _client._send({
      'op': Op.publish,
      'topic': topic,
      'msg': _codec.toJson(message),
      if (_latch) 'latch': true,
      'qos': _qos.toWire(),
    });
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
  final StatusLevel statusLevel;

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

  /// Maximum number of commands buffered while offline.
  static const int maxOutbox = 256;

  /// Upper bound on a single message's fragment count, to reject nonsense
  /// before allocating.
  static const int maxFragments = 100000;

  /// How many incomplete fragment groups to hold before discarding them all.
  static const int maxPendingFragmentGroups = 64;

  // ---------------------------------------------------------------- lifecycle

  RosConnectionState get state => _state;

  /// Connection state changes. Emits the current state to new listeners.
  Stream<RosConnectionState> get states async* {
    yield _state;
    yield* _stateController.stream;
  }

  bool get isConnected => _state == RosConnectionState.connected;

  /// Diagnostics from the rosbridge server (bad topic name, type mismatch...).
  ///
  /// Worth surfacing in development: rosbridge reports most user errors here
  /// rather than failing the operation.
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
      _send({'op': Op.setLevel, 'level': statusLevel.wireName});
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
  }) {
    final effectiveCompression = compression ?? defaultCompression;
    _rejectFragmentedBinary(topic, effectiveCompression, fragmentSize);

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
  RosPublisher<T> advertise<T>(
    String topic, {
    QosProfile qos = QosProfile.default_,
    bool latch = false,
    MessageCodec<T>? codec,
  }) {
    final resolved = codec ?? MessageRegistry.of<T>();
    final existing = _advertised[topic];
    if (existing == null) {
      final command = <String, Object?>{
        'op': Op.advertise,
        'id': _nextId('advertise'),
        'topic': topic,
        'type': resolved.rosType,
        'qos': qos.toWire(),
        if (latch) 'latch': true,
      };
      _advertised[topic] = _AdvertisedTopic(command);
      _send(command);
    } else {
      existing.refCount++;
    }
    return RosPublisher<T>._(this, topic, resolved, qos, latch);
  }

  /// One-shot publish to a topic without holding a publisher.
  ///
  /// Advertises, publishes and unadvertises. Convenient for rare commands;
  /// prefer [advertise] for anything periodic.
  void publishOnce<T>(String topic, T message,
      {QosProfile qos = QosProfile.default_, MessageCodec<T>? codec}) {
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

  void _send(Map<String, Object?> command) {
    if (_state == RosConnectionState.closed) return;
    final transport = _transport;
    if (transport == null || !isConnected) {
      _enqueue(command);
      return;
    }
    try {
      transport.send(WireCodec.encode(command));
    } catch (_) {
      _enqueue(command);
    }
  }

  void _enqueue(Map<String, Object?> command) {
    if (_replayedOps.contains(command['op'])) return;
    if (_outbox.length < maxOutbox) _outbox.add(command);
  }

  void _flushOutbox() {
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

  void _onTransportError(Object error, StackTrace stack) {
    if (_state == RosConnectionState.closed) return;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_state == RosConnectionState.closed) return;
    _reconnectTimer?.cancel();
    // Partial fragments cannot be completed across a reconnect.
    _fragments.clear();
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
      connect().catchError((Object _) {});
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
    buffer.add(num, data);
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
  });

  final String id;
  final String topic;
  final StreamController<T> controller;
  final T Function(Map<String, Object?>) decode;
  final Map<String, Object?> subscribeCommand;

  void deliver(Map<String, Object?> body, void Function(RosStatus) onError) {
    if (controller.isClosed) return;
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

  void add(int index, String data) {
    if (index < 0 || index >= total || _parts[index] != null) return;
    _parts[index] = data;
    _received++;
  }

  bool get isComplete => _received == total;

  String join() => _parts.map((p) => p ?? '').join();
}

/// Keeps [jsonEncode] reachable for consumers building raw commands.
const JsonCodec rosJson = json;
