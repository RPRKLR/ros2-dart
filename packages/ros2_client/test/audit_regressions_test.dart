// Regressions for bugs found by auditing the client against rosbridge 2.0.8.
// Each was confirmed on a live bridge before it was fixed; these pin the
// client-side half of the behaviour.
import 'dart:async';

import 'package:ros2_client/ros2_client.dart';
import 'package:test/test.dart';

import 'fake_bridge.dart';

Future<void> pump() => Future<void>.delayed(Duration.zero);

/// A farm whose first [failures] connection attempts are refused.
({Ros2Client client, FakeBridgeFarm farm}) flakyClient(int failures) {
  final farm = FakeBridgeFarm();
  final client = Ros2Client(
    Uri.parse('ws://fake:9090'),
    transportFactory: (_) {
      final bridge = farm.create();
      if (farm.connectAttempts <= failures) bridge.failConnect = true;
      return bridge;
    },
    reconnectPolicy: const ReconnectPolicy(
        initialDelay: Duration(milliseconds: 5), jitter: 0),
  );
  return (client: client, farm: farm);
}

/// Every command any bridge in [farm] received with [op].
List<Map<String, Object?>> receivedOf(FakeBridgeFarm farm, String op) => [
      for (final bridge in farm.bridges) ...bridge.opsOf(op),
    ];

