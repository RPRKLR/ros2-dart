// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package nav_msgs

import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;
import 'geometry_msgs.dart';

/// An array of navigation goals
///
/// `nav_msgs/msg/Goals`
final class Goals implements RosMessage {
  Goals({
    ros2.Header? header,
    this.goals = const [],
  }) : header = header ?? ros2.Header();

  factory Goals.fromJson(Map<String, Object?> json) => Goals(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        goals: Field.asList<ros2.PoseStamped>(
            json['goals'], ros2.PoseStamped.fromJson),
      );

  final ros2.Header header;
  final List<ros2.PoseStamped> goals;

  @override
  String get rosType => 'nav_msgs/msg/Goals';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'goals': goals.map((ros2.PoseStamped e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goals &&
          other.header == header &&
          _listEquals(other.goals, goals));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...goals,
      ]);

  @override
  String toString() => 'Goals(${toJson()})';
}

/// An array of cells in a 2D grid
///
/// `nav_msgs/msg/GridCells`
final class GridCells implements RosMessage {
  GridCells({
    ros2.Header? header,
    this.cellWidth = 0,
    this.cellHeight = 0,
    this.cells = const [],
  }) : header = header ?? ros2.Header();

  factory GridCells.fromJson(Map<String, Object?> json) => GridCells(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        cellWidth: Field.doubleAt(json, 'cell_width'),
        cellHeight: Field.doubleAt(json, 'cell_height'),
        cells: Field.asList<ros2.Point>(json['cells'], ros2.Point.fromJson),
      );

  final ros2.Header header;
  final double cellWidth;
  final double cellHeight;
  final List<ros2.Point> cells;

  @override
  String get rosType => 'nav_msgs/msg/GridCells';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'cell_width': cellWidth,
        'cell_height': cellHeight,
        'cells': cells.map((ros2.Point e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GridCells &&
          other.header == header &&
          other.cellWidth == cellWidth &&
          other.cellHeight == cellHeight &&
          _listEquals(other.cells, cells));

  @override
  int get hashCode => Object.hashAll([
        header,
        cellWidth,
        cellHeight,
        ...cells,
      ]);

  @override
  String toString() => 'GridCells(${toJson()})';
}

/// An array of trajectory points that represents a trajectory for a robot to follow.
///
/// `nav_msgs/msg/Trajectory`
final class Trajectory implements RosMessage {
  Trajectory({
    ros2.Header? header,
    this.points = const [],
  }) : header = header ?? ros2.Header();

  factory Trajectory.fromJson(Map<String, Object?> json) => Trajectory(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        points: Field.asList<TrajectoryPoint>(
            json['points'], TrajectoryPoint.fromJson),
      );

  final ros2.Header header;
  final List<TrajectoryPoint> points;

  @override
  String get rosType => 'nav_msgs/msg/Trajectory';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'points': points.map((TrajectoryPoint e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trajectory &&
          other.header == header &&
          _listEquals(other.points, points));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...points,
      ]);

  @override
  String toString() => 'Trajectory(${toJson()})';
}

/// Trajectory point state
///
/// `nav_msgs/msg/TrajectoryPoint`
final class TrajectoryPoint implements RosMessage {
  TrajectoryPoint({
    ros2.Header? header,
    ros2.Pose? pose,
    ros2.Twist? velocity,
    Accel? acceleration,
    Wrench? effort,
  })  : header = header ?? ros2.Header(),
        pose = pose ?? ros2.Pose(),
        velocity = velocity ?? ros2.Twist(),
        acceleration = acceleration ?? Accel(),
        effort = effort ?? Wrench();

  factory TrajectoryPoint.fromJson(Map<String, Object?> json) =>
      TrajectoryPoint(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        pose: Field.asMessage(json['pose'], ros2.Pose.fromJson),
        velocity: Field.asMessage(json['velocity'], ros2.Twist.fromJson),
        acceleration: Field.asMessage(json['acceleration'], Accel.fromJson),
        effort: Field.asMessage(json['effort'], Wrench.fromJson),
      );

  final ros2.Header header;
  final ros2.Pose pose;
  final ros2.Twist velocity;
  final Accel acceleration;
  final Wrench effort;

  @override
  String get rosType => 'nav_msgs/msg/TrajectoryPoint';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'pose': pose.toJson(),
        'velocity': velocity.toJson(),
        'acceleration': acceleration.toJson(),
        'effort': effort.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrajectoryPoint &&
          other.header == header &&
          other.pose == pose &&
          other.velocity == velocity &&
          other.acceleration == acceleration &&
          other.effort == effort);

  @override
  int get hashCode => Object.hashAll([
        header,
        pose,
        velocity,
        acceleration,
        effort,
      ]);

  @override
  String toString() => 'TrajectoryPoint(${toJson()})';
}

/// Get the map as a nav_msgs/OccupancyGrid
///
/// `nav_msgs/msg/GetMap_Request`
final class GetMapRequest implements RosMessage {
  const GetMapRequest();

  factory GetMapRequest.fromJson(Map<String, Object?> json) => GetMapRequest();

