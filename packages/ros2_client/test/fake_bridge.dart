import 'dart:async';
import 'dart:convert';

import 'package:ros2_client/ros2_client.dart';

/// An in-memory stand-in for a rosbridge server.
///
/// Records every command the client sends and lets a test push frames back,
/// so the full client can be exercised without a ROS installation.
final class FakeBridge implements RosTransport {
  FakeBridge({this.failConnect = false});

  final _incoming = StreamController<Object>.broadcast();

  /// Every command received, decoded.
  final List<Map<String, Object?>> sent = [];

  bool failConnect;
  bool connected = false;
  int connectAttempts = 0;

  @override
  Stream<Object> get incoming => _incoming.stream;

  @override
  Future<void> connect() async {
    connectAttempts++;
    if (failConnect) throw StateError('connect failed');
    connected = true;
  }

  @override
  void send(String data) {
    if (!connected) throw StateError('not connected');
    sent.add(jsonDecode(data) as Map<String, Object?>);
  }

  @override
  Future<void> close() async {
    connected = false;
    if (!_incoming.isClosed) await _incoming.close();
  }

  // ------------------------------------------------------------- test helpers

  /// Commands matching an opcode.
  List<Map<String, Object?>> opsOf(String op) =>
      sent.where((m) => m['op'] == op).toList();

  Map<String, Object?>? lastOf(String op) {
    final matches = opsOf(op);
    return matches.isEmpty ? null : matches.last;
  }

  /// Pushes a raw frame to the client.
  void emit(Object frame) => _incoming.add(frame);

  /// Pushes a `publish` frame.
  void publish(String topic, Map<String, Object?> msg) =>
      emit(jsonEncode({'op': 'publish', 'topic': topic, 'msg': msg}));

  /// Responds to the most recent `call_service`.
  void respondToCall(Map<String, Object?> values, {bool result = true}) {
    final call = lastOf('call_service');
    emit(jsonEncode({
      'op': 'service_response',
      'id': call?['id'],
      'service': call?['service'],
      'values': values,
      'result': result,
    }));
  }

  /// Pushes action feedback for the most recent goal.
  void sendFeedback(Map<String, Object?> values) {
    final goal = lastOf('send_action_goal');
    emit(jsonEncode({
      'op': 'action_feedback',
      'id': goal?['id'],
      'action': goal?['action'],
      'values': values,
    }));
  }

  /// Pushes an action result for the most recent goal.
  void sendResult(Map<String, Object?> values,
      {int status = 4, bool result = true}) {
    final goal = lastOf('send_action_goal');
    emit(jsonEncode({
      'op': 'action_result',
      'id': goal?['id'],
      'action': goal?['action'],
      'values': values,
      'status': status,
      'result': result,
    }));
  }

  /// Simulates the connection dropping.
  void drop() {
    connected = false;
    _incoming.addError(StateError('connection lost'));
  }
}

/// Mints a fresh [FakeBridge] per connection attempt, the way a real transport
/// factory does, and records them all.
///
/// Needed for reconnect tests: a transport is closed when the connection drops
/// and cannot be reused, so a single shared [FakeBridge] cannot model more than
/// one attempt.
final class FakeBridgeFarm {
  final List<FakeBridge> bridges = [];

  /// Total connection attempts across every bridge handed out.
  int get connectAttempts => bridges.length;

  /// The most recently created bridge.
  FakeBridge get current => bridges.last;

  FakeBridge create() {
    final bridge = FakeBridge();
    bridges.add(bridge);
    return bridge;
  }
}

/// A transport whose `connect()` blocks until the test releases it.
///
/// Needed to exercise interleavings that a synchronous fake cannot reach, such
/// as `close()` landing while a connection attempt is still in flight.
final class GatedBridge implements RosTransport {
  final _incoming = StreamController<Object>.broadcast();
  final _gate = Completer<void>();
  final List<Map<String, Object?>> sent = [];
  bool connected = false;

  /// Lets the pending `connect()` finish.
  void release() {
    if (!_gate.isCompleted) _gate.complete();
  }

  @override
  Stream<Object> get incoming => _incoming.stream;

  @override
  Future<void> connect() async {
    await _gate.future;
    connected = true;
  }

  @override
  void send(String data) => sent.add(jsonDecode(data) as Map<String, Object?>);

  @override
  Future<void> close() async {
    connected = false;
    if (!_incoming.isClosed) await _incoming.close();
  }
}
