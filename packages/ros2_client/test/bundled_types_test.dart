// Pins BundledTypes against what the client actually registers. Without this
// the two drift the moment a message is added to or renamed in the bundled
// set, and generated code silently starts emitting a duplicate codec for a
// type the client already owns.
import 'package:ros2_client/ros2_client.dart';
import 'package:ros2_client/src/codegen/bundled_types.dart';
import 'package:ros2_client/src/codegen/dart_emitter.dart';
import 'package:test/test.dart';

/// `geometry_msgs/msg/Twist` -> `geometry_msgs/Twist`, matching the map's keys.
String short(String rosType) {
  final parts = rosType.split('/');
  return parts.length == 3 ? '${parts[0]}/${parts[2]}' : rosType;
}

void main() {
  setUpAll(registerStandardMessages);

  test('covers exactly the types the client registers', () {
    final registered = MessageRegistry.knownTypes.map(short).toSet();
    final tabled = BundledTypes.dartNames.keys.toSet();

    expect(tabled.difference(registered), isEmpty,
        reason: 'BundledTypes lists types the client does not register; '
            'generated code would import a class that does not exist');
    expect(registered.difference(tabled), isEmpty,
        reason: 'the client registers types BundledTypes does not list; '
            'generated code would emit a second codec for them');
  });

  test('every listed Dart class resolves through the registry', () {
    // The map claims a Dart name for each type. If the name were wrong the
    // generated import would not compile, which no unit test would catch --
    // so check the codec exists for the ROS type at least.
    for (final entry in BundledTypes.dartNames.entries) {
      expect(MessageRegistry.byRosType(entry.key), isNotNull,
          reason: '${entry.key} is listed as bundled but has no codec');
    }
  });

  test('records the names the emitter would get wrong', () {
    // These are hand-written with names the emitter does not derive. The map
    // exists precisely because className() is not the answer for them.
    expect(DartEmitter.className('std_msgs/Bool'), 'Bool');
    expect(BundledTypes.dartNames['std_msgs/Bool'], 'BoolMsg');
    expect(DartEmitter.className('std_msgs/Empty'), 'Empty');
    expect(BundledTypes.dartNames['std_msgs/Empty'], 'EmptyMsg');
    expect(DartEmitter.className('std_msgs/Int32'), 'Int32');
    expect(BundledTypes.dartNames['std_msgs/Int32'], 'Int32Msg');
  });

  test('every bundled type is constructible the way generated code writes it',
      () {
    _compileFallbacks();

    // And the table agrees with which form each type needs.
    const resolver = TypeResolver(package: 'other_msgs');
    expect(resolver.providedFallback('sensor_msgs/Image'),
        'ros2.RosImage.fromJson(const {})');
    expect(resolver.providedFallback('geometry_msgs/Quaternion'),
        'ros2.Quaternion()');
    expect(resolver.providedFallback('other_msgs/Custom'), isNull);
  });

  test('needFromJsonFallback lists only real bundled types', () {
    expect(
        BundledTypes.needFromJsonFallback
            .difference(BundledTypes.dartNames.keys.toSet()),
        isEmpty);
  });

  group('TypeResolver', () {
    const resolver = TypeResolver(package: 'nav2_msgs');

    test('qualifies a bundled type and leaves others alone', () {
      expect(resolver.providedName('geometry_msgs/PoseStamped'),
          'ros2.PoseStamped');
      expect(resolver.providedName('geometry_msgs/msg/PoseStamped'),
          'ros2.PoseStamped');
      expect(resolver.providedName('nav2_msgs/Costmap'), isNull);
      expect(resolver.isProvided('geometry_msgs/Twist'), isTrue);
      expect(resolver.isProvided('nav2_msgs/Costmap'), isFalse);
    });

    test('resolves a bare type against the library being generated', () {
      // Inside geometry_msgs a field is written `Point`, not
      // `geometry_msgs/Point`, and still refers to a bundled type.
      const inGeometry = TypeResolver(package: 'geometry_msgs');
      expect(inGeometry.isProvided('Point'), isTrue);
      expect(inGeometry.providedName('Point'), 'ros2.Point');
      expect(inGeometry.isProvided('Polygon'), isFalse);
    });

    test('standalone defers to nothing', () {
      const standalone = TypeResolver.standalone(package: 'nav2_msgs');
      expect(standalone.isProvided('geometry_msgs/Twist'), isFalse);
      expect(standalone.providedName('geometry_msgs/Twist'), isNull);
    });
  });
}

/// Compiles the fallback expression for every bundled type, exactly as
/// `TypeResolver.providedFallback` writes it into generated code.
///
/// A string table cannot be type-checked, so this file is the check: if a
/// bundled class loses its zero-argument constructor, or one is wrongly listed
/// as needing the `fromJson` form, this stops compiling.
void _compileFallbacks() {
  // needFromJsonFallback -- no zero-argument constructor.
  RosImage.fromJson(const {});
  CompressedImage.fromJson(const {});
  LaserScan.fromJson(const {});
  JointState.fromJson(const {});
  OccupancyGrid.fromJson(const {});

  // Everything else, default-constructed.
  RosDuration();
  RosTime();
  Point();
  Pose();
  PoseStamped();
  Quaternion();
  RosTransform();
  RosTransformStamped();
  Twist();
  Vector3();
  MapMetaData();
  Odometry();
  RosPath();
  BatteryState();
  Imu();
  NavSatFix();
  BoolMsg();
  ColorRGBA();
  EmptyMsg();
  Float64Msg();
  Header();
  Int32Msg();
  StringMsg();
  TFMessage();
}