  @override
  String get rosType => 'nav_msgs/msg/GetMap_Request';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GetMapRequest;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'GetMapRequest(${toJson()})';
}

/// The current map hosted by this map service.
///
/// `nav_msgs/msg/GetMap_Response`
final class GetMapResponse implements RosMessage {
  GetMapResponse({
    ros2.OccupancyGrid? map,
  }) : map = map ?? ros2.OccupancyGrid.fromJson(const {});

  factory GetMapResponse.fromJson(Map<String, Object?> json) => GetMapResponse(
        map: Field.asMessage(json['map'], ros2.OccupancyGrid.fromJson),
      );

  final ros2.OccupancyGrid map;

  @override
  String get rosType => 'nav_msgs/msg/GetMap_Response';

  @override
  Map<String, Object?> toJson() => {
        'map': map.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is GetMapResponse && other.map == map);

  @override
  int get hashCode => Object.hashAll([
        map,
      ]);

  @override
  String toString() => 'GetMapResponse(${toJson()})';
}

/// Get a plan from the current position to the goal Pose
///
/// `nav_msgs/msg/GetPlan_Request`
final class GetPlanRequest implements RosMessage {
  GetPlanRequest({
    ros2.PoseStamped? start,
    ros2.PoseStamped? goal,
    this.tolerance = 0,
  })  : start = start ?? ros2.PoseStamped(),
        goal = goal ?? ros2.PoseStamped();

  factory GetPlanRequest.fromJson(Map<String, Object?> json) => GetPlanRequest(
        start: Field.asMessage(json['start'], ros2.PoseStamped.fromJson),
        goal: Field.asMessage(json['goal'], ros2.PoseStamped.fromJson),
        tolerance: Field.doubleAt(json, 'tolerance'),
      );

  final ros2.PoseStamped start;
  final ros2.PoseStamped goal;
  final double tolerance;

  @override
  String get rosType => 'nav_msgs/msg/GetPlan_Request';

  @override
  Map<String, Object?> toJson() => {
        'start': start.toJson(),
        'goal': goal.toJson(),
        'tolerance': tolerance,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetPlanRequest &&
          other.start == start &&
          other.goal == goal &&
          other.tolerance == tolerance);

  @override
  int get hashCode => Object.hashAll([
        start,
        goal,
        tolerance,
      ]);

  @override
  String toString() => 'GetPlanRequest(${toJson()})';
}

/// Array of poses from start to goal if one was successfully found.
///
/// `nav_msgs/msg/GetPlan_Response`
final class GetPlanResponse implements RosMessage {
  GetPlanResponse({
    ros2.RosPath? plan,
  }) : plan = plan ?? ros2.RosPath();

  factory GetPlanResponse.fromJson(Map<String, Object?> json) =>
      GetPlanResponse(
        plan: Field.asMessage(json['plan'], ros2.RosPath.fromJson),
      );

  final ros2.RosPath plan;

  @override
  String get rosType => 'nav_msgs/msg/GetPlan_Response';

  @override
  Map<String, Object?> toJson() => {
        'plan': plan.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetPlanResponse && other.plan == plan);

  @override
  int get hashCode => Object.hashAll([
        plan,
      ]);

  @override
  String toString() => 'GetPlanResponse(${toJson()})';
}

/// URL of map resource
/// Can be an absolute path to a file: file:///path/to/maps/floor1.yaml
/// Or, relative to a ROS package: package://my_ros_package/maps/floor2.yaml
///
/// `nav_msgs/msg/LoadMap_Request`
final class LoadMapRequest implements RosMessage {
  const LoadMapRequest({
    this.mapUrl = '',
  });

  factory LoadMapRequest.fromJson(Map<String, Object?> json) => LoadMapRequest(
        mapUrl: Field.stringAt(json, 'map_url'),
      );

  final String mapUrl;

  @override
  String get rosType => 'nav_msgs/msg/LoadMap_Request';

  @override
  Map<String, Object?> toJson() => {
        'map_url': mapUrl,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoadMapRequest && other.mapUrl == mapUrl);

  @override
  int get hashCode => Object.hashAll([
        mapUrl,
      ]);

  @override
  String toString() => 'LoadMapRequest(${toJson()})';
}

/// Result code definitions
///
/// `nav_msgs/msg/LoadMap_Response`
final class LoadMapResponse implements RosMessage {
  LoadMapResponse({
    ros2.OccupancyGrid? map,
    this.result = 0,
  }) : map = map ?? ros2.OccupancyGrid.fromJson(const {});

  factory LoadMapResponse.fromJson(Map<String, Object?> json) =>
      LoadMapResponse(
        map: Field.asMessage(json['map'], ros2.OccupancyGrid.fromJson),
        result: Field.intAt(json, 'result'),
      );

  static const int resultSuccess = 0;
  static const int resultMapDoesNotExist = 1;
  static const int resultInvalidMapData = 2;
  static const int resultInvalidMapMetadata = 3;
  static const int resultUndefinedFailure = 255;

