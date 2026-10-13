// The Jazzy set, and what separates it from Humble.
//
// registration_test.dart registers Humble through the original entry point.
// This file registers Jazzy, which is safe only because every test file runs
// in its own isolate with its own registry.
import 'package:ros2_client/ros2_client.dart';
import 'package:ros2_msgs_common/humble/nav2_msgs.dart' as humble;
import 'package:ros2_msgs_common/jazzy/control_msgs.dart' as jazzy_control;
import 'package:ros2_msgs_common/jazzy/nav2_msgs.dart' as jazzy;
import 'package:ros2_msgs_common/nav2_msgs.dart' as unprefixed;
import 'package:ros2_msgs_common/ros2_msgs_common.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    registerStandardMessages();
    registerJazzyMessages();
  });

  test('the unprefixed libraries are the Humble ones', () {
    // Imports written against 0.2.0 must keep meaning what they meant.
    expect(unprefixed.NavigateToPoseResult, humble.NavigateToPoseResult);
  });

  group('Jazzy', () {
    test('registers without shadowing the bundled types', () {
      expect(MessageRegistry.knownTypes, hasLength(greaterThan(300)));
      expect(
          MessageRegistry.byRosType('geometry_msgs/msg/Twist')!
              .fromJson(const {}),
          isA<Twist>());
      expect(
          MessageRegistry.of<LaserScan>().rosType, 'sensor_msgs/msg/LaserScan');
    });

    test('registry resolves Jazzy classes, not Humble ones', () {
      final codec = ActionRegistry.of<jazzy.NavigateToPoseGoal,
          jazzy.NavigateToPoseFeedback, jazzy.NavigateToPoseResult>();
      expect(codec.actionType, 'nav2_msgs/action/NavigateToPose');
      expect(
          MessageRegistry.byRosType('nav2_msgs/msg/NavigateToPose_Result')!
              .fromJson(const {}),
          isA<jazzy.NavigateToPoseResult>());
    });

    test('a navigation result carries why it failed', () {
      // Humble's result has no error fields at all, so a Humble class reading
      // a Jazzy result drops the reason without complaint.
      const wire = {'error_code': 204, 'error_msg': 'goal outside map'};
      final result = jazzy.NavigateToPoseResult.fromJson(wire);
      expect(result.errorCode, 204);
      expect(result.errorMsg, 'goal outside map');
      expect(humble.NavigateToPoseResult.fromJson(wire).toJson(),
          isNot(contains('error_code')));
    });

    test('missed waypoints are objects, not indices', () {
      final result = jazzy.FollowWaypointsResult.fromJson(const {
        'missed_waypoints': [
          {'index': 2, 'error_code': 3},
        ],
      });
      expect(result.missedWaypoints.single.index, 2);
      expect(result.missedWaypoints.single.errorCode, 3);
    });

    test('a published message carries only fields Jazzy defines', () {
      // rosbridge rejects a field its distro does not know, so the Humble
      // controller state, with desired/actual, cannot be published to Jazzy.
      final keys = jazzy_control.JointTrajectoryControllerState().toJson().keys;
      expect(keys, contains('speed_scaling_factor'));
      expect(keys, isNot(contains('desired')));
      expect(keys, isNot(contains('actual')));
    });

    test('types new in Jazzy are present', () {
      expect(
          ActionRegistry.of<jazzy.DockRobotGoal, jazzy.DockRobotFeedback,
                  jazzy.DockRobotResult>()
              .actionType,
          'nav2_msgs/action/DockRobot');
    });
  });
}
