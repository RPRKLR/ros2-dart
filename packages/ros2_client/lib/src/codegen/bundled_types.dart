/// The message types `package:ros2_client` already provides, and how generated
/// code refers to them instead of emitting its own copy.
library;

/// Types bundled with the client, as `package/TypeName` mapped to the Dart
/// class that provides them.
///
/// Regenerating a bundled type is not merely wasteful. Both classes register a
/// codec for the same ROS type name and the last registration wins, so
/// `MessageRegistry.byRosType` silently starts resolving to whichever library
/// was registered second — and the widgets in `ros2_flutter`, which are typed
/// against the bundled classes, cannot accept the generated ones.
///
/// The Dart names are not always what the emitter would derive: `std_msgs/Bool`
/// is hand-written as `BoolMsg`, not `Bool`. `bundled_types_test.dart` pins
/// this map against the registry so the two cannot drift apart.
abstract final class BundledTypes {
  static const Map<String, String> dartNames = {
    'builtin_interfaces/Duration': 'RosDuration',
    'builtin_interfaces/Time': 'RosTime',
    'geometry_msgs/Point': 'Point',
    'geometry_msgs/Pose': 'Pose',
    'geometry_msgs/PoseStamped': 'PoseStamped',
    'geometry_msgs/Quaternion': 'Quaternion',
    'geometry_msgs/Transform': 'RosTransform',
    'geometry_msgs/TransformStamped': 'RosTransformStamped',
    'geometry_msgs/Twist': 'Twist',
    'geometry_msgs/Vector3': 'Vector3',
    'nav_msgs/MapMetaData': 'MapMetaData',
    'nav_msgs/OccupancyGrid': 'OccupancyGrid',
    'nav_msgs/Odometry': 'Odometry',
    'nav_msgs/Path': 'RosPath',
    'sensor_msgs/BatteryState': 'BatteryState',
    'sensor_msgs/CompressedImage': 'CompressedImage',
    'sensor_msgs/Image': 'RosImage',
    'sensor_msgs/Imu': 'Imu',
    'sensor_msgs/JointState': 'JointState',
    'sensor_msgs/LaserScan': 'LaserScan',
    'sensor_msgs/NavSatFix': 'NavSatFix',
    'std_msgs/Bool': 'BoolMsg',
    'std_msgs/ColorRGBA': 'ColorRGBA',
    'std_msgs/Empty': 'EmptyMsg',
    'std_msgs/Float64': 'Float64Msg',
    'std_msgs/Header': 'Header',
    'std_msgs/Int32': 'Int32Msg',
    'std_msgs/String': 'StringMsg',
    'tf2_msgs/TFMessage': 'TFMessage',
  };

  /// Bundled types with no zero-argument constructor.
  ///
  /// Their `uint8[]` and `float64[]` fields are `required` for the same reason
  /// generated code uses a `??` initialiser for them: there is no const empty
  /// typed list. A generated field of one of these types falls back to
  /// `fromJson(const {})`, which is exactly the ROS default because none of
  /// these definitions declares a non-zero default.
  ///
  /// Types *with* a zero-argument constructor must not be listed here.
  /// `geometry_msgs/Quaternion` is the reason: its `.msg` declares
  /// `float64 w 1`, so `Quaternion()` is the identity rotation while
  /// `Quaternion.fromJson(const {})` would be an all-zero, invalid one.
  static const Set<String> needFromJsonFallback = {
    'nav_msgs/OccupancyGrid',
    'sensor_msgs/CompressedImage',
    'sensor_msgs/Image',
    'sensor_msgs/JointState',
    'sensor_msgs/LaserScan',
  };

  /// `pkg/msg/Name`, `pkg/Name` and a bare `Name` within [package] all
  /// normalise to the `pkg/Name` key this map uses.
  static String normalise(String rosType, {String? package}) {
    final parts = rosType.split('/').where((p) => p.isNotEmpty).toList();
    return switch (parts.length) {
      0 => '',
      1 => package == null ? '' : '$package/${parts.first}',
      _ => '${parts.first}/${parts.last}',
    };
  }
}

/// Decides, for one generated library, which types come from the client and
/// which the library emits itself.
final class TypeResolver {
  const TypeResolver({
    required this.package,
    this.useBundled = true,
    this.prefix = 'ros2',
  });

  /// Emits every type, deferring to nothing.
  const TypeResolver.standalone({required this.package})
      : useBundled = false,
        prefix = 'ros2';

  /// The ROS package being generated, used to qualify bare field types.
  final String package;

  /// Whether to defer to the types bundled with the client.
  final bool useBundled;

  /// Import prefix for the client barrel.
  ///
  /// Prefixed rather than bare: the barrel exports plenty of non-message names
  /// (`Ros2Client`, `TfBuffer`, `Compression`), and a custom ROS package is
  /// free to define a message that collides with one of them.
  final String prefix;

  /// True when [rosType] should come from the client rather than be emitted.
  bool isProvided(String rosType) =>
      useBundled &&
      BundledTypes.dartNames
          .containsKey(BundledTypes.normalise(rosType, package: package));

  /// The Dart name to write for [rosType], qualified when it comes from the
  /// client.
  String? providedName(String rosType) {
    if (!useBundled) return null;
    final name = BundledTypes
        .dartNames[BundledTypes.normalise(rosType, package: package)];
    return name == null ? null : '$prefix.$name';
  }

  /// The expression that default-constructs a provided [rosType], for the `??`
  /// initialiser on a field of that type.
  String? providedFallback(String rosType) {
    final name = providedName(rosType);
    if (name == null) return null;
    final key = BundledTypes.normalise(rosType, package: package);
    return BundledTypes.needFromJsonFallback.contains(key)
        ? '$name.fromJson(const {})'
        : '$name()';
  }
}