  final ros2.OccupancyGrid map;
  final int result;

  @override
  String get rosType => 'nav_msgs/msg/LoadMap_Response';

  @override
  Map<String, Object?> toJson() => {
        'map': map.toJson(),
        'result': result,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoadMapResponse && other.map == map && other.result == result);

  @override
  int get hashCode => Object.hashAll([
        map,
        result,
      ]);

  @override
  String toString() => 'LoadMapResponse(${toJson()})';
}

/// Set a new map together with an initial pose
///
/// `nav_msgs/msg/SetMap_Request`
final class SetMapRequest implements RosMessage {
  SetMapRequest({
    ros2.OccupancyGrid? map,
    PoseWithCovarianceStamped? initialPose,
  })  : map = map ?? ros2.OccupancyGrid.fromJson(const {}),
        initialPose = initialPose ?? PoseWithCovarianceStamped();

  factory SetMapRequest.fromJson(Map<String, Object?> json) => SetMapRequest(
        map: Field.asMessage(json['map'], ros2.OccupancyGrid.fromJson),
        initialPose: Field.asMessage(
            json['initial_pose'], PoseWithCovarianceStamped.fromJson),
      );

  final ros2.OccupancyGrid map;
  final PoseWithCovarianceStamped initialPose;

  @override
  String get rosType => 'nav_msgs/msg/SetMap_Request';

  @override
  Map<String, Object?> toJson() => {
        'map': map.toJson(),
        'initial_pose': initialPose.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetMapRequest &&
          other.map == map &&
          other.initialPose == initialPose);

  @override
  int get hashCode => Object.hashAll([
        map,
        initialPose,
      ]);

  @override
  String toString() => 'SetMapRequest(${toJson()})';
}

/// True if the map was successfully set, false otherwise.
///
/// `nav_msgs/msg/SetMap_Response`
final class SetMapResponse implements RosMessage {
  const SetMapResponse({
    this.success = false,
  });

  factory SetMapResponse.fromJson(Map<String, Object?> json) => SetMapResponse(
        success: Field.boolAt(json, 'success'),
      );

  final bool success;

  @override
  String get rosType => 'nav_msgs/msg/SetMap_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetMapResponse && other.success == success);

  @override
  int get hashCode => Object.hashAll([
        success,
      ]);

  @override
  String toString() => 'SetMapResponse(${toJson()})';
}

/// Element-wise list comparison used by generated `==`.
bool _listEquals(List<Object?> a, List<Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Registers every message in `nav_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerNavMsgs() {
  MessageRegistry.register(const MessageCodec<Goals>(
    rosType: 'nav_msgs/msg/Goals',
    fromJson: Goals.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GridCells>(
    rosType: 'nav_msgs/msg/GridCells',
    fromJson: GridCells.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Trajectory>(
    rosType: 'nav_msgs/msg/Trajectory',
    fromJson: Trajectory.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<TrajectoryPoint>(
    rosType: 'nav_msgs/msg/TrajectoryPoint',
    fromJson: TrajectoryPoint.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetMapRequest>(
    rosType: 'nav_msgs/msg/GetMap_Request',
    fromJson: GetMapRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetMapResponse>(
    rosType: 'nav_msgs/msg/GetMap_Response',
    fromJson: GetMapResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetPlanRequest>(
    rosType: 'nav_msgs/msg/GetPlan_Request',
    fromJson: GetPlanRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetPlanResponse>(
    rosType: 'nav_msgs/msg/GetPlan_Response',
    fromJson: GetPlanResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<LoadMapRequest>(
    rosType: 'nav_msgs/msg/LoadMap_Request',
    fromJson: LoadMapRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<LoadMapResponse>(
    rosType: 'nav_msgs/msg/LoadMap_Response',
    fromJson: LoadMapResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SetMapRequest>(
    rosType: 'nav_msgs/msg/SetMap_Request',
    fromJson: SetMapRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SetMapResponse>(
    rosType: 'nav_msgs/msg/SetMap_Response',
    fromJson: SetMapResponse.fromJson,
    toJson: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<GetMapRequest, GetMapResponse>(
    serviceType: 'nav_msgs/srv/GetMap',
    encodeRequest: _toJson,
    decodeResponse: GetMapResponse.fromJson,
    decodeRequest: GetMapRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<GetPlanRequest, GetPlanResponse>(
    serviceType: 'nav_msgs/srv/GetPlan',
    encodeRequest: _toJson,
    decodeResponse: GetPlanResponse.fromJson,
    decodeRequest: GetPlanRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<LoadMapRequest, LoadMapResponse>(
    serviceType: 'nav_msgs/srv/LoadMap',
    encodeRequest: _toJson,
    decodeResponse: LoadMapResponse.fromJson,
    decodeRequest: LoadMapRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<SetMapRequest, SetMapResponse>(
    serviceType: 'nav_msgs/srv/SetMap',
    encodeRequest: _toJson,
    decodeResponse: SetMapResponse.fromJson,
    decodeRequest: SetMapRequest.fromJson,
    encodeResponse: _toJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
