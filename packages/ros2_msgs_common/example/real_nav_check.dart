// Drives a REAL Nav2 the way the ros2_flutter example's Navigate tab does:
// goals, feedback, an abort and its reason, cancel, preemption, the costmap
// reset, and /diagnostics. Each is a claim about what Nav2 and rosbridge do,
// which no fake can make.
//
// Setup, on Lyrical (the classes below are Lyrical's):
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml \
//     send_action_goals_in_new_thread:=true call_services_in_new_thread:=true
//   ros2 launch nav2_bringup tb3_loopback_simulation_launch.py use_rviz:=False
//
//   dart run example/real_nav_check.dart [ws://127.0.0.1:9090]
import 'dart:async';
import 'dart:math' as math;

import 'package:ros2_client/ros2_client.dart';
import 'package:ros2_msgs_common/jazzy/nav2_msgs.dart' as jazzy;
import 'package:ros2_msgs_common/lyrical/diagnostic_msgs.dart';
import 'package:ros2_msgs_common/lyrical/nav2_msgs.dart' as nav2;
import 'package:ros2_msgs_common/ros2_msgs_common.dart';

var passed = 0;
var failed = 0;

Future<void> check(String name, Future<void> Function() body,
    {Duration timeout = const Duration(seconds: 90)}) async {
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

typedef Nav
    = GoalHandle<nav2.NavigateToPoseFeedback, nav2.NavigateToPoseResult>;

Future<void> main(List<String> args) async {
  registerStandardMessages();
  registerLyricalMessages();

  final uri = Uri.parse(args.isNotEmpty ? args.first : 'ws://127.0.0.1:9090');
  final ros = Ros2Client(uri);
  await ros.connect();
  print('Connected to $uri, distro ${await ros.rosDistro()}\n');
  final tf = TfListener(ros)..start();

  Nav go(double x, double y, double yaw) => ros.sendGoal<
          nav2.NavigateToPoseGoal,
          nav2.NavigateToPoseFeedback,
          nav2.NavigateToPoseResult>(
        '/navigate_to_pose',
        nav2.NavigateToPoseGoal(
          pose: PoseStamped(
            // Stamped zero, as RosMapView's goals are: "the latest transform".
            header: const Header(frameId: 'map'),
            pose: Pose(
              position: Point(x: x, y: y),
              orientation: Quaternion.fromYaw(yaw),
            ),
          ),
        ),
      );

  late RosTransform start;
  await check('the robot is localised on the map', () async {
    while (true) {
      final t = tf.buffer.lookup('map', 'base_link');
      if (t != null) {
        start = t;
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    print('          at ${start.translation.x.toStringAsFixed(2)}, '
        '${start.translation.y.toStringAsFixed(2)}');
  }, timeout: const Duration(seconds: 60));

  await check('a reachable goal reports feedback, then succeeds', () async {
    // Half a metre ahead, and turned a quarter: a goal the planner can reach.
    final yaw = start.rotation.yaw;
    final handle = go(start.translation.x + 0.5 * math.cos(yaw),
        start.translation.y + 0.5 * math.sin(yaw), yaw + math.pi / 2);
    final feedback = <nav2.NavigateToPoseFeedback>[];
    handle.feedback.listen(feedback.add);
    final result = await handle.result;
    expect(feedback.isNotEmpty, 'no feedback');
    expect(result.errorCode == 0, 'error ${result.errorCode}');
    print('          ${feedback.length} feedback messages, last '
        '${feedback.last.distanceRemaining.toStringAsFixed(2)} m to go');
  });

  await check('an unreachable goal aborts, and the result says why', () async {
    try {
      await go(500, 500, 0).result;
      throw StateError('a goal far outside the map succeeded');
    } on ActionFailedException catch (e) {
      expect(e.status == GoalStatus.aborted, 'status ${e.status}');
      final result = e.result;
      expect(result is nav2.NavigateToPoseResult, 'result $result');
      result as nav2.NavigateToPoseResult;
      expect(result.errorCode != 0, 'no error code');
      print('          error ${result.errorCode}: "${result.errorMsg}"');
    }
  });

  await check('a cancelled goal ends cancelled', () async {
    final yaw = start.rotation.yaw;
    final handle = go(start.translation.x - 1.5 * math.cos(yaw),
        start.translation.y - 1.5 * math.sin(yaw), yaw);
    await handle.feedback.first;
    handle.cancel();
    try {
      await handle.result;
      throw StateError('it finished instead');
    } on ActionFailedException catch (e) {
      expect(e.status == GoalStatus.canceled, 'status ${e.status}');
    }
  });

  await check('a new goal preempts a running one', () async {
    final now = tf.buffer.lookupOrThrow('map', 'base_link');
    final yaw = now.rotation.yaw;
    final first = go(now.translation.x - 1.5 * math.cos(yaw),
        now.translation.y - 1.5 * math.sin(yaw), yaw);
    await first.feedback.first;
    final second = go(now.translation.x, now.translation.y, yaw + math.pi);
    try {
      await first.result;
      throw StateError('the preempted goal succeeded');
    } on ActionFailedException catch (e) {
      print('          preempted goal ended ${e.status.name}');
    }
    final result = await second.result;
    expect(result.errorCode == 0, 'second goal error ${result.errorCode}');
  });

  await check('both costmaps clear, Lyrical-style', () async {
    for (final service in [
      '/global_costmap/clear_entirely_global_costmap',
      '/local_costmap/clear_entirely_local_costmap',
    ]) {
      final response = await ros.callService<nav2.ClearEntireCostmapRequest,
              nav2.ClearEntireCostmapResponse>(
          service, nav2.ClearEntireCostmapRequest(),
          timeout: const Duration(seconds: 5));
      expect(response.success, '$service answered success: false');
    }
  });

  await check('a Jazzy costmap request is refused by a Lyrical bridge',
      () async {
    // Sent as raw JSON: the Jazzy set cannot be registered beside Lyrical's,
    // since both use the same ROS type names. This is its wire form.
    expect(jazzy.ClearEntireCostmapRequest().toJson().keys.single == 'request',
        'the Jazzy request changed');
    try {
      await ros.callServiceJson('/global_costmap/clear_entirely_global_costmap',
          jazzy.ClearEntireCostmapRequest().toJson(),
          type: 'nav2_msgs/srv/ClearEntireCostmap',
          timeout: const Duration(seconds: 5));
      throw StateError('accepted');
    } on ServiceCallException catch (e) {
      print('          ${e.message}');
    }
  });

  await check('/diagnostics decodes over JSON', () async {
    final array = await ros
        .subscribe<DiagnosticArray>('/diagnostics',
            compression: Compression.none)
        .first;
    expect(array.status.isNotEmpty, 'an empty array');
    print('          ${array.status.map((s) => '${s.name}=${s.level}')}');
  }, timeout: const Duration(seconds: 20));

  // The control, and the reason RosDiagnosticsPanel asks for JSON: rosbridge
  // 4.2.1 cannot convert a `byte` field to CBOR, and drops every message
  // ("'bytes' object has no attribute 'get_fields_and_field_types'" on the
  // robot's console only). If this starts failing, a newer bridge fixed it.
  await check('/diagnostics over CBOR delivers nothing (rosbridge 4.2.1)',
      () async {
    final got = await ros
        .subscribe<DiagnosticArray>('/diagnostics',
            compression: Compression.cbor)
        .first
        .then((_) => true)
        .timeout(const Duration(seconds: 6), onTimeout: () => false);
    expect(!got, 'CBOR delivered: this bridge converts byte fields now');
  }, timeout: const Duration(seconds: 20));

  print('\n$passed passed, $failed failed');
  await tf.stop();
  await ros.close();
}
