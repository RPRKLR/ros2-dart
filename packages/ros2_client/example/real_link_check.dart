// Verifies what a fake bridge cannot show: a link that goes silent without
// closing, noticed both by pings and by the browser's idle probe; one slow
// service call holding up the rest; and a second listener on a topic making
// the bridge deliver a message twice.
//
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml
//   python3 tool/robot_fixtures/slow_service.py
//   ros2 run demo_nodes_cpp talker
//   python3 tool/robot_fixtures/freeze_proxy.py 9091 9090 & A=$!
//   python3 tool/robot_fixtures/freeze_proxy.py 9092 9090 & B=$!
//   dart run example/real_link_check.dart ws://localhost:9090 \
//       ws://localhost:9091 $A ws://localhost:9092 $B
import 'dart:async';
import 'dart:io';

import 'package:ros2_client/ros2_client.dart';

var failures = 0;

void check(String what, bool ok, [String detail = '']) {
  stdout.writeln(
      '${ok ? 'ok  ' : 'FAIL'}  $what${detail.isEmpty ? '' : '  $detail'}');
  if (!ok) failures++;
}

Future<void> main(List<String> args) async {
  final direct = Uri.parse(args[0]);
  final proxied = Uri.parse(args[1]);
  final proxyPid = int.parse(args[2]);
  final probed = Uri.parse(args[3]);
  final probedProxyPid = int.parse(args[4]);

  registerStandardMessages();

  // --- a slow call must not hold up the next one
  final ros = Ros2Client(direct, reconnectPolicy: ReconnectPolicy.none);
  await ros.connect();
  final slow = Stopwatch()..start();
  try {
    await ros.callServiceJson('/slow', {},
        type: 'std_srvs/srv/Trigger', timeout: const Duration(seconds: 2));
    check('/slow times out', false, 'it answered');
  } on TimeoutException {
    check('/slow times out', true, '${slow.elapsedMilliseconds} ms');
  }
  final fast = Stopwatch()..start();
  try {
    final reply = await ros.callServiceJson('/fast', {},
        type: 'std_srvs/srv/Trigger', timeout: const Duration(seconds: 4));
    check(
        '/fast answers at once after /slow timed out',
        reply['message'] == 'fast' && fast.elapsedMilliseconds < 1000,
        '${fast.elapsedMilliseconds} ms');
  } on TimeoutException {
    check('/fast answers at once after /slow timed out', false,
        'still queued behind /slow after ${fast.elapsedMilliseconds} ms');
  }

  // --- a second listener must not make the bridge deliver anything twice
  final first = <String>[], second = <String>[];
  final subA = ros.subscribe<StringMsg>('/chatter').listen((m) {
    first.add(m.data);
  });
  await Future<void>.delayed(const Duration(milliseconds: 2500));
  final subB = ros.subscribe<StringMsg>('/chatter').listen((m) {
    second.add(m.data);
  });
  await Future<void>.delayed(const Duration(seconds: 4));
  await subA.cancel();
  await subB.cancel();
  bool repeats(List<String> got) => got.toSet().length != got.length;
  check(
      'two listeners on /chatter see each message once',
      first.length >= 5 &&
          second.length >= 3 &&
          !repeats(first) &&
          !repeats(second),
      'first ${first.length}, second ${second.length}');
  await ros.close();

  // --- pings keep a healthy idle link up, and notice a silent one
  final link = Ros2Client(proxied,
      reconnectPolicy: const ReconnectPolicy(maxAttempts: 1));
  final states = <(Duration, RosConnectionState)>[];
  final clock = Stopwatch()..start();
  link.states.listen((s) => states.add((clock.elapsed, s)));
  await link.connect();
  states.clear();

  await Future<void>.delayed(const Duration(seconds: 20));
  check(
      'an idle, healthy link stays connected for 20 s of pings',
      link.isConnected &&
          states.every((s) => s.$2 == RosConnectionState.connected),
      '$states');

  Process.killPid(proxyPid, ProcessSignal.sigusr1);
  final frozenAt = clock.elapsed;
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (link.isConnected && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  final noticed = clock.elapsed - frozenAt;
  check('a silent link is noticed', !link.isConnected,
      'after ${noticed.inMilliseconds} ms');
  await link.close();

  // --- the browser's idle probe, with pings turned off to stand in for one
  final web = Ros2Client(probed,
      transportFactory: (uri) => WebSocketTransport(uri, pingInterval: null),
      idleProbeInterval: const Duration(seconds: 2),
      reconnectPolicy: const ReconnectPolicy(maxAttempts: 1));
  await web.connect();
  final webStates = <RosConnectionState>[];
  web.states.listen(webStates.add);
  await Future<void>.delayed(const Duration(seconds: 15));
  check(
      'an idle link answering its probes stays connected for 15 s',
      web.isConnected &&
          webStates.every((s) => s == RosConnectionState.connected),
      '$webStates');

  Process.killPid(probedProxyPid, ProcessSignal.sigusr1);
  final probeClock = Stopwatch()..start();
  final probeDeadline = DateTime.now().add(const Duration(seconds: 30));
  while (web.isConnected && DateTime.now().isBefore(probeDeadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  check('the probe notices a silent link without pings', !web.isConnected,
      'after ${probeClock.elapsedMilliseconds} ms');
  await web.close();

  stdout.writeln(failures == 0 ? '\nall passed' : '\n$failures FAILED');
  exit(failures == 0 ? 0 : 1);
}
