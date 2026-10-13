import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ros2_flutter/ros2_flutter.dart';

import 'support/fake_client.dart';

double forward(Map<String, Object?> twist) =>
    ((twist['linear']! as Map)['x']! as num).toDouble();
double turn(Map<String, Object?> twist) =>
    ((twist['angular']! as Map)['z']! as num).toDouble();
bool moving(Map<String, Object?> twist) =>
    forward(twist) != 0 || turn(twist) != 0;

Widget app(Ros2Client client, Widget child,
        {bool closeClientOnDispose = false}) =>
    MaterialApp(
      home: RosConnection.withClient(
        client: client,
        closeClientOnDispose: closeClientOnDispose,
        child: Scaffold(body: Center(child: child)),
      ),
    );

/// Presses the joystick and pushes it forward.
Future<TestGesture> holdStick(WidgetTester tester) async {
  final gesture =
      await tester.startGesture(tester.getCenter(find.byType(TeleopJoystick)));
  await gesture.moveBy(const Offset(0, -40));
  await gesture.moveBy(const Offset(0, -40));
  await tester.pump(const Duration(milliseconds: 50));
  return gesture;
}

void background(WidgetTester tester) {
  for (final state in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}

void main() {
  setUpAll(registerStandardMessages);
  tearDown(() => TestWidgetsFlutterBinding.instance
      .handleAppLifecycleStateChanged(AppLifecycleState.resumed));

  group('swapping robots mid-drive', () {
    for (final close in [true, false]) {
      testWidgets(
          'stops the old robot and does not drive the new one '
          '(closeClientOnDispose: $close)', (tester) async {
        final a = fakeClient(), b = fakeClient();
        addTearDown(a.client.close);
        addTearDown(b.client.close);

        await tester.pumpWidget(
            app(a.client, const TeleopJoystick(), closeClientOnDispose: close));
        await tester.pump();
        final gesture = await holdStick(tester);
        expect(a.transport.published('/cmd_vel').last, predicate(moving));
        a.transport.sent.clear();

        await tester.pumpWidget(
            app(b.client, const TeleopJoystick(), closeClientOnDispose: close));
        await tester.pump(const Duration(milliseconds: 300));
        // The finger is still on the stick and keeps moving.
        await gesture.moveBy(const Offset(5, -5));
        await tester.pump(const Duration(milliseconds: 300));

        final toA = a.transport.published('/cmd_vel');
        expect(toA, isNotEmpty, reason: 'the old robot never got a stop');
        expect(toA.where(moving), isEmpty);
        expect(b.transport.published('/cmd_vel').where(moving), isEmpty,
            reason: 'a command aimed at one robot drove the other');

        await gesture.up();
        await tester.pumpWidget(const SizedBox());
      });
    }

    testWidgets('the new robot moves once the stick is pressed again',
        (tester) async {
      final a = fakeClient(), b = fakeClient();
      addTearDown(a.client.close);
      addTearDown(b.client.close);
      await tester.pumpWidget(app(a.client, const TeleopJoystick()));
      await tester.pump();
      final first = await holdStick(tester);
      await tester.pumpWidget(app(b.client, const TeleopJoystick()));
      await tester.pump();
      await first.up();
      await tester.pump();

      final second = await holdStick(tester);
      expect(b.transport.published('/cmd_vel').where(moving), isNotEmpty);
      await second.up();
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('TeleopPad stops the old robot and not the new one',
        (tester) async {
      final a = fakeClient(), b = fakeClient();
      addTearDown(a.client.close);
      addTearDown(b.client.close);
      await tester.pumpWidget(
          app(a.client, const TeleopPad(), closeClientOnDispose: true));
      await tester.pump();
      final finger = await tester
          .startGesture(tester.getCenter(find.byIcon(Icons.arrow_upward)));
      await tester.pump(const Duration(milliseconds: 50));
      a.transport.sent.clear();

      await tester.pumpWidget(
          app(b.client, const TeleopPad(), closeClientOnDispose: true));
      await tester.pump(const Duration(milliseconds: 500));

      final toA = a.transport.published('/cmd_vel');
      expect(toA, isNotEmpty);
      expect(toA.where(moving), isEmpty);
      expect(b.transport.published('/cmd_vel').where(moving), isEmpty);
      await finger.up();
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('leaving the foreground mid-drive', () {
    testWidgets('TeleopJoystick stops and stays stopped', (tester) async {
      final fake = fakeClient();
      addTearDown(fake.client.close);
      await tester.pumpWidget(app(fake.client, const TeleopJoystick()));
      await tester.pump();
      final gesture = await holdStick(tester);
      fake.transport.sent.clear();

      background(tester);
      await tester.pump(const Duration(seconds: 1));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      // The platform never cancelled the pointer, so the drag carries on.
      await gesture.moveBy(const Offset(0, -5));
      await tester.pump(const Duration(milliseconds: 300));

      final sent = fake.transport.published('/cmd_vel');
      expect(sent, isNotEmpty, reason: 'no stop was published');
      expect(sent.where(moving), isEmpty);
      await gesture.up();
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('TeleopPad stops', (tester) async {
      final fake = fakeClient();
      addTearDown(fake.client.close);
      await tester.pumpWidget(app(fake.client, const TeleopPad()));
      await tester.pump();
      final finger = await tester
          .startGesture(tester.getCenter(find.byIcon(Icons.arrow_upward)));
      await tester.pump(const Duration(milliseconds: 50));
      fake.transport.sent.clear();

      background(tester);
      await tester.pump(const Duration(seconds: 1));

      final sent = fake.transport.published('/cmd_vel');
      expect(sent, isNotEmpty, reason: 'no stop was published');
      expect(sent.where(moving), isEmpty);
      await finger.up();
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('TeleopPad with two fingers', () {
    testWidgets('lifting one hands back to the button still held',
        (tester) async {
      final fake = fakeClient();
      addTearDown(fake.client.close);
      await tester.pumpWidget(app(fake.client, const TeleopPad()));
      await tester.pump();
      final a = await tester.startGesture(
          tester.getCenter(find.byIcon(Icons.arrow_upward)),
          pointer: 1);
      await tester.pump(const Duration(milliseconds: 50));
      final b = await tester.startGesture(
          tester.getCenter(find.byIcon(Icons.rotate_left)),
          pointer: 2);
      await tester.pump(const Duration(milliseconds: 50));
      expect(turn(fake.transport.published('/cmd_vel').last), greaterThan(0),
          reason: 'the latest press drives');

      await b.up();
      fake.transport.sent.clear();
      await tester.pump(const Duration(milliseconds: 300));
      final sent = fake.transport.published('/cmd_vel');
      expect(sent, isNotEmpty);
      expect(sent.every((t) => forward(t) > 0 && turn(t) == 0), isTrue,
          reason: 'forward is still held');

      await a.up();
      fake.transport.sent.clear();
      await tester.pump(const Duration(milliseconds: 300));
      expect(fake.transport.published('/cmd_vel').where(moving), isEmpty);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the stop button stops whatever is held', (tester) async {
      final fake = fakeClient();
      addTearDown(fake.client.close);
      await tester.pumpWidget(app(fake.client, const TeleopPad()));
      await tester.pump();
      final a = await tester.startGesture(
          tester.getCenter(find.byIcon(Icons.arrow_upward)),
          pointer: 1);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byIcon(Icons.stop));
      fake.transport.sent.clear();
      await tester.pump(const Duration(milliseconds: 300));
      expect(fake.transport.published('/cmd_vel').where(moving), isEmpty);
      await a.up();
      await tester.pumpWidget(const SizedBox());
    });
  });

  testWidgets('a new publishRate applies while the stick is held',
      (tester) async {
    final fake = fakeClient();
    addTearDown(fake.client.close);
    await tester.pumpWidget(app(fake.client, const TeleopJoystick()));
    await tester.pump();
    final gesture = await holdStick(tester);

    await tester.pumpWidget(app(fake.client,
        const TeleopJoystick(publishRate: Duration(milliseconds: 20))));
    fake.transport.sent.clear();
    await tester.pump(const Duration(milliseconds: 200));
    expect(fake.transport.published('/cmd_vel').where(moving).length,
        greaterThanOrEqualTo(9),
        reason: '50 Hz for 200 ms, not the old 10 Hz');
    await gesture.up();
    await tester.pumpWidget(const SizedBox());
  });
}
