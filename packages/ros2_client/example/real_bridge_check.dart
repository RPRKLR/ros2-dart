// Validates every major feature against a REAL rosbridge_server.
//
// Setup:
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml
//   ros2 run turtlesim turtlesim_node
//   ros2 run demo_nodes_cpp talker
//   ros2 run demo_nodes_cpp add_two_ints_server
//
//   dart run example/real_bridge_check.dart
import 'dart:async';

import 'package:ros2_client/ros2_client.dart';

var passed = 0;
var failed = 0;

Future<void> check(String name, Future<void> Function() body,
    {Duration timeout = const Duration(seconds: 15)}) async {
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

  // turtlesim's Pose is not a standard message, so register it by hand — this
  // also exercises the custom-message path end to end.
  MessageRegistry.register(const MessageCodec<TurtlePose>(
    rosType: 'turtlesim/msg/Pose',
    fromJson: TurtlePose.fromJson,
    toJson: TurtlePose.encode,
  ));

  final uri = Uri.parse(args.isNotEmpty ? args.first : 'ws://127.0.0.1:9090');
  final ros = Ros2Client(uri);
  final statuses = <RosStatus>[];
  ros.status.listen(statuses.add);

  await ros.connect();
  print('Connected to $uri\n');

  await check('introspection: topics include turtlesim + talker', () async {
    final topics = await ros.listTopics();
    final names = topics.map((t) => t.name).toSet();
    expect(names.contains('/turtle1/pose'), 'missing /turtle1/pose');
    expect(names.contains('/chatter'), 'missing /chatter');
    final pose = topics.firstWhere((t) => t.name == '/turtle1/pose');
    expect(pose.type == 'turtlesim/msg/Pose', 'wrong type ${pose.type}');
  });

  await check('introspection: topicType()', () async {
    final type = await ros.topicType('/chatter');
    expect(type == 'std_msgs/msg/String', 'got $type');
  });

  await check('introspection: nodes', () async {
    final nodes = await ros.listNodes();
    expect(nodes.contains('/turtlesim'), 'missing /turtlesim in $nodes');
  });

  await check('introspection: action servers', () async {
    final actions = await ros.listActionServers();
    expect(actions.contains('/turtle1/rotate_absolute'),
        'missing rotate_absolute in $actions');
  });

  await check('introspection: rosDistro', () async {
    final distro = await ros.rosDistro();
    expect(distro.isNotEmpty, 'empty distro');
    print('          distro=$distro');
  });

  await check('subscribe: typed std_msgs/String from talker', () async {
    final msg = await ros.subscribe<StringMsg>('/chatter').first;
    expect(msg.data.contains('Hello World'), 'got "${msg.data}"');
  });

  await check('subscribe: custom message type (turtlesim/Pose)', () async {
    final pose = await ros.subscribe<TurtlePose>('/turtle1/pose').first;
    expect(pose.x > 0 && pose.y > 0, 'implausible pose $pose');
    print('          $pose');
  });

  await check('publish: drive the turtle and observe it move', () async {
    final start = await ros.subscribe<TurtlePose>('/turtle1/pose').first;
    final cmd = ros.advertise<Twist>('/turtle1/cmd_vel');

    // turtlesim stops without a steady command stream.
    final ticker = Timer.periodic(const Duration(milliseconds: 50),
        (_) => cmd.publish(Twist.drive(forward: 2.0)));
    await Future<void>.delayed(const Duration(seconds: 2));
    ticker.cancel();
    cmd.publish(Twist.stop);
    cmd.close();

    final end = await ros.subscribe<TurtlePose>('/turtle1/pose').first;
    final moved = (end.x - start.x).abs() + (end.y - start.y).abs();
    expect(moved > 0.5, 'turtle did not move (delta $moved)');
    print('          moved ${moved.toStringAsFixed(2)} units');
  });

  await check('service: add_two_ints', () async {
    final res = await ros.callServiceJson('/add_two_ints', {'a': 41, 'b': 1},
        type: 'example_interfaces/srv/AddTwoInts');
    expect(res['sum'] == 42, 'got ${res['sum']}');
  });

  await check('service: turtlesim /spawn then /kill', () async {
    final spawn = await ros.callServiceJson(
        '/spawn', {'x': 2.0, 'y': 2.0, 'theta': 0.0, 'name': 'probe'});
    expect(spawn['name'] == 'probe', 'spawn returned $spawn');
    await ros.callServiceJson('/kill', {'name': 'probe'});
  });

  await check('action: rotate_absolute with feedback and result', () async {
    final codec = ActionCodec<double, double, double>(
      actionType: 'turtlesim/action/RotateAbsolute',
      encodeGoal: (theta) => {'theta': theta},
      decodeFeedback: (json) => (json['remaining'] as num?)?.toDouble() ?? 0,
      decodeResult: (json) => (json['delta'] as num?)?.toDouble() ?? 0,
    );

    final handle = ros.sendGoal<double, double, double>(
        '/turtle1/rotate_absolute', 1.5,
        codec: codec);
    final feedback = <double>[];
    final sub = handle.feedback.listen(feedback.add);

    final delta = await handle.result;
    await sub.cancel();
    print('          delta=${delta.toStringAsFixed(3)}, '
        '${feedback.length} feedback messages');
    expect(feedback.isNotEmpty, 'no feedback received');
  });

  await check('parameters: read a known node parameter', () async {
    final value = await ros.getParam('/turtlesim:background_r');
    expect(value is int, 'expected an int, got $value');
    print('          /turtlesim:background_r = $value');
  });

  await check('parameters: listParams (slow; needs params_glob)', () async {
    final sw = Stopwatch()..start();
    final names = await ros.listParams();
    print('          ${names.length} params in ${sw.elapsedMilliseconds}ms'
        '${names.isEmpty ? "  (empty: bridge has no params_glob set)" : ""}');
  }, timeout: const Duration(seconds: 60));

  await check('parameters: write and read back', () async {
    const name = '/turtlesim:background_b';
    final ok = await ros.setParam(name, 128);
    expect(ok, 'setParam was rejected');
    final value = await ros.getParam(name);
    expect(value == 128, 'read back $value');
  });

  await check('QoS: best-effort subscription still delivers', () async {
    final msg = await ros
        .subscribe<StringMsg>('/chatter', qos: QosProfile.sensorData)
        .first;
    expect(msg.data.isNotEmpty, 'empty message');
  });

  await check('throttle_rate is honoured by the bridge', () async {
    final received = <DateTime>[];
    final sub = ros
        .subscribe<StringMsg>('/chatter', throttleRate: 2000)
        .listen((_) => received.add(DateTime.now()));
    await Future<void>.delayed(const Duration(seconds: 5));
    await sub.cancel();
    // talker runs at 1 Hz; throttling to one per 2 s must cut that down.
    expect(received.length <= 4, 'got ${received.length} in 5s, expected <= 4');
    print('          ${received.length} messages in 5s (unthrottled ~5)');
  });

  print('\n$passed passed, $failed failed');
  if (statuses.isNotEmpty) {
    print('\nBridge status messages:');
    for (final s in statuses.take(10)) {
      print('  $s');
    }
  }

  await ros.close();
}

/// `turtlesim/msg/Pose` — not a standard message, registered by hand.
final class TurtlePose implements RosMessage {
  const TurtlePose(this.x, this.y, this.theta);

  factory TurtlePose.fromJson(Map<String, Object?> json) => TurtlePose(
        Field.asDouble(json['x']),
        Field.asDouble(json['y']),
        Field.asDouble(json['theta']),
      );

  static Map<String, Object?> encode(TurtlePose p) =>
      {'x': p.x, 'y': p.y, 'theta': p.theta};

  final double x, y, theta;

  @override
  String get rosType => 'turtlesim/msg/Pose';

  @override
  Map<String, Object?> toJson() => encode(this);

  @override
  String toString() => 'TurtlePose(${x.toStringAsFixed(2)}, '
      '${y.toStringAsFixed(2)}, θ=${theta.toStringAsFixed(2)})';
}
