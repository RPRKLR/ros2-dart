// Verifies the tf2 buffer follows sim time across simulator restarts, which a
// synthetic buffer cannot check end to end: /clock jumping back to zero under
// a live TfListener, as happens on every Gazebo reset.
//
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml
//   python3 sim_clock_pub.py
//   dart run example/real_clock_jump_check.dart
import 'dart:async';
import 'dart:io';

import 'package:ros2_client/ros2_client.dart';

var failures = 0;

void check(String what, bool ok, [String detail = '']) {
  stdout.writeln(
      '${ok ? 'ok  ' : 'FAIL'}  $what${detail.isEmpty ? '' : '  $detail'}');
  if (!ok) failures++;
}

/// Sim seconds encoded in the fixture's pose, or null if unresolvable.
double? simSeconds(TfBuffer buffer, {RosTime? time}) {
  final t = buffer.lookup('map', 'base_link', time: time);
  return t == null ? null : t.translation.x * 100;
}

/// Polls until [condition] holds on the latest answer, or [timeout] passes.
Future<double?> waitFor(TfBuffer buffer, bool Function(double sim) condition,
    Duration timeout) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    final sim = simSeconds(buffer);
    if (sim != null && condition(sim)) return sim;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  return null;
}

Future<void> main(List<String> args) async {
  registerStandardMessages();
  final uri = Uri.parse(args.isEmpty ? 'ws://localhost:9090' : args.first);
  final ros = Ros2Client(uri, reconnectPolicy: ReconnectPolicy.none);
  await ros.connect();

  final tf = TfListener(ros)..start();
  await tf.waitForTransform('map', 'base_link',
      timeout: const Duration(seconds: 12));

  // The fixture alternates 6 s phases from 500 s and from 0 s. Start from the
  // 500 s side so that the next restart is a jump back.
  const phase = Duration(seconds: 15);
  final before = await waitFor(tf.buffer, (s) => s >= 500, phase);
  check('sim time before the restart', before != null,
      '${before?.toStringAsFixed(2)} s');

  // The restart itself. Before the fix every new sample was trimmed on
  // arrival and this answered the pre-restart pose forever.
  final watch = Stopwatch()..start();
  final after = await waitFor(tf.buffer, (s) => s < 100, phase);
  check(
      'the buffer follows the clock back to zero',
      after != null,
      after == null
          ? 'still answering ${simSeconds(tf.buffer)?.toStringAsFixed(2)} s'
          : '${after.toStringAsFixed(2)} s, '
              '${watch.elapsedMilliseconds} ms after waiting began');

  // Following it once is not enough: the answer must keep moving.
  if (after != null) {
    await Future<void>.delayed(const Duration(seconds: 1));
    final later = simSeconds(tf.buffer);
    check('and keeps moving with it', later != null && later > after + 0.5,
        '${later?.toStringAsFixed(2)} s one second on');

    // A timed lookup on the new clock interpolates rather than failing.
    final stampMicros = ((after + 0.3) * 1e6).round();
    final at = RosTime(
        sec: stampMicros ~/ 1000000, nanosec: stampMicros % 1000000 * 1000);
    final timed = simSeconds(tf.buffer, time: at);
    check(
        'a timed lookup resolves on the new clock',
        timed != null && (timed - (after + 0.3)).abs() < 0.05,
        '${timed?.toStringAsFixed(3)} s for ${(after + 0.3).toStringAsFixed(3)}');
  }

  // And forward again, the direction the buffer already handled. Early in the
  // new phase, so a buffer stuck late in the previous one does not count.
  final forward = await waitFor(tf.buffer, (s) => s >= 500 && s < 502, phase);
  check('the jump forward to the next phase is followed', forward != null,
      '${forward?.toStringAsFixed(2)} s');

  await tf.stop();
  await ros.close();
  stdout.writeln(failures == 0 ? 'All checks passed.' : '$failures failed.');
  exit(failures == 0 ? 0 : 1);
}
