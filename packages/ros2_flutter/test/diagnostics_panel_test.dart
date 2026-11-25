// Deprecated in Flutter 3.50 for package:material_ui, a separate copy whose
// widgets lose the theme and Material of apps still on this import.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ros2_flutter/ros2_flutter.dart';

import 'support/fake_client.dart';

/// Stands in for `ros2_msgs_common`'s `DiagnosticArray`, which this package
/// does not depend on: the panel only ever sees what `toEntries` returns.
class TestArray {
  TestArray(this.status);
  factory TestArray.fromJson(Map<String, Object?> json) => TestArray([
        for (final s in (json['status'] as List? ?? const []))
          (s as Map).cast<String, Object?>(),
      ]);
  final List<Map<String, Object?>> status;
}

List<RosDiagnosticEntry> toEntries(TestArray a) => [
      for (final s in a.status)
        RosDiagnosticEntry(
          name: s['name']! as String,
          level: RosDiagnosticLevel.fromByte(s['level']! as int),
          message: s['message'] as String? ?? '',
          hardwareId: s['hardware_id'] as String? ?? '',
          values: [
            for (final kv in (s['values'] as List? ?? const []))
              (
                key: (kv as Map)['key']! as String,
                value: kv['value']! as String
              ),
          ],
        ),
    ];

Map<String, Object?> array(List<Map<String, Object?>> status) => {
      'header': {
        'stamp': {'sec': 0, 'nanosec': 0},
        'frame_id': '',
      },
      'status': status,
    };

Map<String, Object?> status(String name, int level,
        {String message = '', List<(String, String)> values = const []}) =>
    {
      'name': name,
      'level': level,
      'message': message,
      'hardware_id': '',
      'values': [
        for (final (k, v) in values) {'key': k, 'value': v},
      ],
    };

