@Tags(['integration'])
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ros2_client/ros2_client.dart';
import 'package:test/test.dart';

/// Exercises the real [WebSocketTransport] against a Tornado server speaking
/// the rosbridge protocol — the same server rosbridge_suite is built on.
///
/// Run with: dart test -t integration
void main() {
  // Tornado is what rosbridge_suite itself runs on, but a contributor may not
  // have it. Skip rather than fail with a confusing socket timeout.
  final probe = Process.runSync('python3', ['-c', 'import tornado']);
  if (probe.exitCode != 0) {
    test('integration tests skipped', () {},
        skip: 'python3 + tornado required');
    return;
  }

  late Process server;
  late int port;
  late Ros2Client ros;

  setUpAll(() async {
    registerStandardMessages();
    server = await Process.start(
      'python3',
      ['test/integration/fake_rosbridge_server.py'],
    );
    // The server binds an ephemeral port and reports it, so parallel runs and
    // leftover processes cannot collide on a fixed port.
    final ready = Completer<int>();
    server.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      if (line.startsWith('READY') && !ready.isCompleted) {
        ready.complete(int.parse(line.split(' ').last));
      }
    });
    port = await ready.future.timeout(const Duration(seconds: 15));
  });

  tearDownAll(() async {
    server.kill();
    await server.exitCode;
  });

  setUp(() async {
    ros = Ros2Client(
      Uri.parse('ws://127.0.0.1:$port'),
      reconnectPolicy: ReconnectPolicy.none,
    );
    await ros.connect();
  });

  tearDown(() => ros.close());

  test('connects over a real WebSocket', () {
    expect(ros.isConnected, isTrue);
  });

  test('receives and decodes a typed message', () async {
    final message = await ros.subscribe<StringMsg>('/chatter').first.timeout(
          const Duration(seconds: 5),
        );
    expect(message.data, 'hello from tornado');
  });

  test('decodes a nested message', () async {
    final twist = await ros
        .subscribe<Twist>('/cmd_vel')
        .first
        .timeout(const Duration(seconds: 5));
    expect(twist.linear.x, 1.5);
    expect(twist.angular.z, -0.5);
  });

  test('round-trips a published message through the bridge', () async {
    final received = ros.subscribe<StringMsg>('/echo').first;
    // Give the subscribe time to register before publishing.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    ros.publishOnce<StringMsg>('/echo', const StringMsg('round trip'));

    expect((await received.timeout(const Duration(seconds: 5))).data,
        'round trip');
  });

  test('calls a service and receives the response', () async {
    final result =
        await ros.callServiceJson('/add_two_ints', {'a': 7, 'b': 5}).timeout(
      const Duration(seconds: 5),
    );
    expect(result['sum'], 12);
  });

  test('introspects the topic list', () async {
    final topics = await ros.listTopics().timeout(const Duration(seconds: 5));
    expect(topics.map((t) => t.name), containsAll(['/chatter', '/cmd_vel']));
    expect(topics.first.type, 'std_msgs/msg/String');
  });

  test('runs an action goal to completion with feedback', () async {
    final codec = ActionCodec<int, int, String>(
      actionType: 'test_msgs/action/Fibonacci',
      encodeGoal: (order) => {'order': order},
      decodeFeedback: (json) => (json['partial'] as num).toInt(),
      decodeResult: (json) => '${json['sequence']}',
    );

    final handle =
        ros.sendGoal<int, int, String>('/fibonacci', 3, codec: codec);
    final feedback = <int>[];
    final sub = handle.feedback.listen(feedback.add);

    expect(await handle.result.timeout(const Duration(seconds: 5)), 'complete');
    await sub.cancel();
    expect(feedback, [0, 1, 2]);
  });

  test('reconnects automatically after the server drops the socket', () async {
    final client = Ros2Client(
      Uri.parse('ws://127.0.0.1:$port'),
      reconnectPolicy: const ReconnectPolicy(
        initialDelay: Duration(milliseconds: 50),
        jitter: 0,
      ),
    );
    addTearDown(client.close);
    await client.connect();
    expect(client.isConnected, isTrue);

    // Watch for the client going down and coming back up on its own.
    final sawReconnecting = Completer<void>();
    final sawReconnected = Completer<void>();
    final sub = client.states.listen((state) {
      if (state == RosConnectionState.reconnecting &&
          !sawReconnecting.isCompleted) {
        sawReconnecting.complete();
      } else if (state == RosConnectionState.connected &&
          sawReconnecting.isCompleted &&
          !sawReconnected.isCompleted) {
        sawReconnected.complete();
      }
    });
    addTearDown(sub.cancel);

    // Ask the server to hang up on us. Sent as a service call, not a
    // subscription: subscriptions are replayed on reconnect, which would drop
    // the connection again in a loop.
    unawaited(client.callServiceJson('/__drop__', const {}).catchError(
        (Object _) => const <String, Object?>{}));

    await sawReconnecting.future.timeout(const Duration(seconds: 10),
        onTimeout: () => fail('client never noticed the drop'));
    await sawReconnected.future.timeout(const Duration(seconds: 10),
        onTimeout: () => fail('client never reconnected'));

    expect(client.isConnected, isTrue);

    // And it is genuinely usable again, not just marked connected.
    final message = await client
        .subscribe<StringMsg>('/chatter')
        .first
        .timeout(const Duration(seconds: 5));
    expect(message.data, 'hello from tornado');
  });
}
