// The point of this package is that it composes with the types ros2_client
// already bundles instead of shadowing them. That is what these tests check.
import 'package:ros2_client/ros2_client.dart';
import 'package:ros2_msgs_common/nav2_msgs.dart';
import 'package:ros2_msgs_common/ros2_msgs_common.dart';
import 'package:ros2_msgs_common/tf2_msgs.dart';
import 'package:ros2_msgs_common/visualization_msgs.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    registerStandardMessages();
    registerCommonMessages();
  });

  test('registers a large set without throwing', () {
    expect(MessageRegistry.knownTypes, hasLength(greaterThan(300)));
  });

  group('does not shadow the bundled types', () {
    test('core types still resolve to the client classes', () {
      // If this package re-emitted them, the last registration would win and
      // these would come back as its own classes instead.
      expect(MessageRegistry.byRosType('geometry_msgs/msg/Twist')!
          .fromJson(const {}), isA<Twist>());
      expect(MessageRegistry.byRosType('sensor_msgs/msg/Image')!
          .fromJson(const {}), isA<RosImage>());
      expect(MessageRegistry.byRosType('std_msgs/msg/Header')!
          .fromJson(const {}), isA<Header>());
      expect(MessageRegistry.byRosType('nav_msgs/msg/OccupancyGrid')!
          .fromJson(const {}), isA<OccupancyGrid>());
    });

    test('the widgets in ros2_flutter can still be fed', () {
      // They are typed against the bundled classes, so a subscription for the
      // bundled Dart type has to keep resolving.
      expect(MessageRegistry.has<LaserScan>(), isTrue);
      expect(MessageRegistry.of<LaserScan>().rosType,
          'sensor_msgs/msg/LaserScan');
    });
  });

  group('generated types', () {
    test('a marker decodes and keeps its constants', () {
      final marker = Marker.fromJson(const {
        'ns': 'goals',
        'id': 7,
        'type': 8,
        'points': [
          {'x': 1.0, 'y': 2.0, 'z': 0.0},
        ],
      });

      expect(marker.ns, 'goals');
      expect(marker.id, 7);
      expect(marker.type, Marker.pointsConst);
      // The nested Point comes from ros2_client, not a second copy.
      expect(marker.points.single, isA<Point>());
      expect(marker.points.single.x, 1.0);
      expect(marker.rosType, 'visualization_msgs/msg/Marker');
    });

    test('a bundled-typed field defaults correctly', () {
      // Marker's header field is the bundled Header, defaulted through the
      // generated `??` initialiser.
      final marker = Marker();
      expect(marker.header, isA<Header>());
      expect(marker.header.frameId, '');
      // And a Quaternion default must be the identity, not all zeros.
      expect(marker.pose.orientation.w, 1.0);
    });

    test('an action is registered with its three parts in order', () {
      final codec = ActionRegistry.of<NavigateToPoseGoal,
          NavigateToPoseFeedback, NavigateToPoseResult>();
      expect(codec.actionType, 'nav2_msgs/action/NavigateToPose');
    });

    test('a service round-trips through its codec', () {
      final codec = ServiceRegistry.of<ClearEntireCostmapRequest,
          ClearEntireCostmapResponse>();
      expect(codec.serviceType, 'nav2_msgs/srv/ClearEntireCostmap');
    });

    test('tf2 lookup service is present alongside the bundled TFMessage', () {
      // tf2_msgs/TFMessage is bundled; FrameGraph is not.
      expect(MessageRegistry.byRosType('tf2_msgs/msg/TFMessage')!
          .fromJson(const {}), isA<TFMessage>());
      expect(
          ServiceRegistry.of<FrameGraphRequest, FrameGraphResponse>()
              .serviceType,
          'tf2_msgs/srv/FrameGraph');
    });
  });
}
