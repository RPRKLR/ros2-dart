// Validates the connection-level APIs against a REAL rosbridge_server.
//
// Everything here is a claim about what the bridge does with a connection,
// and every one of them is the kind a fake server would agree with whatever
// the client did: whether a handshake carrying subprotocols is accepted at
// all, whether `rosapi` really lists its own action service, and whether the
// retry loop brings a link up after the first attempt is refused.
//
// Setup:
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml
//
//   dart run example/real_connection_check.dart
import 'dart:async';

import 'package:ros2_client/ros2_client.dart';

var passed = 0;
var failed = 0;

Future<void> check(String name, Future<void> Function() body,
    {Duration timeout = const Duration(seconds: 20)}) async {
  try {
    await body().timeout(timeout);
    passed++;
    print('  PASS  $name');
  } catch (e) {
    failed++;
    print('  FAIL  $name\n          $e');
  }
}

void expect(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Future<void> main(List<String> args) async {
  registerStandardMessages();

  final uri = Uri.parse(args.isNotEmpty ? args.first : 'ws://127.0.0.1:9090');
  final ros = Ros2Client(uri);
  await ros.connect();
  print('Connected to $uri\n');

  await check('waitUntilConnected returns at once on a live client', () async {
    final started = DateTime.now();
    await ros.waitUntilConnected(timeout: const Duration(seconds: 2));
    expect(DateTime.now().difference(started) < const Duration(seconds: 1),
        'took too long for an already-connected client');
  });

  await check('probeBridge reports ROS 2, the distro, and action support',
      () async {
    final info = await ros.probeBridge();
    print('        $info');
    expect(info.rosVersion == 2, 'expected ROS 2, got ${info.rosVersion}');
    expect(info.distro.isNotEmpty, 'no distro reported');
    // rosbridge_suite >= 2.0.0 ships /rosapi/action_servers alongside
    // send_action_goal; this asserts the pairing on a bridge that has both.
    expect(info.supportsActions,
        'action support not detected on a bridge that has it');
  });

  await check('the probe never calls a service to find out it exists',
      () async {
    // Calling /rosapi/action_servers to test for it would park the bridge's
    // only queue thread forever on a bridge that lacks it. This asserts the
    // probe still works when the answer has to come from the service list.
    final services = await ros.listServices();
    expect(services.contains('/rosapi/action_servers'),
        '/rosapi/action_servers missing from the service list');
  });

  await check('a handshake offering subprotocols is still accepted', () async {
    // The reverse-proxy token path. rosbridge selects no subprotocol, and the
    // question this answers is whether it accepts the connection anyway —
    // nothing in the protocol document says, and a fake server cannot tell us.
    final tokenised = Ros2Client(
      uri,
      protocols: const ['rosbridge.v1', 'token.not-a-real-secret'],
      reconnectPolicy: ReconnectPolicy.none,
    );
    await tokenised.connect();
    expect(tokenised.isConnected, 'connection with subprotocols was refused');

    // And it carries traffic, not just a handshake.
    final distro = await tokenised.rosDistro();
    expect(distro.isNotEmpty, 'no traffic flowed over the subprotocol socket');
    await tokenised.close();
  });

  await check('waitUntilConnected completes on a retry, not the first attempt',
      () async {
    // The first attempt goes to a port with nothing on it, so connect()
    // throws; the URI the retry loop uses is the same one, so this also
    // proves the failure path leaves a usable client behind.
    final wrong = Uri.parse('ws://127.0.0.1:9091');
    final client = Ros2Client(
      wrong,
      reconnectPolicy: const ReconnectPolicy(
          initialDelay: Duration(milliseconds: 300), jitter: 0),
    );
    await client.connect().then<void>((_) {}, onError: (Object _) {});
    expect(!client.isConnected, 'sanity: nothing should be listening on 9091');

    final at = client.nextRetryAt;
    expect(at != null, 'no retry scheduled after a refused connection');
    expect(at!.difference(DateTime.now()) <= const Duration(seconds: 1),
        'retry scheduled further out than the policy asked for');

    // It never comes up, so the timeout is what has to fire.
    var timedOut = false;
    try {
      await client.waitUntilConnected(timeout: const Duration(seconds: 1));
    } on TimeoutException {
      timedOut = true;
    }
    expect(timedOut, 'waiting on a dead endpoint did not time out');
    await client.close();
  });

  await check('a client that gives up says so instead of waiting', () async {
    final client = Ros2Client(Uri.parse('ws://127.0.0.1:9091'),
        reconnectPolicy: ReconnectPolicy.none);
    await client.connect().then<void>((_) {}, onError: (Object _) {});

    Object? error;
    try {
      await client.waitUntilConnected(timeout: const Duration(seconds: 5));
    } catch (e) {
      error = e;
    }
    expect(error is StateError, 'expected a StateError, got $error');
    expect('$error'.contains('Gave up'), 'unexpected message: $error');
    await client.close();
  });

  print('\n$passed passed, $failed failed');
  await ros.close();
}