void main() {
  setUpAll(() {
    registerStandardMessages();
    MessageRegistry.register(MessageCodec<TestArray>(
      rosType: 'diagnostic_msgs/msg/DiagnosticArray',
      fromJson: TestArray.fromJson,
      toJson: (_) => throw UnimplementedError(),
    ));
  });

  test('fromByte follows DiagnosticStatus, and distrusts unknown values', () {
    expect(RosDiagnosticLevel.fromByte(0), RosDiagnosticLevel.ok);
    expect(RosDiagnosticLevel.fromByte(1), RosDiagnosticLevel.warn);
    expect(RosDiagnosticLevel.fromByte(2), RosDiagnosticLevel.error);
    expect(RosDiagnosticLevel.fromByte(3), RosDiagnosticLevel.stale);
    expect(RosDiagnosticLevel.fromByte(7), RosDiagnosticLevel.stale);
  });

  group('RosDiagnosticsPanel', () {
    late FakeTransport transport;
    late Ros2Client client;

    setUp(() => (:client, :transport) = fakeClient());
    tearDown(() => client.close());

    Future<void> pumpPanel(WidgetTester tester,
        {String topic = '/diagnostics',
        Duration? staleAfter = const Duration(seconds: 5)}) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RosConnection.withClient(
            client: client,
            child: RosDiagnosticsPanel<TestArray>(
              topic: topic,
              staleAfter: staleAfter,
              toEntries: toEntries,
            ),
          ),
        ),
      ));
      await tester.pump();
    }

    Future<void> report(WidgetTester tester, List<Map<String, Object?>> s,
        {String topic = '/diagnostics'}) async {
      transport.publish(topic, array(s));
      // Delivery takes a few microtask hops, so the panel's setState lands
      // after the first frame; the second one renders it.
      await tester.pump();
      await tester.pump();
    }

    /// Entry names top to bottom.
    List<String> order(WidgetTester tester) => [
          for (final t in tester.widgetList<Text>(find.descendant(
              of: find.byType(ListView), matching: find.byType(Text))))
            if (const {'lidar', 'motors', 'battery', 'camera'}.contains(t.data))
              t.data!,
        ];

    IconData iconOf(WidgetTester tester, String name) => tester
        .widget<Icon>(find
            .descendant(
                of: find.ancestor(
                    of: find.text(name), matching: find.byType(ListTile)),
                matching: find.byType(Icon))
            .first)
        .icon!;

    testWidgets('subscribes to /diagnostics with the message type',
        (tester) async {
      await pumpPanel(tester);
      final sub = transport.sent.singleWhere(
          (f) => f['op'] == 'subscribe' && f['topic'] == '/diagnostics');
      expect(sub['type'], 'diagnostic_msgs/msg/DiagnosticArray');
      // rosbridge 4.2.1 drops every DiagnosticArray it is asked for in CBOR.
      expect(sub['compression'], 'none');
      expect(find.text('No diagnostics received yet'), findsOneWidget);
    });

    testWidgets('keeps every node\'s report, worst first', (tester) async {
      await pumpPanel(tester);
      // Two nodes, each publishing only its own statuses.
      await report(tester, [status('lidar', 0), status('motors', 1)]);
      await report(tester, [status('battery', 2, message: 'Low')]);

      expect(order(tester), ['battery', 'motors', 'lidar']);
      expect(find.text('Low'), findsOneWidget);

      // A later report replaces that component's entry, and nothing else.
      await report(tester, [status('battery', 0, message: 'Charging')]);
      expect(find.text('Low'), findsNothing);
      expect(order(tester), ['motors', 'battery', 'lidar']);
    });

    testWidgets('a component that goes quiet turns stale; the others do not',
        (tester) async {
      await pumpPanel(tester);
      await report(tester, [status('lidar', 0), status('motors', 0)]);

      // Motors keeps reporting every second; lidar never does again.
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(seconds: 1));
        // Checked just before each report, when motors is at its oldest: a
        // timer that a report failed to reset would show here.
        expect(iconOf(tester, 'motors'), Icons.check_circle,
            reason: 'at ${i + 1} s');
        await report(tester, [status('motors', 0)]);
      }
      expect(iconOf(tester, 'lidar'), Icons.help);
      expect(iconOf(tester, 'motors'), Icons.check_circle);
      expect(order(tester), ['lidar', 'motors']);
      expect(find.textContaining('No report for a while'), findsOneWidget);

      // It recovers the moment it reports again.
      await report(tester, [status('lidar', 0)]);
      expect(iconOf(tester, 'lidar'), Icons.check_circle);
    });

    testWidgets('with staleAfter null the last report stands', (tester) async {
      await pumpPanel(tester, staleAfter: null);
      await report(tester, [status('lidar', 0)]);
      await tester.pump(const Duration(minutes: 5));
      expect(iconOf(tester, 'lidar'), Icons.check_circle);
    });

    testWidgets('expands to show hardware values', (tester) async {
      await pumpPanel(tester);
      await report(tester, [
        status('battery', 1, values: [('Voltage', '11.2 V'), ('Cells', '3')]),
      ]);
      expect(find.text('11.2 V'), findsNothing);
      await tester.tap(find.text('battery'));
      await tester.pumpAndSettle();
      expect(find.text('Voltage'), findsOneWidget);
      expect(find.text('11.2 V'), findsOneWidget);
    });

    testWidgets('an expanded tile stays expanded when the order changes',
        (tester) async {
      await pumpPanel(tester);
      await report(tester, [
        status('battery', 1, values: [('Voltage', '11.2 V')]),
        status('lidar', 0, values: [('Rate', '10 Hz')]),
      ]);
      await tester.tap(find.text('battery'));
      await tester.pumpAndSettle();
      expect(find.text('11.2 V'), findsOneWidget);

      // lidar fails and sorts above battery.
      await report(tester, [
        status('lidar', 2, values: [('Rate', '0 Hz')]),
      ]);
      await tester.pumpAndSettle();
      expect(order(tester), ['lidar', 'battery']);
      expect(find.text('11.2 V'), findsOneWidget,
          reason: 'battery collapsed when it moved');
      expect(find.text('0 Hz'), findsNothing,
          reason: 'lidar inherited battery\'s expansion');
    });

    testWidgets('a new topic starts from nothing', (tester) async {
      await pumpPanel(tester);
      await report(tester, [status('lidar', 2)]);
      await pumpPanel(tester, topic: '/diagnostics_agg');

      expect(
          transport.sent.where(
              (f) => f['op'] == 'unsubscribe' && f['topic'] == '/diagnostics'),
          hasLength(1));
      expect(find.text('lidar'), findsNothing);
      await report(tester, [status('camera', 0)], topic: '/diagnostics_agg');
      expect(order(tester), ['camera']);
    });

    testWidgets('leaves no timers behind', (tester) async {
      await pumpPanel(tester);
      await report(tester, [status('lidar', 0)]);
      await tester.pumpWidget(const SizedBox());
      // The test binding fails the test if a timer is still pending here.
    });
  });
}
