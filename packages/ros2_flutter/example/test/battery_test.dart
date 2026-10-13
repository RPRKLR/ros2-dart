import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ros2_flutter/ros2_flutter.dart';
import 'package:ros2_flutter_example/main.dart';

final class _FakeTransport implements RosTransport {
  final _incoming = StreamController<Object>.broadcast();

  @override
  Stream<Object> get incoming => _incoming.stream;

  @override
  Future<void> connect() async {}

  @override
  void send(String data) {}

  @override
  Future<void> close() async {
    if (!_incoming.isClosed) await _incoming.close();
  }

  void publish(String topic, Map<String, Object?> msg) =>
      _incoming.add(jsonEncode({'op': 'publish', 'topic': topic, 'msg': msg}));
}

void main() {
  setUpAll(registerStandardMessages);

  testWidgets('an unmeasured battery shows a dash instead of crashing',
      (tester) async {
    final transport = _FakeTransport();
    final client = Ros2Client(Uri.parse('ws://fake:9090'),
        transportFactory: (_) => transport,
        reconnectPolicy: ReconnectPolicy.none);
    addTearDown(client.close);

    await tester.pumpWidget(MaterialApp(
        home: RosConnection.withClient(
            client: client, child: const ControlPanel())));
    await tester.pump();
    await tester.pump();

    // A robot that cannot measure its charge publishes NaN, which rosbridge
    // sends as null and the client decodes back to NaN.
    transport.publish('/battery_state', {'voltage': 12.0, 'percentage': null});
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('—'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });
}
