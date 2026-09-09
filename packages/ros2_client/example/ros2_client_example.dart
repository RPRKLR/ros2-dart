// A console ROS 2 client: connect, introspect, subscribe, and drive.
//
// Start a bridge on the robot first:
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml
//
// Then:  dart run example/ros2_client_example.dart ws://192.168.1.10:9090
import 'dart:async';
import 'dart:io';

import 'package:ros2_client/ros2_client.dart';

Future<void> main(List<String> args) async {
  registerStandardMessages();

  final uri = Uri.parse(args.isNotEmpty ? args.first : 'ws://127.0.0.1:9090');
  final ros = Ros2Client(uri, defaultCompression: Compression.cbor);

  ros.states.listen((state) => print('[connection] ${state.name}'));
  ros.status.listen((status) => print('[bridge] $status'));

  print('Connecting to $uri …');
  await ros.connect();

  // --- Introspection: what is actually running on this robot? ---------------
  final topics = await ros.listTopics();
  print('\n${topics.length} topics:');
  for (final topic in topics.take(15)) {
    print('  $topic');
  }

  final nodes = await ros.listNodes();
  print('\n${nodes.length} nodes: ${nodes.take(8).join(', ')}');

  // --- Subscribe to whatever interesting topics exist -----------------------
  final names = topics.map((t) => t.name).toSet();

  if (names.contains('/odom')) {
    ros.subscribe<Odometry>('/odom', throttleRate: 500).listen((odom) {
      final p = odom.pose.position;
      print('[odom] x=${p.x.toStringAsFixed(2)} '
          'y=${p.y.toStringAsFixed(2)} '
          'yaw=${odom.pose.orientation.yaw.toStringAsFixed(2)}');
    });
  }

  if (names.contains('/scan')) {
    // Lidar is published best-effort; the default reliable QoS matches nothing.
    ros
        .subscribe<LaserScan>('/scan',
            qos: QosProfile.sensorData, throttleRate: 1000)
        .listen((scan) {
      final valid = scan.ranges.where((r) => r.isFinite && r > 0);
      final closest =
          valid.isEmpty ? double.nan : valid.reduce((a, b) => a < b ? a : b);
      print('[scan] ${scan.ranges.length} beams, '
          'closest ${closest.toStringAsFixed(2)} m');
    });
  }

  if (names.contains('/battery_state')) {
    ros.subscribe<BatteryState>('/battery_state').listen(
        (b) => print('[battery] ${(b.percentage * 100).toStringAsFixed(0)}% '
            '${b.isCharging ? '(charging)' : ''}'));
  }

  // --- Drive forward briefly, then stop ------------------------------------
  if (names.contains('/cmd_vel')) {
    final cmdVel = ros.advertise<Twist>('/cmd_vel');
    print('\nDriving forward for 2 s …');
    final ticker = Timer.periodic(const Duration(milliseconds: 100),
        (_) => cmdVel.publish(Twist.drive(forward: 0.15)));

    await Future<void>.delayed(const Duration(seconds: 2));
    ticker.cancel();
    cmdVel.publish(Twist.stop);
    print('Stopped.');
  }

  print('\nStreaming for 15 s — Ctrl-C to quit.');
  await Future<void>.delayed(const Duration(seconds: 15));

  await ros.close();
  exit(0);
}
