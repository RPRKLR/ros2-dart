// Verifies the tf2 buffer against a real robot's transform tree, which a
// synthetic buffer cannot check: the QoS on /tf and /tf_static, several
// independent latching broadcasters, and a 50 Hz stream of real timestamps.
//
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml
//   python3 tf_pub.py
//   dart run example/real_tf_check.dart
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:ros2_client/ros2_client.dart';

var failures = 0;

void check(String what, bool ok, [String detail = '']) {
  stdout.writeln(
      '${ok ? 'ok  ' : 'FAIL'}  $what${detail.isEmpty ? '' : '  $detail'}');
  if (!ok) failures++;
}

Future<void> main(List<String> args) async {
  registerStandardMessages();
  final uri = Uri.parse(args.isEmpty ? 'ws://localhost:9090' : args.first);
  final ros = Ros2Client(uri, reconnectPolicy: ReconnectPolicy.none);
  ros.status.listen((s) => stdout.writeln('   status: ${s.message}'));
  await ros.connect();

  final tf = TfListener(ros)..start();

  // Every static frame must arrive, not just one broadcaster's worth. A
  // one-deep transient-local reader keeps only the last publisher's backlog.
  for (final frame in ['laser', 'camera', 'imu']) {
    try {
      await tf.waitForFrame(frame, timeout: const Duration(seconds: 12));
      check('static frame "$frame" arrived', true);
    } on TimeoutException {
      check('static frame "$frame" arrived', false, 'timed out');
    }
  }

  // The leading slash must not matter.
  try {
    await tf.waitForFrame('/laser', timeout: const Duration(seconds: 5));
    check('waitForFrame tolerates a leading slash', true);
  } on TimeoutException {
    check('waitForFrame tolerates a leading slash', false, 'timed out');
  }

  await tf.waitForTransform('map', 'base_link',
      timeout: const Duration(seconds: 12));
  check('dynamic chain map <- base_link resolves', true);

  // map -> odom is a fixed 1 m offset; odom -> base_link runs a 2 m circle.
  // So the robot is always between 1 m and 3 m from the map origin.
  final t = tf.buffer.lookupOrThrow('map', 'base_link');
  final radius = math.sqrt(
      t.translation.x * t.translation.x + t.translation.y * t.translation.y);
  check(
      'composed transform has a plausible magnitude',
      radius > 0.9 && radius < 3.2,
      '${radius.toStringAsFixed(3)} m from the map origin');

  // A three-level chain through a static leaf.
  final laser = tf.buffer.lookupOrThrow('map', 'laser');
  check(
      'map <- laser composes through the static leaf',
      (laser.translation.z - 0.3).abs() < 1e-6,
      'z = ${laser.translation.z.toStringAsFixed(3)}');

  // The buffer must actually be filling at 50 Hz, not keeping one sample.
  await Future<void>.delayed(const Duration(seconds: 2));
  final described = tf.buffer.describe();
  final samples = RegExp(r'(\d+) samples')
      .allMatches(described)
      .map((m) => int.parse(m.group(1)!))
      .fold(0, math.max);
  check('the buffer holds a real history', samples > 20, '$samples samples');

  // Interpolation between real stamps.
  final now = DateTime.now().toUtc();
  final past =
      RosTime.fromDateTime(now.subtract(const Duration(milliseconds: 200)));
  final interpolated = tf.buffer.lookup('map', 'base_link', time: past);
  check('interpolates at a past timestamp', interpolated != null);

  check(
      'frames are normalised',
      tf.buffer.frames.every((f) => !f.startsWith('/')),
      tf.buffer.frames.join(', '));

  stdout.writeln('\n${tf.buffer.describe()}');
  await tf.stop();
  await ros.close();
  stdout.writeln(failures == 0 ? 'All checks passed.' : '$failures failed.');
  exit(failures == 0 ? 0 : 1);
}
