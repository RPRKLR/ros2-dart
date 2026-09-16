// Verifies that each distro's classes are the ones its robot accepts, against
// a REAL rosbridge. A test can only compare the generated code with the
// definitions it came from; whether rosbridge refuses the other distro's
// fields, and what an aborted navigation goal actually carries, only a bridge
// can say.
//
// Setup, on a Humble or a Jazzy robot:
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml
//   python3 tool/robot_fixtures/nav_result_server.py
//
//   dart run example/real_distro_check.dart [ws://127.0.0.1:9090]
import 'dart:async';

import 'package:ros2_client/ros2_client.dart';
import 'package:ros2_msgs_common/humble/control_msgs.dart' as humble_control;
import 'package:ros2_msgs_common/humble/nav2_msgs.dart' as humble;
import 'package:ros2_msgs_common/jazzy/control_msgs.dart' as jazzy_control;
import 'package:ros2_msgs_common/jazzy/nav2_msgs.dart' as jazzy;
import 'package:ros2_msgs_common/ros2_msgs_common.dart';

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

/// Publishes [message] on a fresh topic and reports whether the bridge
/// delivered it back, which it does only if it could build the ROS message.
Future<bool> delivered<T>(Ros2Client ros, String topic, T message) async {
  final echo = ros
      .subscribeJson(topic, type: MessageRegistry.of<T>().rosType)
      .first
      .then((_) => true)
      .timeout(const Duration(seconds: 4), onTimeout: () => false);
  // Give the bridge's subscription time to match the publisher.
  await Future<void>.delayed(const Duration(milliseconds: 800));
  final publisher = ros.advertise<T>(topic);
  final ticker = Timer.periodic(
      const Duration(milliseconds: 200), (_) => publisher.publish(message));
  try {
    return await echo;
  } finally {
    ticker.cancel();
    publisher.close();
  }
}

Future<void> main(List<String> args) async {
  registerStandardMessages();
  // Both sets, deliberately: the registry is keyed by Dart type as well as by
  // ROS name, and this check needs each distro's classes by Dart type. An app
  // registers one.
  registerHumbleMessages();
  registerJazzyMessages();

  final uri = Uri.parse(args.isNotEmpty ? args.first : 'ws://127.0.0.1:9090');
  final ros = Ros2Client(uri);
  await ros.connect();
  final distro = (await ros.probeBridge()).distro;
  print('Connected to $uri, ROS 2 $distro\n');
  if (distro != 'humble' && distro != 'jazzy') {
    print('This check knows Humble and Jazzy only.');
    await ros.close();
    return;
  }
  final isJazzy = distro == 'jazzy';

  await check('$distro accepts its own controller state', () async {
    final ok = isJazzy
        ? await delivered(ros, '/distro_check/own',
            jazzy_control.JointTrajectoryControllerState(jointNames: ['j1']))
        : await delivered(ros, '/distro_check/own',
            humble_control.JointTrajectoryControllerState(jointNames: ['j1']));
    expect(ok, 'the bridge did not deliver its own distro\'s message');
  });

  await check('$distro refuses the other distro\'s controller state', () async {
    // Humble's carries desired/actual, which Jazzy removed; Jazzy's carries
    // speed_scaling_factor, which Humble never had.
    final ok = isJazzy
        ? await delivered(ros, '/distro_check/other',
            humble_control.JointTrajectoryControllerState(jointNames: ['j1']))
        : await delivered(ros, '/distro_check/other',
            jazzy_control.JointTrajectoryControllerState(jointNames: ['j1']));
    expect(!ok, 'the bridge delivered a field its distro does not define');
  });

  Future<Object> navigate(double x) async {
    final goalPose = PoseStamped(
        header: const Header(frameId: 'map'),
        pose: Pose(position: Point(x: x)));
    try {
      return isJazzy
          ? await ros
              .sendGoal<jazzy.NavigateToPoseGoal, jazzy.NavigateToPoseFeedback,
                      jazzy.NavigateToPoseResult>(
                  '/navigate_to_pose', jazzy.NavigateToPoseGoal(pose: goalPose))
              .result
          : await ros
              .sendGoal<
                      humble.NavigateToPoseGoal,
                      humble.NavigateToPoseFeedback,
                      humble.NavigateToPoseResult>('/navigate_to_pose',
                  humble.NavigateToPoseGoal(pose: goalPose))
              .result;
    } on ActionFailedException catch (e) {
      return e;
    }
  }

  await check('a navigation goal that succeeds decodes its result', () async {
    final outcome = await navigate(1);
    expect(
        outcome is jazzy.NavigateToPoseResult ||
            outcome is humble.NavigateToPoseResult,
        'got $outcome');
  });

  await check('an aborted navigation goal keeps its result', () async {
    final outcome = await navigate(-1);
    expect(outcome is ActionFailedException, 'did not fail: $outcome');
    final failure = outcome as ActionFailedException;
    expect(failure.status == GoalStatus.aborted, 'status ${failure.status}');
    if (isJazzy) {
      final result = failure.result;
      expect(result is jazzy.NavigateToPoseResult, 'result was $result');
      result as jazzy.NavigateToPoseResult;
      expect(result.errorCode == 204 && result.errorMsg == 'goal outside map',
          'error ${result.errorCode} "${result.errorMsg}"');
      print('          error_code ${result.errorCode}: ${result.errorMsg}');
    } else {
      // Humble's result has no error fields to carry a reason in.
      expect(failure.result is humble.NavigateToPoseResult,
          'result was ${failure.result}');
    }
  });

  await ros.close();
  print('\n$passed passed, $failed failed');
  if (failed > 0) throw StateError('$failed checks failed');
}
