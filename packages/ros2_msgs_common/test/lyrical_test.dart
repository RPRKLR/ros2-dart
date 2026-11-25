// The Lyrical set, and what separates it from Jazzy on the wire.
//
// Its own file, so its own isolate and registry: see distro_test.dart.
import 'package:ros2_client/ros2_client.dart';
import 'package:ros2_msgs_common/jazzy/lifecycle_msgs.dart' as jazzy_lifecycle;
import 'package:ros2_msgs_common/jazzy/nav2_msgs.dart' as jazzy;
import 'package:ros2_msgs_common/lyrical/lifecycle_msgs.dart' as lifecycle;
import 'package:ros2_msgs_common/lyrical/nav2_msgs.dart' as lyrical;
import 'package:ros2_msgs_common/lyrical/nav_msgs.dart' as nav;
import 'package:ros2_msgs_common/ros2_msgs_common.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    registerStandardMessages();
    registerLyricalMessages();
  });

  test('registers without shadowing the bundled types', () {
    expect(MessageRegistry.knownTypes, hasLength(greaterThan(320)));
    expect(MessageRegistry.of<Odometry>().rosType, 'nav_msgs/msg/Odometry');
    // Lyrical's nav2_msgs pulls in nav_msgs types the client does not bundle;
    // the bundled ones must still resolve to the client's classes.
    expect(
        MessageRegistry.byRosType('nav_msgs/msg/OccupancyGrid')!
            .fromJson(const {}),
        isA<OccupancyGrid>());
    expect(MessageRegistry.byRosType('nav_msgs/msg/Goals')!.fromJson(const {}),
        isA<nav.Goals>());
  });

  test('NavigateToPose keeps the goal and result Jazzy has', () {
    final goal = lyrical.NavigateToPoseGoal(behaviorTree: 'bt.xml').toJson();
    expect(
        goal.keys,
        unorderedEquals(
            jazzy.NavigateToPoseGoal(behaviorTree: 'bt.xml').toJson().keys));
    final result = lyrical.NavigateToPoseResult.fromJson(
        const {'error_code': 9003, 'error_msg': 'timed out'});
    expect(result.errorCode, lyrical.NavigateToPoseResult.timeout);
    expect(result.errorMsg, 'timed out');
  });

  test('costmap clearing takes plugins and answers success', () {
    // A Jazzy request carries a `request` field that a Lyrical bridge refuses.
    expect(jazzy.ClearEntireCostmapRequest().toJson().keys, ['request']);
    expect(
        lyrical.ClearEntireCostmapRequest(plugins: ['obstacle_layer']).toJson(),
        {
          'plugins': ['obstacle_layer']
        });
    expect(
        lyrical.ClearEntireCostmapResponse.fromJson(const {'success': true})
            .success,
        isTrue);
    final codec = ServiceRegistry.of<lyrical.ClearEntireCostmapRequest,
        lyrical.ClearEntireCostmapResponse>();
    expect(codec.serviceType, 'nav2_msgs/srv/ClearEntireCostmap');
  });

  test('TransitionEvent renamed timestamp to stamp', () {
    expect(lifecycle.TransitionEvent().toJson(), contains('stamp'));
    expect(lifecycle.TransitionEvent().toJson(), isNot(contains('timestamp')));
    expect(jazzy_lifecycle.TransitionEvent().toJson(), contains('timestamp'));
  });
}
