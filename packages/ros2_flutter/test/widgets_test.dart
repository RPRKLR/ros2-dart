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
  Future<void> connect() async {
    // A stalled link refuses reconnects too; without this the client
    // reconnects instantly and the outage never actually happens.
    if (!up) throw StateError('socket is gone');
  }

  /// Set false to simulate a stalled link: a real transport throws when the
  /// socket is gone, which is what makes the client buffer or drop.
  bool up = true;

  @override
  void send(String data) {
    if (!up) throw StateError('socket is gone');
    sent.add(jsonDecode(data) as Map<String, Object?>);
  }

  @override
  Future<void> close() async {
    if (!_incoming.isClosed) await _incoming.close();
  }

  void publish(String topic, Map<String, Object?> msg) =>
      _incoming.add(jsonEncode({'op': 'publish', 'topic': topic, 'msg': msg}));

  /// Pushes a frame verbatim, for wire forms `jsonEncode` cannot produce.
  void emitRaw(String frame) => _incoming.add(frame);

  /// Simulates the socket dying, which is what drives the client's reconnect
  /// loop and therefore its outbox replay.
  void drop() {
    up = false;
    _incoming.addError(StateError('connection lost'));
  }
}

/// A client wired to [_FakeTransport], connected and ready.
({Ros2Client client, _FakeTransport transport}) fakeClient(
    {ReconnectPolicy policy = ReconnectPolicy.none}) {
  final transport = _FakeTransport();
  final client = Ros2Client(
    Uri.parse('ws://fake:9090'),
    transportFactory: (_) => transport,
    reconnectPolicy: policy,
  );
  return (client: client, transport: transport);
}

