// Using pre-generated messages alongside the types ros2_client bundles.
//
//   dart run example/ros2_msgs_common_example.dart ws://robot.local:9090
import 'dart:io';

import 'package:ros2_client/ros2_client.dart';
import 'package:ros2_msgs_common/diagnostic_msgs.dart';
import 'package:ros2_msgs_common/ros2_msgs_common.dart';
import 'package:ros2_msgs_common/visualization_msgs.dart';

Future<void> main(List<String> args) async {
  // Both registries: the client's core types, then everything in this package.
  registerStandardMessages();
  registerCommonMessages();

  final uri = Uri.parse(args.isEmpty ? 'ws://localhost:9090' : args.first);
  final ros = Ros2Client(uri);
  await ros.connect();

  // A marker's `pose` and `points` are geometry_msgs types that come from
  // ros2_client, not from a second copy defined here.
  final marker = Marker(
    ns: 'demo',
    id: 1,
    type: Marker.sphere,
    action: Marker.add,
    pose: const Pose(position: Point(x: 1, y: 2)),
    scale: const Vector3(x: 0.2, y: 0.2, z: 0.2),
    color: const ColorRGBA(r: 1, a: 1),
  );
  ros.advertise<Marker>('/visualization_marker').publish(marker);
  stdout.writeln('published a ${marker.pose.position.x}m marker');

  // Diagnostics, with backpressure: only the newest report matters.
  final report = await ros
      .subscribe<DiagnosticArray>('/diagnostics',
          backpressure: Backpressure.latest)
      .first
      .timeout(const Duration(seconds: 10), onTimeout: () => DiagnosticArray());

  for (final status in report.status) {
    stdout.writeln('${status.level == DiagnosticStatus.ok ? "OK " : "!! "}'
        '${status.name}: ${status.message}');
  }

  await ros.close();
}
