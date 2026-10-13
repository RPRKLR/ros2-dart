import 'dart:async';
import 'dart:convert';

import 'package:ros2_flutter/ros2_flutter.dart';

/// An in-memory transport, so widget tests do no real network I/O and leave
/// no pending timers behind.
final class FakeTransport implements RosTransport {
  final _incoming = StreamController<Object>.broadcast();
  final List<Map<String, Object?>> sent = [];

  @override
  Stream<Object> get incoming => _incoming.stream;

  @override
  Future<void> connect() async {}

  @override
  void send(String data) => sent.add(jsonDecode(data) as Map<String, Object?>);

  @override
  Future<void> close() async {
    if (!_incoming.isClosed) await _incoming.close();
  }

  void publish(String topic, Map<String, Object?> msg) =>
      _incoming.add(jsonEncode({'op': 'publish', 'topic': topic, 'msg': msg}));

  /// The messages published to [topic], oldest first.
  List<Map<String, Object?>> published(String topic) => [
        for (final m in sent)
          if (m['op'] == 'publish' && m['topic'] == topic)
            m['msg']! as Map<String, Object?>,
      ];
}

/// A client wired to a [FakeTransport], connecting as soon as it is mounted.
({Ros2Client client, FakeTransport transport}) fakeClient() {
  final transport = FakeTransport();
  final client = Ros2Client(
    Uri.parse('ws://fake:9090'),
    transportFactory: (_) => transport,
    reconnectPolicy: ReconnectPolicy.none,
  );
  return (client: client, transport: transport);
}