void main() {
  setUpAll(registerStandardMessages);
  probeTests();

  group('a request reported as failed is never sent', () {
    test('a call and a goal failed by a reconnect attempt', () async {
      final (:client, :farm) = flakyClient(2);
      addTearDown(client.close);

      final call = client.callServiceJson('/reset_odometry', {});
      final goal = client.sendGoal<JsonMessage, JsonMessage, JsonMessage>(
          '/navigate', const JsonMessage('', {}),
          codec: _jsonAction);
      unawaited(client.connect().catchError((Object _) {}));

      await expectLater(call, throwsA(isA<ServiceCallException>()));
      await expectLater(goal.result, throwsA(isA<ActionFailedException>()));
      await client.waitUntilConnected(timeout: const Duration(seconds: 2));
      await pump();

      expect(receivedOf(farm, 'call_service'), isEmpty,
          reason: 'the caller was told this call failed');
      expect(receivedOf(farm, 'send_action_goal'), isEmpty,
          reason: 'the caller was told this goal failed');
    });

    test('a call that timed out while offline', () async {
      final farm = FakeBridgeFarm();
      final client = Ros2Client(Uri.parse('ws://fake:9090'),
          transportFactory: (_) => farm.create(),
          reconnectPolicy: const ReconnectPolicy(
              initialDelay: Duration(milliseconds: 200), jitter: 0));
      addTearDown(client.close);
      await client.connect();
      farm.current.drop();
      await pump();

      await expectLater(
          client.callServiceJson('/reset_odometry', {},
              timeout: const Duration(milliseconds: 20)),
          throwsA(isA<TimeoutException>()));
      await client.waitUntilConnected(timeout: const Duration(seconds: 2));
      await pump();

      expect(farm.current.opsOf('call_service'), isEmpty);
    });

    test('a goal that timed out while offline', () async {
      final farm = FakeBridgeFarm();
      final client = Ros2Client(Uri.parse('ws://fake:9090'),
          transportFactory: (_) => farm.create(),
          reconnectPolicy: const ReconnectPolicy(
              initialDelay: Duration(milliseconds: 200), jitter: 0));
      addTearDown(client.close);
      await client.connect();
      farm.current.drop();
      await pump();

      final goal = client.sendGoal<JsonMessage, JsonMessage, JsonMessage>(
          '/navigate', const JsonMessage('', {}),
          codec: _jsonAction, timeout: const Duration(milliseconds: 20));
      await expectLater(goal.result, throwsA(isA<ActionFailedException>()));
      await client.waitUntilConnected(timeout: const Duration(seconds: 2));
      await pump();

      expect(farm.current.opsOf('send_action_goal'), isEmpty);
    });

    test('a call queued during a brief outage still goes out', () async {
      // The other half: withdrawing must not throw away what the outbox is
      // for. A call made while reconnecting and answered in time succeeds.
      final farm = FakeBridgeFarm();
      final client = Ros2Client(Uri.parse('ws://fake:9090'),
          transportFactory: (_) => farm.create(),
          reconnectPolicy: const ReconnectPolicy(
              initialDelay: Duration(milliseconds: 20), jitter: 0));
      addTearDown(client.close);
      await client.connect();
      farm.current.drop();
      await pump();

      final call = client.callServiceJson('/reset_odometry', {});
      await client.waitUntilConnected(timeout: const Duration(seconds: 2));
      await pump();
      expect(farm.current.opsOf('call_service'), hasLength(1));
      farm.current.respondToCall({'ok': true});
      expect(await call, {'ok': true});
    });
  });

  test('a service call tells the bridge its timeout', () async {
    // rosbridge's own default is to wait forever, and it serves one client's
    // calls in order, so one hung call blocks every later call.
    final bridge = FakeBridge();
    final client = Ros2Client(Uri.parse('ws://fake:9090'),
        transportFactory: (_) => bridge, reconnectPolicy: ReconnectPolicy.none);
    addTearDown(client.close);
    await client.connect();

    unawaited(client
        .callServiceJson('/slow', {},
            timeout: const Duration(milliseconds: 2500))
        .catchError((Object _) => <String, Object?>{}));
    await pump();
    expect(bridge.lastOf('call_service')!['timeout'], 2.5);
  });

  test('cancelling a goal leaves its timeout armed', () async {
    // A cancel can be refused, or never delivered; the timeout is then the
    // only thing that ends the wait.
    final bridge = FakeBridge();
    final client = Ros2Client(Uri.parse('ws://fake:9090'),
        transportFactory: (_) => bridge, reconnectPolicy: ReconnectPolicy.none);
    addTearDown(client.close);
    await client.connect();

    final goal = client.sendGoal<JsonMessage, JsonMessage, JsonMessage>(
        '/navigate', const JsonMessage('', {}),
        codec: _jsonAction, timeout: const Duration(milliseconds: 50));
    goal.cancel();
    await expectLater(goal.result.timeout(const Duration(seconds: 1)),
        throwsA(isA<ActionFailedException>()));
  });

  group('after close', () {
    late Ros2Client client;
    setUp(() async {
      client = Ros2Client(Uri.parse('ws://fake:9090'),
          transportFactory: (_) => FakeBridge(),
          reconnectPolicy: ReconnectPolicy.none);
      await client.connect();
      await client.close();
    });

    test('a service call fails at once instead of timing out', () async {
      final started = DateTime.now();
      await expectLater(client.callServiceJson('/x', {}),
          throwsA(isA<ServiceCallException>()));
      expect(DateTime.now().difference(started),
          lessThan(const Duration(seconds: 1)));
    });

    test('a goal fails at once instead of hanging', () async {
      final goal = client.sendGoal<JsonMessage, JsonMessage, JsonMessage>(
          '/navigate', const JsonMessage('', {}),
          codec: _jsonAction);
      await expectLater(goal.result.timeout(const Duration(seconds: 1)),
          throwsA(isA<ActionFailedException>()));
    });
  });

  group('fragment_size is connection-wide', () {
    late FakeBridgeFarm farm;
    late Ros2Client client;
    setUp(() async {
      farm = FakeBridgeFarm();
      client = Ros2Client(Uri.parse('ws://fake:9090'),
          transportFactory: (_) => farm.create(),
          reconnectPolicy: const ReconnectPolicy(
              initialDelay: Duration(milliseconds: 5), jitter: 0));
      await client.connect();
    });
    tearDown(() => client.close());

    test('refuses fragmentSize while a CBOR topic is live', () {
      client
          .subscribeJson('/big', compression: Compression.cbor)
          .listen((_) {});
      expect(
          () => client.subscribeJson('/small',
              compression: Compression.none, fragmentSize: 50000),
          throwsA(isA<ArgumentError>()
              .having((e) => e.message, 'message', contains('/big'))));
    });

    test(
        'refuses CBOR once the connection has fragmented, even after the '
        'fragmented topic is cancelled', () async {
      final sub = client
          .subscribeJson('/small',
              compression: Compression.none, fragmentSize: 50000)
          .listen((_) {});
      await sub.cancel();
      expect(() => client.subscribeJson('/big', compression: Compression.cbor),
          throwsArgumentError);
    });

    test('a reconnect without fragmented listeners clears it', () async {
      final sub = client
          .subscribeJson('/small',
              compression: Compression.none, fragmentSize: 50000)
          .listen((_) {});
      await sub.cancel();
      farm.current.drop();
      await pump();
      await client.waitUntilConnected(timeout: const Duration(seconds: 2));
      expect(
          () => client
              .subscribeJson('/big', compression: Compression.cbor)
              .listen((_) {}),
          returnsNormally);
    });

    test('JSON topics may still share a fragmented connection', () {
      client
          .subscribeJson('/small',
              compression: Compression.none, fragmentSize: 50000)
          .listen((_) {});
      expect(
          () => client
              .subscribeJson('/other', compression: Compression.none)
              .listen((_) {}),
          returnsNormally);
    });
  });

  test('warns when a second listener asks for a different QoS', () async {
    final bridge = FakeBridge();
    final client = Ros2Client(Uri.parse('ws://fake:9090'),
        transportFactory: (_) => bridge, reconnectPolicy: ReconnectPolicy.none);
    addTearDown(client.close);
    await client.connect();
    final statuses = <RosStatus>[];
    client.status.listen(statuses.add);

    client.subscribe<StringMsg>('/be').listen((_) {});
    client
        .subscribe<StringMsg>('/be', qos: QosProfile.sensorData)
        .listen((_) {});
    client.subscribe<StringMsg>('/be').listen((_) {});
    await pump();

    final warnings = statuses.where((s) => s.message.contains('QoS')).toList();
    expect(warnings, hasLength(1),
        reason: 'the sensorData listener, not the matching third one');
    expect(warnings.single.level, StatusLevel.warning);
  });

  test('a decode error in a backlogged message reaches status', () async {
    final bridge = FakeBridge();
    final client = Ros2Client(Uri.parse('ws://fake:9090'),
        transportFactory: (_) => bridge, reconnectPolicy: ReconnectPolicy.none);
    addTearDown(client.close);
    await client.connect();
    final errors = <RosStatus>[];
    client.status.where((s) => s.level == StatusLevel.error).listen(errors.add);

    final sub = client
        .subscribe<StringMsg>('/bad',
            backpressure: Backpressure.latest,
            codec: MessageCodec<StringMsg>(
                rosType: 'std_msgs/msg/String',
                fromJson: (_) => throw const FormatException('bad message'),
                toJson: (m) => m.toJson()))
        .listen((_) {});
    bridge.publish('/bad', {'data': 'live'});
    await pump();
    expect(errors, hasLength(1));

    sub.pause();
    bridge.publish('/bad', {'data': 'held'});
    await pump();
    sub.resume();
    await pump();
    expect(errors, hasLength(2),
        reason: 'the held message failed to decode as well');
    await sub.cancel();
  });
}

