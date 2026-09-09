import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ros2_flutter/ros2_flutter.dart';

/// An in-memory transport, so widget tests do no real network I/O and leave
/// no pending timers behind.
final class _FakeTransport implements RosTransport {
  final _incoming = StreamController<Object>.broadcast();
  final List<Map<String, Object?>> sent = [];

  @override
  Stream<Object> get incoming => _incoming.stream;

  @override
  Future<void> connect() async {}

  @override
  void send(String data) =>
      sent.add(jsonDecode(data) as Map<String, Object?>);

  @override
  Future<void> close() async {
    if (!_incoming.isClosed) await _incoming.close();
  }

  void publish(String topic, Map<String, Object?> msg) =>
      _incoming.add(jsonEncode({'op': 'publish', 'topic': topic, 'msg': msg}));

  /// Pushes a frame verbatim, for wire forms `jsonEncode` cannot produce.
  void emitRaw(String frame) => _incoming.add(frame);
}

/// A client wired to [_FakeTransport], connected and ready.
({Ros2Client client, _FakeTransport transport}) fakeClient() {
  final transport = _FakeTransport();
  final client = Ros2Client(
    Uri.parse('ws://fake:9090'),
    transportFactory: (_) => transport,
    reconnectPolicy: ReconnectPolicy.none,
  );
  return (client: client, transport: transport);
}

void main() {
  setUpAll(registerStandardMessages);

  testWidgets('RosConnection exposes a client to descendants', (tester) async {
    final fake = fakeClient();
    addTearDown(fake.client.close);
    Ros2Client? found;

    await tester.pumpWidget(
      MaterialApp(
        home: RosConnection.withClient(
          client: fake.client,
          child: Builder(
            builder: (context) {
              found = RosConnection.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(found, same(fake.client));
    expect(found!.isConnected, isTrue);
  });

  testWidgets('RosConnection.of throws a helpful error with no ancestor',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(
              () => RosConnection.of(context),
              throwsA(isA<FlutterError>().having((e) => e.message, 'message',
                  contains('no RosConnection ancestor'))),
            );
            return const SizedBox();
          },
        ),
      ),
    );
  });

  testWidgets('RosConnectionBuilder reflects the connection state',
      (tester) async {
    final fake = fakeClient();
    addTearDown(fake.client.close);
    await tester.pumpWidget(
      MaterialApp(
        home: RosConnection.withClient(
          client: fake.client,
          child: RosConnectionBuilder(
            builder: (context, state) => Text(
              state.name,
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('connected'), findsOneWidget);
  });

  testWidgets('RosTopicBuilder shows a placeholder, then live data',
      (tester) async {
    final fake = fakeClient();
    addTearDown(fake.client.close);

    await tester.pumpWidget(
      MaterialApp(
        home: RosConnection.withClient(
          client: fake.client,
          child: RosTopicBuilder<BatteryState>(
            topic: '/battery_state',
            builder: (context, battery) => Text(
              battery == null
                  ? 'no data'
                  : '${(battery.percentage * 100).round()}%',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('no data'), findsOneWidget);

    // A message arrives from the robot.
    fake.transport.publish('/battery_state', {'percentage': 0.42});
    await tester.pump();
    await tester.pump();

    expect(find.text('42%'), findsOneWidget);
  });

  testWidgets('TeleopJoystick publishes a Twist on drag and stops on release',
      (tester) async {
    final fake = fakeClient();
    addTearDown(fake.client.close);
    await tester.pumpWidget(
      MaterialApp(
        home: RosConnection.withClient(
          client: fake.client,
          child: const Scaffold(body: Center(child: TeleopJoystick())),
        ),
      ),
    );
    await tester.pump();

    final joystick = find.byType(TeleopJoystick);
    expect(joystick, findsOneWidget);

    await tester.drag(joystick, const Offset(0, -40));
    await tester.pump();
    expect(tester.takeException(), isNull);

    final publishes =
        fake.transport.sent.where((m) => m['op'] == 'publish').toList();
    expect(publishes, isNotEmpty, reason: 'drag should command the robot');
    final advertise =
        fake.transport.sent.firstWhere((m) => m['op'] == 'advertise');
    expect(advertise['type'], 'geometry_msgs/msg/Twist');
    expect(advertise['topic'], '/cmd_vel');

    // Releasing must send an all-zero Twist so the robot stops.
    final last = publishes.last['msg']! as Map<String, Object?>;
    expect((last['linear']! as Map)['x'], 0.0);
    expect((last['angular']! as Map)['z'], 0.0);
  });

  testWidgets('RosLaserScanView paints with and without data', (tester) async {
    final fake = fakeClient();
    addTearDown(fake.client.close);
    await tester.pumpWidget(
      MaterialApp(
        home: RosConnection.withClient(
          client: fake.client,
          child: const Scaffold(
            body: SizedBox(width: 300, height: 300, child: RosLaserScanView()),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(RosLaserScanView), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Non-finite and out-of-range beams must be skipped, not plotted at the
    // origin. Infinity is injected as the raw literal a Python bridge emits,
    // since jsonEncode cannot represent it.
    fake.transport.emitRaw('{"op":"publish","topic":"/scan","msg":'
        '{"angle_min":-1.5,"angle_increment":0.1,'
        '"ranges":[1.0,Infinity,2.0,NaN,-1.0,500.0]}}');
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
