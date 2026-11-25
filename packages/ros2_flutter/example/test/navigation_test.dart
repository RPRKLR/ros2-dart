import 'dart:async';
import 'dart:convert';

// Deprecated in Flutter 3.50 for package:material_ui, a separate copy whose
// widgets lose the theme and Material of apps still on this import.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ros2_flutter/ros2_flutter.dart';
import 'package:ros2_flutter_example/main.dart';
import 'package:ros2_flutter_example/navigation.dart';
import 'package:ros2_msgs_common/ros2_msgs_common.dart';

final class _FakeTransport implements RosTransport {
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

  void reply(Map<String, Object?> frame) => _incoming.add(jsonEncode(frame));

  /// The link dying under the client, as a dropped Wi-Fi does.
  void drop() => _incoming.addError(StateError('link lost'));

  List<Map<String, Object?>> op(String op) => [
        for (final f in sent)
          if (f['op'] == op) f
      ];
}

const _pose = PoseStamped(
  header: Header(frameId: 'map'),
  pose: Pose(position: Point(x: 1.5, y: -2)),
);

void main() {
  setUpAll(() {
    registerStandardMessages();
    registerLyricalMessages();
  });

  late _FakeTransport transport;
  late Ros2Client client;
  late NavigationSession session;

  setUp(() async {
    transport = _FakeTransport();
    client = Ros2Client(Uri.parse('ws://fake:9090'),
        transportFactory: (_) => transport,
        reconnectPolicy: ReconnectPolicy.none);
    await client.connect();
    session = NavigationSession(client);
  });
  tearDown(() async {
    session.dispose();
    await client.close();
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  String goalId() => transport.op('send_action_goal').last['id']! as String;

  void result(String id, int status, Map<String, Object?> values) =>
      transport.reply({
        'op': 'action_result',
        'id': id,
        'action': '/navigate_to_pose',
        'status': status,
        'result': true,
        'values': values,
      });

  test('sends NavigateToPose with the picked pose', () async {
    session.navigateTo(_pose);
    await settle();
    final goal = transport.op('send_action_goal').single;
    expect(goal['action'], '/navigate_to_pose');
    expect(goal['action_type'], 'nav2_msgs/action/NavigateToPose');
    final args = goal['args']! as Map;
    expect((args['pose'] as Map)['header'], containsPair('frame_id', 'map'));
    expect(session.phase, NavigationPhase.navigating);
    expect(session.goal, _pose);
  });

  test('shows feedback, then arrives', () async {
    session.navigateTo(_pose);
    await settle();
    transport.reply({
      'op': 'action_feedback',
      'id': goalId(),
      'action': '/navigate_to_pose',
      'values': {'distance_remaining': 3.25, 'number_of_recoveries': 1},
    });
    await settle();
    expect(session.feedback!.distanceRemaining, 3.25);

    result(goalId(), GoalStatus.succeeded.value, const {'error_code': 0});
    await settle();
    expect(session.phase, NavigationPhase.succeeded);
    expect(session.goal, isNull);
  });

  test('an aborted goal says why, from Nav2\'s result', () async {
    session.navigateTo(_pose);
    await settle();
    result(goalId(), GoalStatus.aborted.value,
        const {'error_code': 204, 'error_msg': 'Goal is in collision'});
    await settle();
    expect(session.phase, NavigationPhase.failed);
    expect(session.failure, contains('Goal is in collision'));
    expect(session.failure, contains('204'));
  });

  test('a newer goal is not overwritten by the one it preempted', () async {
    session.navigateTo(_pose);
    await settle();
    final first = goalId();
    const second = PoseStamped(
        header: Header(frameId: 'map'), pose: Pose(position: Point(x: 4)));
    session.navigateTo(second);
    await settle();

    // Nav2 aborts the preempted goal once the new one is running.
    result(first, GoalStatus.aborted.value, const {'error_code': 0});
    await settle();
    expect(session.phase, NavigationPhase.navigating);
    expect(session.goal, second);
  });

  test('a lost link keeps the goal, and says the robot may still drive',
      () async {
    session.navigateTo(_pose);
    await settle();
    transport.drop();
    await settle();
    await settle();
    expect(session.phase, NavigationPhase.failed);
    expect(session.failure, contains('may still be driving'));
    expect(session.goal, _pose);
  });

  test('disposing the session cancels the goal', () async {
    final own = NavigationSession(client)..navigateTo(_pose);
    await settle();
    final id = goalId();
    own.dispose();
    await settle();
    expect(transport.op('cancel_action_goal').single['id'], id);
  });

  test('clears both costmaps, and names the one that refused', () async {
    final outcome = session.clearCostmaps();
    await settle();
    final calls = transport.op('call_service');
    expect([
      for (final c in calls) c['service']
    ], [
      '/global_costmap/clear_entirely_global_costmap',
      '/local_costmap/clear_entirely_local_costmap',
    ]);
    // Lyrical's request: a plugin list, empty for every layer.
    expect(calls.first['args'], {'plugins': <Object?>[]});
    for (final (i, ok) in [(0, true), (1, false)]) {
      transport.reply({
        'op': 'service_response',
        'id': calls[i]['id'],
        'service': calls[i]['service'],
        'result': true,
        'values': {'success': ok},
      });
    }
    expect(await outcome, 'local refused');
  });

  testWidgets('the Navigate tab shows the map and how to pick a goal',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: RosConnection.withClient(
            client: client, child: const ControlPanel())));
    await tester.pump();
    await tester.tap(find.text('Navigate'));
    await tester.pump();
    expect(find.byType(RosMapView), findsOneWidget);
    expect(find.textContaining('Long-press the map'), findsOneWidget);

    await tester.tap(find.text('Health'));
    await tester.pump();
    expect(find.text('No diagnostics received yet'), findsOneWidget);
  });
}