final _jsonAction = ActionCodec<JsonMessage, JsonMessage, JsonMessage>(
  actionType: 'test/action/Any',
  encodeGoal: (g) => g.toJson(),
  decodeFeedback: (j) => JsonMessage('', j),
  decodeResult: (j) => JsonMessage('', j),
);

void probeTests() {
  group('idle probe', () {
    const interval = Duration(milliseconds: 40);
    late FakeBridgeFarm farm;
    late Ros2Client client;

    setUp(() async {
      farm = FakeBridgeFarm();
      client = Ros2Client(Uri.parse('ws://fake:9090'),
          transportFactory: (_) => farm.create(),
          idleProbeInterval: interval,
          reconnectPolicy: const ReconnectPolicy(
              initialDelay: Duration(milliseconds: 5), jitter: 0));
      await client.connect();
    });
    tearDown(() => client.close());

    String probeTopic() => farm.current
        .opsOf('subscribe')
        .map((c) => c['topic']! as String)
        .singleWhere((t) => t.startsWith('/_ros2_client/probe_'));

    test('subscribes to its own probe topic and probes when idle', () async {
      final topic = probeTopic();
      expect(farm.current.opsOf('advertise').map((c) => c['topic']),
          contains(topic));
      await Future<void>.delayed(interval * 2.5);
      expect(farm.current.opsOf('publish').where((c) => c['topic'] == topic),
          isNotEmpty);
    });

    test('a link that answers its probes stays up', () async {
      final topic = probeTopic();
      // Echo every probe back, as the bridge does.
      final echo = Timer.periodic(const Duration(milliseconds: 5), (_) {
        final bridge = farm.current;
        final probes =
            bridge.opsOf('publish').where((c) => c['topic'] == topic).length;
        for (var i = bridge.echoed; i < probes; i++) {
          bridge.publish(topic, {'data': ''});
        }
        bridge.echoed = probes;
      });
      addTearDown(echo.cancel);
      await Future<void>.delayed(interval * 10);
      expect(farm.connectAttempts, 1);
      expect(client.isConnected, isTrue);
    });

    test('a link that goes silent is reconnected', () async {
      await Future<void>.delayed(interval * 6);
      expect(farm.connectAttempts, greaterThan(1),
          reason: 'two unanswered probes mean the link is dead');
    });

    test('traffic counts as proof of life', () async {
      final traffic = Timer.periodic(const Duration(milliseconds: 10),
          (_) => farm.current.publish('/chatter', {'data': 'hi'}));
      addTearDown(traffic.cancel);
      await Future<void>.delayed(interval * 8);
      expect(farm.connectAttempts, 1);
      expect(farm.current.opsOf('publish'), isEmpty,
          reason: 'no probe is needed while frames arrive');
    });

    test('does not probe while a call is outstanding', () async {
      // The bridge answers nothing else until a call returns, so a busy
      // bridge would look like a dead one.
      unawaited(client
          .callServiceJson('/slow', {}, timeout: const Duration(seconds: 5))
          .catchError((Object _) => <String, Object?>{}));
      await Future<void>.delayed(interval * 6);
      expect(farm.connectAttempts, 1);
      expect(farm.current.opsOf('publish'), isEmpty);
    });
  });

  test('is off by default outside a browser', () async {
    final bridge = FakeBridge();
    final client = Ros2Client(Uri.parse('ws://fake:9090'),
        transportFactory: (_) => bridge, reconnectPolicy: ReconnectPolicy.none);
    addTearDown(client.close);
    await client.connect();
    expect(client.idleProbeInterval, isNull);
    expect(bridge.opsOf('subscribe'), isEmpty);
  });
}