/// A `tf2_msgs/msg/TFMessage` wire frame with a single transform.
Map<String, Object?> tfFrame(
  String parent,
  String child, {
  double x = 0,
  double y = 0,
  int sec = 0,
}) =>
    {
      'transforms': [
        {
          'header': {
            'stamp': {'sec': sec, 'nanosec': 0},
            'frame_id': parent,
          },
          'child_frame_id': child,
          'transform': {
            'translation': {'x': x, 'y': y, 'z': 0.0},
            'rotation': {'x': 0.0, 'y': 0.0, 'z': 0.0, 'w': 1.0},
          },
        },
      ],
    };

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

  testWidgets('TfFrameBuilder resolves a transform once /tf arrives',
      (tester) async {
    final fake = fakeClient();
    addTearDown(fake.client.close);
    RosTransform? seen;

    await tester.pumpWidget(
      MaterialApp(
        home: RosConnection.withClient(
          client: fake.client,
          child: TfFrameBuilder(
            targetFrame: 'map',
            sourceFrame: 'base_link',
            builder: (context, transform) {
              seen = transform;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(seen, isNull, reason: 'nothing is known before /tf arrives');

    // Both topics must be subscribed, and /tf_static needs transient-local
    // durability or a late joiner never receives the latched frames.
    final subs = fake.transport.sent.where((m) => m['op'] == 'subscribe');
    expect(subs.map((m) => m['topic']), containsAll(['/tf', '/tf_static']));
    final staticSub = subs.firstWhere((m) => m['topic'] == '/tf_static');
    expect((staticSub['qos']! as Map)['durability'], 'transient_local');

    // map -> odom static, odom -> base_link dynamic: the lookup has to walk
    // the chain and compose both.
    fake.transport.publish('/tf_static', tfFrame('map', 'odom', x: 1.0));
    fake.transport.publish('/tf', tfFrame('odom', 'base_link', y: 2.0));
    await tester.pump();
    await tester.pump();

    expect(seen, isNotNull);
    expect(seen!.translation.x, closeTo(1.0, 1e-9));
    expect(seen!.translation.y, closeTo(2.0, 1e-9));
  });

  testWidgets('TfFrameBuilder coalesces a burst of updates into one rebuild',
      (tester) async {
    final fake = fakeClient();
    addTearDown(fake.client.close);
    var builds = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: RosConnection.withClient(
          client: fake.client,
          child: TfFrameBuilder(
            targetFrame: 'odom',
            sourceFrame: 'base_link',
            builder: (context, transform) {
              builds++;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pump();
    final before = builds;

    // 20 updates between two frames must not cause 20 rebuilds; /tf on a real
    // robot runs far faster than the display refreshes.
    for (var i = 0; i < 20; i++) {
      fake.transport.publish('/tf', tfFrame('odom', 'base_link', x: i * 0.1));
    }
    await tester.pump();
    await tester.pump();

    expect(builds - before, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TfFrameBuilder reports why a lookup fails', (tester) async {
    final fake = fakeClient();
    addTearDown(fake.client.close);
    final errors = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: RosConnection.withClient(
          client: fake.client,
          child: TfFrameBuilder(
            targetFrame: 'map',
            sourceFrame: 'camera_link',
            onError: (error) => errors.add(error.message),
            builder: (context, transform) => const SizedBox(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(errors, isNotEmpty);
    expect(errors.first, contains('camera_link'));

    // Settle the tree first: the message names the known frames, so it
    // legitimately changes while new frames are still appearing.
    fake.transport.publish('/tf', tfFrame('odom', 'base_link'));
    await tester.pump();
    await tester.pump();
    final count = errors.length;

    // Once the tree stops changing, repeated failures for the same reason
    // must not spam the callback — /tf would otherwise log 100x a second.
    for (var i = 0; i < 20; i++) {
      fake.transport.publish('/tf', tfFrame('odom', 'base_link', x: i * 0.1));
    }
    await tester.pump();
    await tester.pump();
    expect(errors.length, count);
    expect(errors.last, contains('camera_link'));
  });

  testWidgets('one TfListener is shared across the subtree', (tester) async {
    final fake = fakeClient();
    addTearDown(fake.client.close);
    final listeners = <TfListener>{};

    await tester.pumpWidget(
      MaterialApp(
        home: RosConnection.withClient(
          client: fake.client,
          child: Column(
            children: [
              for (var i = 0; i < 3; i++)
                Builder(builder: (context) {
                  listeners.add(RosConnection.tfOf(context));
                  return const SizedBox();
                }),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(listeners, hasLength(1));
    final tfSubs = fake.transport.sent
        .where((m) => m['op'] == 'subscribe' && m['topic'] == '/tf');
    expect(tfSubs, hasLength(1), reason: '/tf must be subscribed exactly once');
  });

  testWidgets('teleop never replays stale motion after the link recovers',
      (tester) async {
    // The runaway case: the operator holds the stick, the link stalls, they
    // let go, and the link comes back. Buffered velocity commands would be
    // handed to the robot in one burst after the operator already released.
    // A policy that retries quickly, so the reconnect (and therefore the
    // outbox replay) happens inside the test.
    final fake = fakeClient(
        policy: const ReconnectPolicy(
            initialDelay: Duration(milliseconds: 10),
            maxDelay: Duration(milliseconds: 10),
            jitter: 0));
    addTearDown(fake.client.close);

    await tester.pumpWidget(
      MaterialApp(
        home: RosConnection.withClient(
          client: fake.client,
          child: const Scaffold(body: TeleopJoystick()),
        ),
      ),
    );
    await tester.pump();

    final joystick = find.byType(TeleopJoystick);
    await tester.drag(joystick, const Offset(0, -40));
    await tester.pump();
    expect(fake.transport.sent.where((m) => m['op'] == 'publish'), isNotEmpty,
        reason: 'sanity: driving publishes while connected');

    // The link dies while the operator is still holding the stick.
    fake.transport.drop();
    await tester.pump();
    final before = fake.transport.sent.length;

    for (var i = 0; i < 40; i++) {
      await tester.drag(joystick, const Offset(0, -40));
      await tester.pump(const Duration(milliseconds: 60));
    }

    // The operator lets go, then the link recovers and the client replays
    // whatever it buffered.
    await tester.tapAt(tester.getCenter(joystick));
    await tester.pump();
    fake.transport.up = true;
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final replayed = fake.transport.sent
        .skip(before)
        .where((m) => m['op'] == 'publish')
        .map((m) => m['msg']! as Map<String, Object?>)
        .toList();
    final moving = replayed.where((msg) {
      final linear = msg['linear']! as Map<String, Object?>;
      final angular = msg['angular']! as Map<String, Object?>;
      return (linear['x']! as num) != 0 || (angular['z']! as num) != 0;
    });

    expect(moving, isEmpty,
        reason: 'a motion command buffered while offline must never be '
            'replayed: the operator has already let go');
  });

  testWidgets('teleop rebinds when the topic changes', (tester) async {
    final fake = fakeClient();
    addTearDown(fake.client.close);

    Widget app(String topic) => MaterialApp(
          home: RosConnection.withClient(
            client: fake.client,
            child: Scaffold(body: TeleopJoystick(topic: topic)),
          ),
        );

    await tester.pumpWidget(app('/robot_a/cmd_vel'));
    await tester.pump();
    await tester.drag(find.byType(TeleopJoystick), const Offset(0, -40));
    await tester.pump();

    // A robot selector swaps the topic in place.
    await tester.pumpWidget(app('/robot_b/cmd_vel'));
    await tester.pump();
    final afterSwap = fake.transport.sent.length;
    await tester.drag(find.byType(TeleopJoystick), const Offset(0, -40));
    await tester.pump();

    final topics = fake.transport.sent
        .skip(afterSwap)
        .where((m) => m['op'] == 'publish')
        .map((m) => m['topic'])
        .toSet();
    // Otherwise the UI names robot B while robot A is the one that moves.
    expect(topics, {'/robot_b/cmd_vel'});

    // And the robot being left behind gets a stop.
    final stopToA = fake.transport.sent
        .where((m) => m['op'] == 'publish' && m['topic'] == '/robot_a/cmd_vel')
        .last['msg']! as Map<String, Object?>;
    expect((stopToA['linear']! as Map)['x'], 0.0);
  });

  testWidgets('RosCameraView keeps frames out of the global ImageCache',
      (tester) async {
    final fake = fakeClient();
    addTearDown(fake.client.close);
    imageCache.clear();
    imageCache.clearLiveImages();

    await tester.pumpWidget(
      MaterialApp(
        home: RosConnection.withClient(
          client: fake.client,
          child: const Scaffold(
            body: SizedBox(width: 64, height: 64, child: RosCameraView()),
          ),
        ),
      ),
    );
    await tester.pump();

    // A 1x1 PNG, republished as distinct byte lists the way a camera would.
    final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==');
    for (var i = 0; i < 20; i++) {
      fake.transport.publish('/camera/image_raw/compressed',
          {'format': 'png', 'data': base64Encode(png)});
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pump(const Duration(milliseconds: 50));

    // Image.memory keys the global cache on byte-list identity, so every frame
    // is a new entry and a video stream evicts everything else the app cached.
    expect(imageCache.currentSize, 0,
        reason: 'camera frames are never re-fetched and must not be cached');
    expect(tester.takeException(), isNull);
  });

  testWidgets('swapping a client closes the old one when asked',
      (tester) async {
    final first = fakeClient();
    final second = fakeClient();
    addTearDown(second.client.close);

    Widget app(Ros2Client client) => MaterialApp(
          home: RosConnection.withClient(
            client: client,
            closeClientOnDispose: true,
            child: const SizedBox(),
          ),
        );

    await tester.pumpWidget(app(first.client));
    await tester.pump();
    expect(first.client.state, isNot(RosConnectionState.closed));

    await tester.pumpWidget(app(second.client));
    await tester.pump();

    // dispose() honours closeClientOnDispose; didUpdateWidget used not to, so
    // the old socket, its reconnect timer and every subscription stayed alive
    // for the life of the app.
    expect(first.client.state, RosConnectionState.closed);
  });
}
