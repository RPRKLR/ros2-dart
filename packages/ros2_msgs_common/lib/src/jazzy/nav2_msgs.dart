// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package nav2_msgs

import 'dart:typed_data';

import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;
import 'geographic_msgs.dart';
import 'geometry_msgs.dart';

/// `nav2_msgs/msg/BehaviorTreeLog`
final class BehaviorTreeLog implements RosMessage {
  BehaviorTreeLog({
    ros2.RosTime? timestamp,
    this.eventLog = const [],
  }) : timestamp = timestamp ?? ros2.RosTime();

  factory BehaviorTreeLog.fromJson(Map<String, Object?> json) =>
      BehaviorTreeLog(
        timestamp: Field.asMessage(json['timestamp'], ros2.RosTime.fromJson),
        eventLog: Field.asList<BehaviorTreeStatusChange>(
            json['event_log'], BehaviorTreeStatusChange.fromJson),
      );

  /// ROS time that this log message was sent.
  final ros2.RosTime timestamp;
  final List<BehaviorTreeStatusChange> eventLog;

  @override
  String get rosType => 'nav2_msgs/msg/BehaviorTreeLog';

  @override
  Map<String, Object?> toJson() => {
        'timestamp': timestamp.toJson(),
        'event_log':
            eventLog.map((BehaviorTreeStatusChange e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BehaviorTreeLog &&
          other.timestamp == timestamp &&
          _listEquals(other.eventLog, eventLog));

  @override
  int get hashCode => Object.hashAll([
        timestamp,
        ...eventLog,
      ]);

  @override
  String toString() => 'BehaviorTreeLog(${toJson()})';
}

/// `nav2_msgs/msg/BehaviorTreeStatusChange`
final class BehaviorTreeStatusChange implements RosMessage {
  BehaviorTreeStatusChange({
    ros2.RosTime? timestamp,
    this.nodeName = '',
    this.uid = 0,
    this.previousStatus = '',
    this.currentStatus = '',
  }) : timestamp = timestamp ?? ros2.RosTime();

  factory BehaviorTreeStatusChange.fromJson(Map<String, Object?> json) =>
      BehaviorTreeStatusChange(
        timestamp: Field.asMessage(json['timestamp'], ros2.RosTime.fromJson),
        nodeName: Field.stringAt(json, 'node_name'),
        uid: Field.intAt(json, 'uid'),
        previousStatus: Field.stringAt(json, 'previous_status'),
        currentStatus: Field.stringAt(json, 'current_status'),
      );

  /// internal behavior tree event timestamp. Typically this is wall clock time
  final ros2.RosTime timestamp;
  final String nodeName;

  /// unique ID for this node
  final int uid;

  /// IDLE, RUNNING, SUCCESS or FAILURE
  final String previousStatus;

  /// IDLE, RUNNING, SUCCESS or FAILURE
  final String currentStatus;

  @override
  String get rosType => 'nav2_msgs/msg/BehaviorTreeStatusChange';

  @override
  Map<String, Object?> toJson() => {
        'timestamp': timestamp.toJson(),
        'node_name': nodeName,
        'uid': uid,
        'previous_status': previousStatus,
        'current_status': currentStatus,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BehaviorTreeStatusChange &&
          other.timestamp == timestamp &&
          other.nodeName == nodeName &&
          other.uid == uid &&
          other.previousStatus == previousStatus &&
          other.currentStatus == currentStatus);

  @override
  int get hashCode => Object.hashAll([
        timestamp,
        nodeName,
        uid,
        previousStatus,
        currentStatus,
      ]);

  @override
  String toString() => 'BehaviorTreeStatusChange(${toJson()})';
}

/// Name of configured polygons
///
/// `nav2_msgs/msg/CollisionDetectorState`
final class CollisionDetectorState implements RosMessage {
  const CollisionDetectorState({
    this.polygons = const [],
    this.detections = const [],
  });

  factory CollisionDetectorState.fromJson(Map<String, Object?> json) =>
      CollisionDetectorState(
        polygons: Field.asStringList(json['polygons']),
        detections: Field.asBoolList(json['detections']),
      );

  final List<String> polygons;
  final List<bool> detections;

  @override
  String get rosType => 'nav2_msgs/msg/CollisionDetectorState';

  @override
  Map<String, Object?> toJson() => {
        'polygons': polygons,
        'detections': detections,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollisionDetectorState &&
          _listEquals(other.polygons, polygons) &&
          _listEquals(other.detections, detections));

  @override
  int get hashCode => Object.hashAll([
        ...polygons,
        ...detections,
      ]);

  @override
  String toString() => 'CollisionDetectorState(${toJson()})';
}

/// Action type for robot in Collision Monitor
///
/// `nav2_msgs/msg/CollisionMonitorState`
final class CollisionMonitorState implements RosMessage {
  const CollisionMonitorState({
    this.actionType = 0,
    this.polygonName = '',
  });

  factory CollisionMonitorState.fromJson(Map<String, Object?> json) =>
      CollisionMonitorState(
        actionType: Field.intAt(json, 'action_type'),
        polygonName: Field.stringAt(json, 'polygon_name'),
      );

  /// No action
  static const int doNothing = 0;

  /// Stop the robot
  static const int stop = 1;

  /// Slowdown in percentage from current operating speed
  static const int slowdown = 2;

  /// Keep constant time interval before collision
  static const int approach = 3;

  /// Sets a limit of velocities if pts in range
  static const int limit = 4;

  final int actionType;
  final String polygonName;

  @override
  String get rosType => 'nav2_msgs/msg/CollisionMonitorState';

  @override
  Map<String, Object?> toJson() => {
        'action_type': actionType,
        'polygon_name': polygonName,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollisionMonitorState &&
          other.actionType == actionType &&
          other.polygonName == polygonName);

  @override
  int get hashCode => Object.hashAll([
        actionType,
        polygonName,
      ]);

  @override
  String toString() => 'CollisionMonitorState(${toJson()})';
}

/// This represents a 2-D grid map, in which each cell has an associated cost
///
/// `nav2_msgs/msg/Costmap`
final class Costmap implements RosMessage {
  Costmap({
    ros2.Header? header,
    CostmapMetaData? metadata,
    Uint8List? data,
  })  : header = header ?? ros2.Header(),
        metadata = metadata ?? CostmapMetaData(),
        data = data ?? Uint8List(0);

  factory Costmap.fromJson(Map<String, Object?> json) => Costmap(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        metadata: Field.asMessage(json['metadata'], CostmapMetaData.fromJson),
        data: Field.asBytes(json['data']),
      );

  final ros2.Header header;
  final CostmapMetaData metadata;
  final Uint8List data;

  @override
  String get rosType => 'nav2_msgs/msg/Costmap';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'metadata': metadata.toJson(),
        'data': Field.encodeBytes(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Costmap &&
          other.header == header &&
          other.metadata == metadata &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        header,
        metadata,
        ...data,
      ]);

  @override
  String toString() => 'Costmap(${toJson()})';
}

/// `nav2_msgs/msg/CostmapFilterInfo`
final class CostmapFilterInfo implements RosMessage {
  CostmapFilterInfo({
    ros2.Header? header,
    this.type = 0,
    this.filterMaskTopic = '',
    this.base = 0,
    this.multiplier = 0,
  }) : header = header ?? ros2.Header();

  factory CostmapFilterInfo.fromJson(Map<String, Object?> json) =>
      CostmapFilterInfo(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        type: Field.intAt(json, 'type'),
        filterMaskTopic: Field.stringAt(json, 'filter_mask_topic'),
        base: Field.doubleAt(json, 'base'),
        multiplier: Field.doubleAt(json, 'multiplier'),
      );

  final ros2.Header header;
  final int type;
  final String filterMaskTopic;
  final double base;
  final double multiplier;

  @override
  String get rosType => 'nav2_msgs/msg/CostmapFilterInfo';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'type': type,
        'filter_mask_topic': filterMaskTopic,
        'base': base,
        'multiplier': multiplier,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CostmapFilterInfo &&
          other.header == header &&
          other.type == type &&
          other.filterMaskTopic == filterMaskTopic &&
          other.base == base &&
          other.multiplier == multiplier);

  @override
  int get hashCode => Object.hashAll([
        header,
        type,
        filterMaskTopic,
        base,
        multiplier,
      ]);

  @override
  String toString() => 'CostmapFilterInfo(${toJson()})';
}

/// This hold basic information about the characteristics of the Costmap
///
/// `nav2_msgs/msg/CostmapMetaData`
final class CostmapMetaData implements RosMessage {
  CostmapMetaData({
    ros2.RosTime? mapLoadTime,
    ros2.RosTime? updateTime,
    this.layer = '',
    this.resolution = 0,
    this.sizeX = 0,
    this.sizeY = 0,
    ros2.Pose? origin,
  })  : mapLoadTime = mapLoadTime ?? ros2.RosTime(),
        updateTime = updateTime ?? ros2.RosTime(),
        origin = origin ?? ros2.Pose();

  factory CostmapMetaData.fromJson(Map<String, Object?> json) =>
      CostmapMetaData(
        mapLoadTime:
            Field.asMessage(json['map_load_time'], ros2.RosTime.fromJson),
        updateTime: Field.asMessage(json['update_time'], ros2.RosTime.fromJson),
        layer: Field.stringAt(json, 'layer'),
        resolution: Field.doubleAt(json, 'resolution'),
        sizeX: Field.intAt(json, 'size_x'),
        sizeY: Field.intAt(json, 'size_y'),
        origin: Field.asMessage(json['origin'], ros2.Pose.fromJson),
      );

  final ros2.RosTime mapLoadTime;
  final ros2.RosTime updateTime;
  final String layer;
  final double resolution;
  final int sizeX;
  final int sizeY;
  final ros2.Pose origin;

  @override
  String get rosType => 'nav2_msgs/msg/CostmapMetaData';

  @override
  Map<String, Object?> toJson() => {
        'map_load_time': mapLoadTime.toJson(),
        'update_time': updateTime.toJson(),
        'layer': layer,
        'resolution': resolution,
        'size_x': sizeX,
        'size_y': sizeY,
        'origin': origin.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CostmapMetaData &&
          other.mapLoadTime == mapLoadTime &&
          other.updateTime == updateTime &&
          other.layer == layer &&
          other.resolution == resolution &&
          other.sizeX == sizeX &&
          other.sizeY == sizeY &&
          other.origin == origin);

  @override
  int get hashCode => Object.hashAll([
        mapLoadTime,
        updateTime,
        layer,
        resolution,
        sizeX,
        sizeY,
        origin,
      ]);

  @override
  String toString() => 'CostmapMetaData(${toJson()})';
}

/// Update msg for Costmap containing the modified part of Costmap
///
/// `nav2_msgs/msg/CostmapUpdate`
final class CostmapUpdate implements RosMessage {
  CostmapUpdate({
    ros2.Header? header,
    this.x = 0,
    this.y = 0,
    this.sizeX = 0,
    this.sizeY = 0,
    Uint8List? data,
  })  : header = header ?? ros2.Header(),
        data = data ?? Uint8List(0);

  factory CostmapUpdate.fromJson(Map<String, Object?> json) => CostmapUpdate(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        x: Field.intAt(json, 'x'),
        y: Field.intAt(json, 'y'),
        sizeX: Field.intAt(json, 'size_x'),
        sizeY: Field.intAt(json, 'size_y'),
        data: Field.asBytes(json['data']),
      );

  final ros2.Header header;
  final int x;
  final int y;
  final int sizeX;
  final int sizeY;
  final Uint8List data;

  @override
  String get rosType => 'nav2_msgs/msg/CostmapUpdate';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'x': x,
        'y': y,
        'size_x': sizeX,
        'size_y': sizeY,
        'data': Field.encodeBytes(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CostmapUpdate &&
          other.header == header &&
          other.x == x &&
          other.y == y &&
          other.sizeX == sizeX &&
          other.sizeY == sizeY &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        header,
        x,
        y,
        sizeX,
        sizeY,
        ...data,
      ]);

  @override
  String toString() => 'CostmapUpdate(${toJson()})';
}

/// Edge cost to use with nav2_msgs/srv/DynamicEdges to adjust route edge costs
///
/// `nav2_msgs/msg/EdgeCost`
final class EdgeCost implements RosMessage {
  const EdgeCost({
    this.edgeid = 0,
    this.cost = 0,
  });

  factory EdgeCost.fromJson(Map<String, Object?> json) => EdgeCost(
        edgeid: Field.intAt(json, 'edgeid'),
        cost: Field.doubleAt(json, 'cost'),
      );

  final int edgeid;
  final double cost;

  @override
  String get rosType => 'nav2_msgs/msg/EdgeCost';

  @override
  Map<String, Object?> toJson() => {
        'edgeid': edgeid,
        'cost': cost,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EdgeCost && other.edgeid == edgeid && other.cost == cost);

  @override
  int get hashCode => Object.hashAll([
        edgeid,
        cost,
      ]);

  @override
  String toString() => 'EdgeCost(${toJson()})';
}

/// `nav2_msgs/msg/MissedWaypoint`
final class MissedWaypoint implements RosMessage {
  MissedWaypoint({
    this.index = 0,
    ros2.PoseStamped? goal,
    this.errorCode = 0,
  }) : goal = goal ?? ros2.PoseStamped();

  factory MissedWaypoint.fromJson(Map<String, Object?> json) => MissedWaypoint(
        index: Field.intAt(json, 'index'),
        goal: Field.asMessage(json['goal'], ros2.PoseStamped.fromJson),
        errorCode: Field.intAt(json, 'error_code'),
      );

  final int index;
  final ros2.PoseStamped goal;
  final int errorCode;

  @override
  String get rosType => 'nav2_msgs/msg/MissedWaypoint';

  @override
  Map<String, Object?> toJson() => {
        'index': index,
        'goal': goal.toJson(),
        'error_code': errorCode,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MissedWaypoint &&
          other.index == index &&
          other.goal == goal &&
          other.errorCode == errorCode);

  @override
  int get hashCode => Object.hashAll([
        index,
        goal,
        errorCode,
      ]);

  @override
  String toString() => 'MissedWaypoint(${toJson()})';
}

/// This represents an individual particle with weight produced by a particle filter
///
/// `nav2_msgs/msg/Particle`
final class Particle implements RosMessage {
  Particle({
    ros2.Pose? pose,
    this.weight = 0,
  }) : pose = pose ?? ros2.Pose();

  factory Particle.fromJson(Map<String, Object?> json) => Particle(
        pose: Field.asMessage(json['pose'], ros2.Pose.fromJson),
        weight: Field.doubleAt(json, 'weight'),
      );

  final ros2.Pose pose;
  final double weight;

  @override
  String get rosType => 'nav2_msgs/msg/Particle';

  @override
  Map<String, Object?> toJson() => {
        'pose': pose.toJson(),
        'weight': weight,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Particle && other.pose == pose && other.weight == weight);

  @override
  int get hashCode => Object.hashAll([
        pose,
        weight,
      ]);

  @override
  String toString() => 'Particle(${toJson()})';
}

/// This represents a particle cloud containing particle poses and weights
///
/// `nav2_msgs/msg/ParticleCloud`
final class ParticleCloud implements RosMessage {
  ParticleCloud({
    ros2.Header? header,
    this.particles = const [],
  }) : header = header ?? ros2.Header();

  factory ParticleCloud.fromJson(Map<String, Object?> json) => ParticleCloud(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        particles: Field.asList<Particle>(json['particles'], Particle.fromJson),
      );

  final ros2.Header header;
  final List<Particle> particles;

  @override
  String get rosType => 'nav2_msgs/msg/ParticleCloud';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'particles': particles.map((Particle e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParticleCloud &&
          other.header == header &&
          _listEquals(other.particles, particles));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...particles,
      ]);

  @override
  String toString() => 'ParticleCloud(${toJson()})';
}

/// `nav2_msgs/msg/Route`
final class RosRoute implements RosMessage {
  RosRoute({
    ros2.Header? header,
    this.routeCost = 0,
    this.nodes = const [],
    this.edges = const [],
  }) : header = header ?? ros2.Header();

  factory RosRoute.fromJson(Map<String, Object?> json) => RosRoute(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        routeCost: Field.doubleAt(json, 'route_cost'),
        nodes: Field.asList<RouteNode>(json['nodes'], RouteNode.fromJson),
        edges: Field.asList<RouteEdge>(json['edges'], RouteEdge.fromJson),
      );

  final ros2.Header header;
  final double routeCost;

  /// ordered set of nodes of the route
  final List<RouteNode> nodes;

  /// ordered set of edges that connect nodes
  final List<RouteEdge> edges;

  @override
  String get rosType => 'nav2_msgs/msg/Route';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'route_cost': routeCost,
        'nodes': nodes.map((RouteNode e) => e.toJson()).toList(),
        'edges': edges.map((RouteEdge e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RosRoute &&
          other.header == header &&
          other.routeCost == routeCost &&
          _listEquals(other.nodes, nodes) &&
          _listEquals(other.edges, edges));

  @override
  int get hashCode => Object.hashAll([
        header,
        routeCost,
        ...nodes,
        ...edges,
      ]);

  @override
  String toString() => 'RosRoute(${toJson()})';
}

/// `nav2_msgs/msg/RouteEdge`
final class RouteEdge implements RosMessage {
  RouteEdge({
    this.edgeid = 0,
    ros2.Point? start,
    ros2.Point? end,
  })  : start = start ?? ros2.Point(),
        end = end ?? ros2.Point();

  factory RouteEdge.fromJson(Map<String, Object?> json) => RouteEdge(
        edgeid: Field.intAt(json, 'edgeid'),
        start: Field.asMessage(json['start'], ros2.Point.fromJson),
        end: Field.asMessage(json['end'], ros2.Point.fromJson),
      );

  final int edgeid;
  final ros2.Point start;
  final ros2.Point end;

  @override
  String get rosType => 'nav2_msgs/msg/RouteEdge';

  @override
  Map<String, Object?> toJson() => {
        'edgeid': edgeid,
        'start': start.toJson(),
        'end': end.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteEdge &&
          other.edgeid == edgeid &&
          other.start == start &&
          other.end == end);

  @override
  int get hashCode => Object.hashAll([
        edgeid,
        start,
        end,
      ]);

  @override
  String toString() => 'RouteEdge(${toJson()})';
}

/// `nav2_msgs/msg/RouteNode`
final class RouteNode implements RosMessage {
  RouteNode({
    this.nodeid = 0,
    ros2.Point? position,
  }) : position = position ?? ros2.Point();

  factory RouteNode.fromJson(Map<String, Object?> json) => RouteNode(
        nodeid: Field.intAt(json, 'nodeid'),
        position: Field.asMessage(json['position'], ros2.Point.fromJson),
      );

  final int nodeid;
  final ros2.Point position;

  @override
  String get rosType => 'nav2_msgs/msg/RouteNode';

  @override
  Map<String, Object?> toJson() => {
        'nodeid': nodeid,
        'position': position.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteNode &&
          other.nodeid == nodeid &&
          other.position == position);

  @override
  int get hashCode => Object.hashAll([
        nodeid,
        position,
      ]);

  @override
  String toString() => 'RouteNode(${toJson()})';
}

/// `nav2_msgs/msg/SpeedLimit`
final class SpeedLimit implements RosMessage {
  SpeedLimit({
    ros2.Header? header,
    this.percentage = false,
    this.speedLimit = 0,
  }) : header = header ?? ros2.Header();

  factory SpeedLimit.fromJson(Map<String, Object?> json) => SpeedLimit(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        percentage: Field.boolAt(json, 'percentage'),
        speedLimit: Field.doubleAt(json, 'speed_limit'),
      );

  final ros2.Header header;
  final bool percentage;
  final double speedLimit;

  @override
  String get rosType => 'nav2_msgs/msg/SpeedLimit';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'percentage': percentage,
        'speed_limit': speedLimit,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeedLimit &&
          other.header == header &&
          other.percentage == percentage &&
          other.speedLimit == speedLimit);

  @override
  int get hashCode => Object.hashAll([
        header,
        percentage,
        speedLimit,
      ]);

  @override
  String toString() => 'SpeedLimit(${toJson()})';
}

/// `nav2_msgs/msg/VoxelGrid`
final class VoxelGrid implements RosMessage {
  VoxelGrid({
    ros2.Header? header,
    Uint32List? data,
    Point32? origin,
    ros2.Vector3? resolutions,
    this.sizeX = 0,
    this.sizeY = 0,
    this.sizeZ = 0,
  })  : header = header ?? ros2.Header(),
        data = data ?? Uint32List(0),
        origin = origin ?? Point32(),
        resolutions = resolutions ?? ros2.Vector3();

  factory VoxelGrid.fromJson(Map<String, Object?> json) => VoxelGrid(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        data: Field.asUint32List(json['data']),
        origin: Field.asMessage(json['origin'], Point32.fromJson),
        resolutions:
            Field.asMessage(json['resolutions'], ros2.Vector3.fromJson),
        sizeX: Field.intAt(json, 'size_x'),
        sizeY: Field.intAt(json, 'size_y'),
        sizeZ: Field.intAt(json, 'size_z'),
      );

  final ros2.Header header;
  final Uint32List data;
  final Point32 origin;
  final ros2.Vector3 resolutions;
  final int sizeX;
  final int sizeY;
  final int sizeZ;

  @override
  String get rosType => 'nav2_msgs/msg/VoxelGrid';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'data': Field.encodeNumbers(data),
        'origin': origin.toJson(),
        'resolutions': resolutions.toJson(),
        'size_x': sizeX,
        'size_y': sizeY,
        'size_z': sizeZ,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoxelGrid &&
          other.header == header &&
          _listEquals(other.data, data) &&
          other.origin == origin &&
          other.resolutions == resolutions &&
          other.sizeX == sizeX &&
          other.sizeY == sizeY &&
          other.sizeZ == sizeZ);

  @override
  int get hashCode => Object.hashAll([
        header,
        ...data,
        origin,
        resolutions,
        sizeX,
        sizeY,
        sizeZ,
      ]);

  @override
  String toString() => 'VoxelGrid(${toJson()})';
}

/// Clears the costmap within a distance around a given pose
///
/// `nav2_msgs/msg/ClearCostmapAroundPose_Request`
final class ClearCostmapAroundPoseRequest implements RosMessage {
  ClearCostmapAroundPoseRequest({
    ros2.PoseStamped? pose,
    this.resetDistance = 0,
  }) : pose = pose ?? ros2.PoseStamped();

  factory ClearCostmapAroundPoseRequest.fromJson(Map<String, Object?> json) =>
      ClearCostmapAroundPoseRequest(
        pose: Field.asMessage(json['pose'], ros2.PoseStamped.fromJson),
        resetDistance: Field.doubleAt(json, 'reset_distance'),
      );

  final ros2.PoseStamped pose;
  final double resetDistance;

  @override
  String get rosType => 'nav2_msgs/msg/ClearCostmapAroundPose_Request';

  @override
  Map<String, Object?> toJson() => {
        'pose': pose.toJson(),
        'reset_distance': resetDistance,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClearCostmapAroundPoseRequest &&
          other.pose == pose &&
          other.resetDistance == resetDistance);

  @override
  int get hashCode => Object.hashAll([
        pose,
        resetDistance,
      ]);

  @override
  String toString() => 'ClearCostmapAroundPoseRequest(${toJson()})';
}

/// `nav2_msgs/msg/ClearCostmapAroundPose_Response`
final class ClearCostmapAroundPoseResponse implements RosMessage {
  ClearCostmapAroundPoseResponse({
    ros2.EmptyMsg? response,
  }) : response = response ?? ros2.EmptyMsg();

  factory ClearCostmapAroundPoseResponse.fromJson(Map<String, Object?> json) =>
      ClearCostmapAroundPoseResponse(
        response: Field.asMessage(json['response'], ros2.EmptyMsg.fromJson),
      );

  final ros2.EmptyMsg response;

  @override
  String get rosType => 'nav2_msgs/msg/ClearCostmapAroundPose_Response';

  @override
  Map<String, Object?> toJson() => {
        'response': response.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClearCostmapAroundPoseResponse && other.response == response);

  @override
  int get hashCode => Object.hashAll([
        response,
      ]);

  @override
  String toString() => 'ClearCostmapAroundPoseResponse(${toJson()})';
}

/// Clears the costmap within a distance
///
/// `nav2_msgs/msg/ClearCostmapAroundRobot_Request`
final class ClearCostmapAroundRobotRequest implements RosMessage {
  const ClearCostmapAroundRobotRequest({
    this.resetDistance = 0,
  });

  factory ClearCostmapAroundRobotRequest.fromJson(Map<String, Object?> json) =>
      ClearCostmapAroundRobotRequest(
        resetDistance: Field.doubleAt(json, 'reset_distance'),
      );

  final double resetDistance;

  @override
  String get rosType => 'nav2_msgs/msg/ClearCostmapAroundRobot_Request';

  @override
  Map<String, Object?> toJson() => {
        'reset_distance': resetDistance,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClearCostmapAroundRobotRequest &&
          other.resetDistance == resetDistance);

  @override
  int get hashCode => Object.hashAll([
        resetDistance,
      ]);

  @override
  String toString() => 'ClearCostmapAroundRobotRequest(${toJson()})';
}

/// `nav2_msgs/msg/ClearCostmapAroundRobot_Response`
final class ClearCostmapAroundRobotResponse implements RosMessage {
  ClearCostmapAroundRobotResponse({
    ros2.EmptyMsg? response,
  }) : response = response ?? ros2.EmptyMsg();

  factory ClearCostmapAroundRobotResponse.fromJson(Map<String, Object?> json) =>
      ClearCostmapAroundRobotResponse(
        response: Field.asMessage(json['response'], ros2.EmptyMsg.fromJson),
      );

  final ros2.EmptyMsg response;

  @override
  String get rosType => 'nav2_msgs/msg/ClearCostmapAroundRobot_Response';

  @override
  Map<String, Object?> toJson() => {
        'response': response.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClearCostmapAroundRobotResponse && other.response == response);

  @override
  int get hashCode => Object.hashAll([
        response,
      ]);

  @override
  String toString() => 'ClearCostmapAroundRobotResponse(${toJson()})';
}

/// Clears the costmap except a rectangular region specified by reset_distance
///
/// `nav2_msgs/msg/ClearCostmapExceptRegion_Request`
final class ClearCostmapExceptRegionRequest implements RosMessage {
  const ClearCostmapExceptRegionRequest({
    this.resetDistance = 0,
  });

  factory ClearCostmapExceptRegionRequest.fromJson(Map<String, Object?> json) =>
      ClearCostmapExceptRegionRequest(
        resetDistance: Field.doubleAt(json, 'reset_distance'),
      );

  final double resetDistance;

  @override
  String get rosType => 'nav2_msgs/msg/ClearCostmapExceptRegion_Request';

  @override
  Map<String, Object?> toJson() => {
        'reset_distance': resetDistance,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClearCostmapExceptRegionRequest &&
          other.resetDistance == resetDistance);

  @override
  int get hashCode => Object.hashAll([
        resetDistance,
      ]);

  @override
  String toString() => 'ClearCostmapExceptRegionRequest(${toJson()})';
}

/// `nav2_msgs/msg/ClearCostmapExceptRegion_Response`
final class ClearCostmapExceptRegionResponse implements RosMessage {
  ClearCostmapExceptRegionResponse({
    ros2.EmptyMsg? response,
  }) : response = response ?? ros2.EmptyMsg();

  factory ClearCostmapExceptRegionResponse.fromJson(
          Map<String, Object?> json) =>
      ClearCostmapExceptRegionResponse(
        response: Field.asMessage(json['response'], ros2.EmptyMsg.fromJson),
      );

  final ros2.EmptyMsg response;

  @override
  String get rosType => 'nav2_msgs/msg/ClearCostmapExceptRegion_Response';

  @override
  Map<String, Object?> toJson() => {
        'response': response.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClearCostmapExceptRegionResponse && other.response == response);

  @override
  int get hashCode => Object.hashAll([
        response,
      ]);

  @override
  String toString() => 'ClearCostmapExceptRegionResponse(${toJson()})';
}

/// Clears all layers on the costmap
///
/// `nav2_msgs/msg/ClearEntireCostmap_Request`
final class ClearEntireCostmapRequest implements RosMessage {
  ClearEntireCostmapRequest({
    ros2.EmptyMsg? request,
  }) : request = request ?? ros2.EmptyMsg();

  factory ClearEntireCostmapRequest.fromJson(Map<String, Object?> json) =>
      ClearEntireCostmapRequest(
        request: Field.asMessage(json['request'], ros2.EmptyMsg.fromJson),
      );

  final ros2.EmptyMsg request;

  @override
  String get rosType => 'nav2_msgs/msg/ClearEntireCostmap_Request';

  @override
  Map<String, Object?> toJson() => {
        'request': request.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClearEntireCostmapRequest && other.request == request);

  @override
  int get hashCode => Object.hashAll([
        request,
      ]);

  @override
  String toString() => 'ClearEntireCostmapRequest(${toJson()})';
}

/// `nav2_msgs/msg/ClearEntireCostmap_Response`
final class ClearEntireCostmapResponse implements RosMessage {
  ClearEntireCostmapResponse({
    ros2.EmptyMsg? response,
  }) : response = response ?? ros2.EmptyMsg();

  factory ClearEntireCostmapResponse.fromJson(Map<String, Object?> json) =>
      ClearEntireCostmapResponse(
        response: Field.asMessage(json['response'], ros2.EmptyMsg.fromJson),
      );

  final ros2.EmptyMsg response;

  @override
  String get rosType => 'nav2_msgs/msg/ClearEntireCostmap_Response';

  @override
  Map<String, Object?> toJson() => {
        'response': response.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClearEntireCostmapResponse && other.response == response);

  @override
  int get hashCode => Object.hashAll([
        response,
      ]);

  @override
  String toString() => 'ClearEntireCostmapResponse(${toJson()})';
}

/// `nav2_msgs/msg/DynamicEdges_Request`
final class DynamicEdgesRequest implements RosMessage {
  DynamicEdgesRequest({
    Uint16List? closedEdges,
    Uint16List? openedEdges,
    this.adjustEdges = const [],
  })  : closedEdges = closedEdges ?? Uint16List(0),
        openedEdges = openedEdges ?? Uint16List(0);

  factory DynamicEdgesRequest.fromJson(Map<String, Object?> json) =>
      DynamicEdgesRequest(
        closedEdges: Field.asUint16List(json['closed_edges']),
        openedEdges: Field.asUint16List(json['opened_edges']),
        adjustEdges:
            Field.asList<EdgeCost>(json['adjust_edges'], EdgeCost.fromJson),
      );

  final Uint16List closedEdges;
  final Uint16List openedEdges;
  final List<EdgeCost> adjustEdges;

  @override
  String get rosType => 'nav2_msgs/msg/DynamicEdges_Request';

  @override
  Map<String, Object?> toJson() => {
        'closed_edges': Field.encodeNumbers(closedEdges),
        'opened_edges': Field.encodeNumbers(openedEdges),
        'adjust_edges': adjustEdges.map((EdgeCost e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DynamicEdgesRequest &&
          _listEquals(other.closedEdges, closedEdges) &&
          _listEquals(other.openedEdges, openedEdges) &&
          _listEquals(other.adjustEdges, adjustEdges));

  @override
  int get hashCode => Object.hashAll([
        ...closedEdges,
        ...openedEdges,
        ...adjustEdges,
      ]);

  @override
  String toString() => 'DynamicEdgesRequest(${toJson()})';
}

/// `nav2_msgs/msg/DynamicEdges_Response`
final class DynamicEdgesResponse implements RosMessage {
  const DynamicEdgesResponse({
    this.success = false,
  });

  factory DynamicEdgesResponse.fromJson(Map<String, Object?> json) =>
      DynamicEdgesResponse(
        success: Field.boolAt(json, 'success'),
      );

  final bool success;

  @override
  String get rosType => 'nav2_msgs/msg/DynamicEdges_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DynamicEdgesResponse && other.success == success);

  @override
  int get hashCode => Object.hashAll([
        success,
      ]);

  @override
  String toString() => 'DynamicEdgesResponse(${toJson()})';
}

/// Get costmap cost at given point
///
/// `nav2_msgs/msg/GetCost_Request`
final class GetCostRequest implements RosMessage {
  const GetCostRequest({
    this.useFootprint = false,
    this.x = 0,
    this.y = 0,
    this.theta = 0,
  });

  factory GetCostRequest.fromJson(Map<String, Object?> json) => GetCostRequest(
        useFootprint: Field.boolAt(json, 'use_footprint'),
        x: Field.doubleAt(json, 'x'),
        y: Field.doubleAt(json, 'y'),
        theta: Field.doubleAt(json, 'theta'),
      );

  final bool useFootprint;
  final double x;
  final double y;
  final double theta;

  @override
  String get rosType => 'nav2_msgs/msg/GetCost_Request';

  @override
  Map<String, Object?> toJson() => {
        'use_footprint': useFootprint,
        'x': x,
        'y': y,
        'theta': theta,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetCostRequest &&
          other.useFootprint == useFootprint &&
          other.x == x &&
          other.y == y &&
          other.theta == theta);

  @override
  int get hashCode => Object.hashAll([
        useFootprint,
        x,
        y,
        theta,
      ]);

  @override
  String toString() => 'GetCostRequest(${toJson()})';
}

/// `nav2_msgs/msg/GetCost_Response`
final class GetCostResponse implements RosMessage {
  const GetCostResponse({
    this.cost = 0,
  });

  factory GetCostResponse.fromJson(Map<String, Object?> json) =>
      GetCostResponse(
        cost: Field.doubleAt(json, 'cost'),
      );

  final double cost;

  @override
  String get rosType => 'nav2_msgs/msg/GetCost_Response';

  @override
  Map<String, Object?> toJson() => {
        'cost': cost,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetCostResponse && other.cost == cost);

  @override
  int get hashCode => Object.hashAll([
        cost,
      ]);

  @override
  String toString() => 'GetCostResponse(${toJson()})';
}

/// Get the costmap
///
/// `nav2_msgs/msg/GetCostmap_Request`
final class GetCostmapRequest implements RosMessage {
  GetCostmapRequest({
    CostmapMetaData? specs,
  }) : specs = specs ?? CostmapMetaData();

  factory GetCostmapRequest.fromJson(Map<String, Object?> json) =>
      GetCostmapRequest(
        specs: Field.asMessage(json['specs'], CostmapMetaData.fromJson),
      );

  final CostmapMetaData specs;

  @override
  String get rosType => 'nav2_msgs/msg/GetCostmap_Request';

  @override
  Map<String, Object?> toJson() => {
        'specs': specs.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetCostmapRequest && other.specs == specs);

  @override
  int get hashCode => Object.hashAll([
        specs,
      ]);

  @override
  String toString() => 'GetCostmapRequest(${toJson()})';
}

/// `nav2_msgs/msg/GetCostmap_Response`
final class GetCostmapResponse implements RosMessage {
  GetCostmapResponse({
    Costmap? map,
  }) : map = map ?? Costmap();

  factory GetCostmapResponse.fromJson(Map<String, Object?> json) =>
      GetCostmapResponse(
        map: Field.asMessage(json['map'], Costmap.fromJson),
      );

  final Costmap map;

  @override
  String get rosType => 'nav2_msgs/msg/GetCostmap_Response';

  @override
  Map<String, Object?> toJson() => {
        'map': map.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetCostmapResponse && other.map == map);

  @override
  int get hashCode => Object.hashAll([
        map,
      ]);

  @override
  String toString() => 'GetCostmapResponse(${toJson()})';
}

/// Determine if the current path is still valid
///
/// `nav2_msgs/msg/IsPathValid_Request`
final class IsPathValidRequest implements RosMessage {
  IsPathValidRequest({
    ros2.RosPath? path,
  }) : path = path ?? ros2.RosPath();

  factory IsPathValidRequest.fromJson(Map<String, Object?> json) =>
      IsPathValidRequest(
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
      );

  final ros2.RosPath path;

  @override
  String get rosType => 'nav2_msgs/msg/IsPathValid_Request';

  @override
  Map<String, Object?> toJson() => {
        'path': path.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IsPathValidRequest && other.path == path);

  @override
  int get hashCode => Object.hashAll([
        path,
      ]);

  @override
  String toString() => 'IsPathValidRequest(${toJson()})';
}

/// `nav2_msgs/msg/IsPathValid_Response`
final class IsPathValidResponse implements RosMessage {
  IsPathValidResponse({
    this.isValid = false,
    Int32List? invalidPoseIndices,
  }) : invalidPoseIndices = invalidPoseIndices ?? Int32List(0);

  factory IsPathValidResponse.fromJson(Map<String, Object?> json) =>
      IsPathValidResponse(
        isValid: Field.boolAt(json, 'is_valid'),
        invalidPoseIndices: Field.asInt32List(json['invalid_pose_indices']),
      );

  final bool isValid;
  final Int32List invalidPoseIndices;

  @override
  String get rosType => 'nav2_msgs/msg/IsPathValid_Response';

  @override
  Map<String, Object?> toJson() => {
        'is_valid': isValid,
        'invalid_pose_indices': Field.encodeNumbers(invalidPoseIndices),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IsPathValidResponse &&
          other.isValid == isValid &&
          _listEquals(other.invalidPoseIndices, invalidPoseIndices));

  @override
  int get hashCode => Object.hashAll([
        isValid,
        ...invalidPoseIndices,
      ]);

  @override
  String toString() => 'IsPathValidResponse(${toJson()})';
}

/// URL of map resource
/// Can be an absolute path to a file: file:///path/to/maps/floor1.yaml
/// Or, relative to a ROS package: package://my_ros_package/maps/floor2.yaml
///
/// `nav2_msgs/msg/LoadMap_Request`
final class LoadMapRequest implements RosMessage {
  const LoadMapRequest({
    this.mapUrl = '',
  });

  factory LoadMapRequest.fromJson(Map<String, Object?> json) => LoadMapRequest(
        mapUrl: Field.stringAt(json, 'map_url'),
      );

  final String mapUrl;

  @override
  String get rosType => 'nav2_msgs/msg/LoadMap_Request';

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

/// Result code defintions
///
/// `nav2_msgs/msg/LoadMap_Response`
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
  String get rosType => 'nav2_msgs/msg/LoadMap_Response';

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

/// `nav2_msgs/msg/ManageLifecycleNodes_Request`
final class ManageLifecycleNodesRequest implements RosMessage {
  const ManageLifecycleNodesRequest({
    this.command = 0,
  });

  factory ManageLifecycleNodesRequest.fromJson(Map<String, Object?> json) =>
      ManageLifecycleNodesRequest(
        command: Field.intAt(json, 'command'),
      );

  static const int startup = 0;
  static const int pause = 1;
  static const int resume = 2;
  static const int reset = 3;
  static const int shutdown = 4;
  static const int configure = 5;
  static const int cleanup = 6;

  final int command;

  @override
  String get rosType => 'nav2_msgs/msg/ManageLifecycleNodes_Request';

  @override
  Map<String, Object?> toJson() => {
        'command': command,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManageLifecycleNodesRequest && other.command == command);

  @override
  int get hashCode => Object.hashAll([
        command,
      ]);

  @override
  String toString() => 'ManageLifecycleNodesRequest(${toJson()})';
}

/// `nav2_msgs/msg/ManageLifecycleNodes_Response`
final class ManageLifecycleNodesResponse implements RosMessage {
  const ManageLifecycleNodesResponse({
    this.success = false,
  });

  factory ManageLifecycleNodesResponse.fromJson(Map<String, Object?> json) =>
      ManageLifecycleNodesResponse(
        success: Field.boolAt(json, 'success'),
      );

  final bool success;

  @override
  String get rosType => 'nav2_msgs/msg/ManageLifecycleNodes_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManageLifecycleNodesResponse && other.success == success);

  @override
  int get hashCode => Object.hashAll([
        success,
      ]);

  @override
  String toString() => 'ManageLifecycleNodesResponse(${toJson()})';
}

/// Reloads the dock's database with a new filepath
///
/// `nav2_msgs/msg/ReloadDockDatabase_Request`
final class ReloadDockDatabaseRequest implements RosMessage {
  const ReloadDockDatabaseRequest({
    this.filepath = '',
  });

  factory ReloadDockDatabaseRequest.fromJson(Map<String, Object?> json) =>
      ReloadDockDatabaseRequest(
        filepath: Field.stringAt(json, 'filepath'),
      );

  final String filepath;

  @override
  String get rosType => 'nav2_msgs/msg/ReloadDockDatabase_Request';

  @override
  Map<String, Object?> toJson() => {
        'filepath': filepath,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReloadDockDatabaseRequest && other.filepath == filepath);

  @override
  int get hashCode => Object.hashAll([
        filepath,
      ]);

  @override
  String toString() => 'ReloadDockDatabaseRequest(${toJson()})';
}

/// `nav2_msgs/msg/ReloadDockDatabase_Response`
final class ReloadDockDatabaseResponse implements RosMessage {
  const ReloadDockDatabaseResponse({
    this.success = false,
  });

  factory ReloadDockDatabaseResponse.fromJson(Map<String, Object?> json) =>
      ReloadDockDatabaseResponse(
        success: Field.boolAt(json, 'success'),
      );

  final bool success;

  @override
  String get rosType => 'nav2_msgs/msg/ReloadDockDatabase_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReloadDockDatabaseResponse && other.success == success);

  @override
  int get hashCode => Object.hashAll([
        success,
      ]);

  @override
  String toString() => 'ReloadDockDatabaseResponse(${toJson()})';
}

/// URL of map resource
/// Can be an absolute path to a file: file:///path/to/maps/floor1.yaml
/// Or, relative to a ROS package: package://my_ros_package/maps/floor2.yaml
///
/// `nav2_msgs/msg/SaveMap_Request`
final class SaveMapRequest implements RosMessage {
  const SaveMapRequest({
    this.mapTopic = '',
    this.mapUrl = '',
    this.imageFormat = '',
    this.mapMode = '',
    this.freeThresh = 0,
    this.occupiedThresh = 0,
  });

  factory SaveMapRequest.fromJson(Map<String, Object?> json) => SaveMapRequest(
        mapTopic: Field.stringAt(json, 'map_topic'),
        mapUrl: Field.stringAt(json, 'map_url'),
        imageFormat: Field.stringAt(json, 'image_format'),
        mapMode: Field.stringAt(json, 'map_mode'),
        freeThresh: Field.doubleAt(json, 'free_thresh'),
        occupiedThresh: Field.doubleAt(json, 'occupied_thresh'),
      );

  final String mapTopic;
  final String mapUrl;
  final String imageFormat;
  final String mapMode;
  final double freeThresh;
  final double occupiedThresh;

  @override
  String get rosType => 'nav2_msgs/msg/SaveMap_Request';

  @override
  Map<String, Object?> toJson() => {
        'map_topic': mapTopic,
        'map_url': mapUrl,
        'image_format': imageFormat,
        'map_mode': mapMode,
        'free_thresh': freeThresh,
        'occupied_thresh': occupiedThresh,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveMapRequest &&
          other.mapTopic == mapTopic &&
          other.mapUrl == mapUrl &&
          other.imageFormat == imageFormat &&
          other.mapMode == mapMode &&
          other.freeThresh == freeThresh &&
          other.occupiedThresh == occupiedThresh);

  @override
  int get hashCode => Object.hashAll([
        mapTopic,
        mapUrl,
        imageFormat,
        mapMode,
        freeThresh,
        occupiedThresh,
      ]);

  @override
  String toString() => 'SaveMapRequest(${toJson()})';
}

/// `nav2_msgs/msg/SaveMap_Response`
final class SaveMapResponse implements RosMessage {
  const SaveMapResponse({
    this.result = false,
  });

  factory SaveMapResponse.fromJson(Map<String, Object?> json) =>
      SaveMapResponse(
        result: Field.boolAt(json, 'result'),
      );

  final bool result;

  @override
  String get rosType => 'nav2_msgs/msg/SaveMap_Response';

  @override
  Map<String, Object?> toJson() => {
        'result': result,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveMapResponse && other.result == result);

  @override
  int get hashCode => Object.hashAll([
        result,
      ]);

  @override
  String toString() => 'SaveMapResponse(${toJson()})';
}

/// `nav2_msgs/msg/SetInitialPose_Request`
final class SetInitialPoseRequest implements RosMessage {
  SetInitialPoseRequest({
    PoseWithCovarianceStamped? pose,
  }) : pose = pose ?? PoseWithCovarianceStamped();

  factory SetInitialPoseRequest.fromJson(Map<String, Object?> json) =>
      SetInitialPoseRequest(
        pose: Field.asMessage(json['pose'], PoseWithCovarianceStamped.fromJson),
      );

  final PoseWithCovarianceStamped pose;

  @override
  String get rosType => 'nav2_msgs/msg/SetInitialPose_Request';

  @override
  Map<String, Object?> toJson() => {
        'pose': pose.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetInitialPoseRequest && other.pose == pose);

  @override
  int get hashCode => Object.hashAll([
        pose,
      ]);

  @override
  String toString() => 'SetInitialPoseRequest(${toJson()})';
}

/// `nav2_msgs/msg/SetInitialPose_Response`
final class SetInitialPoseResponse implements RosMessage {
  const SetInitialPoseResponse();

  factory SetInitialPoseResponse.fromJson(Map<String, Object?> json) =>
      SetInitialPoseResponse();

  @override
  String get rosType => 'nav2_msgs/msg/SetInitialPose_Response';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SetInitialPoseResponse;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'SetInitialPoseResponse(${toJson()})';
}

/// `nav2_msgs/msg/SetRouteGraph_Request`
final class SetRouteGraphRequest implements RosMessage {
  const SetRouteGraphRequest({
    this.graphFilepath = '',
  });

  factory SetRouteGraphRequest.fromJson(Map<String, Object?> json) =>
      SetRouteGraphRequest(
        graphFilepath: Field.stringAt(json, 'graph_filepath'),
      );

  final String graphFilepath;

  @override
  String get rosType => 'nav2_msgs/msg/SetRouteGraph_Request';

  @override
  Map<String, Object?> toJson() => {
        'graph_filepath': graphFilepath,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetRouteGraphRequest && other.graphFilepath == graphFilepath);

  @override
  int get hashCode => Object.hashAll([
        graphFilepath,
      ]);

  @override
  String toString() => 'SetRouteGraphRequest(${toJson()})';
}

/// `nav2_msgs/msg/SetRouteGraph_Response`
final class SetRouteGraphResponse implements RosMessage {
  const SetRouteGraphResponse({
    this.success = false,
  });

  factory SetRouteGraphResponse.fromJson(Map<String, Object?> json) =>
      SetRouteGraphResponse(
        success: Field.boolAt(json, 'success'),
      );

  final bool success;

  @override
  String get rosType => 'nav2_msgs/msg/SetRouteGraph_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetRouteGraphResponse && other.success == success);

  @override
  int get hashCode => Object.hashAll([
        success,
      ]);

  @override
  String toString() => 'SetRouteGraphResponse(${toJson()})';
}

/// `nav2_msgs/msg/Toggle_Request`
final class ToggleRequest implements RosMessage {
  const ToggleRequest({
    this.enable = false,
  });

  factory ToggleRequest.fromJson(Map<String, Object?> json) => ToggleRequest(
        enable: Field.boolAt(json, 'enable'),
      );

  final bool enable;

  @override
  String get rosType => 'nav2_msgs/msg/Toggle_Request';

  @override
  Map<String, Object?> toJson() => {
        'enable': enable,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ToggleRequest && other.enable == enable);

  @override
  int get hashCode => Object.hashAll([
        enable,
      ]);

  @override
  String toString() => 'ToggleRequest(${toJson()})';
}

/// `nav2_msgs/msg/Toggle_Response`
final class ToggleResponse implements RosMessage {
  const ToggleResponse({
    this.success = false,
    this.message = '',
  });

  factory ToggleResponse.fromJson(Map<String, Object?> json) => ToggleResponse(
        success: Field.boolAt(json, 'success'),
        message: Field.stringAt(json, 'message'),
      );

  final bool success;
  final String message;

  @override
  String get rosType => 'nav2_msgs/msg/Toggle_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
        'message': message,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ToggleResponse &&
          other.success == success &&
          other.message == message);

  @override
  int get hashCode => Object.hashAll([
        success,
        message,
      ]);

  @override
  String toString() => 'ToggleResponse(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/AssistedTeleop_Goal`
final class AssistedTeleopGoal implements RosMessage {
  AssistedTeleopGoal({
    ros2.RosDuration? timeAllowance,
  }) : timeAllowance = timeAllowance ?? ros2.RosDuration();

  factory AssistedTeleopGoal.fromJson(Map<String, Object?> json) =>
      AssistedTeleopGoal(
        timeAllowance:
            Field.asMessage(json['time_allowance'], ros2.RosDuration.fromJson),
      );

  final ros2.RosDuration timeAllowance;

  @override
  String get rosType => 'nav2_msgs/msg/AssistedTeleop_Goal';

  @override
  Map<String, Object?> toJson() => {
        'time_allowance': timeAllowance.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssistedTeleopGoal && other.timeAllowance == timeAllowance);

  @override
  int get hashCode => Object.hashAll([
        timeAllowance,
      ]);

  @override
  String toString() => 'AssistedTeleopGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/AssistedTeleop_Result`
final class AssistedTeleopResult implements RosMessage {
  AssistedTeleopResult({
    ros2.RosDuration? totalElapsedTime,
    this.errorCode = 0,
    this.errorMsg = '',
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory AssistedTeleopResult.fromJson(Map<String, Object?> json) =>
      AssistedTeleopResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int unknown = 730;
  static const int timeout = 731;
  static const int tfError = 732;

  final ros2.RosDuration totalElapsedTime;
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/AssistedTeleop_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssistedTeleopResult &&
          other.totalElapsedTime == totalElapsedTime &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'AssistedTeleopResult(${toJson()})';
}

/// feedback
///
/// `nav2_msgs/msg/AssistedTeleop_Feedback`
final class AssistedTeleopFeedback implements RosMessage {
  AssistedTeleopFeedback({
    ros2.RosDuration? currentTeleopDuration,
  }) : currentTeleopDuration = currentTeleopDuration ?? ros2.RosDuration();

  factory AssistedTeleopFeedback.fromJson(Map<String, Object?> json) =>
      AssistedTeleopFeedback(
        currentTeleopDuration: Field.asMessage(
            json['current_teleop_duration'], ros2.RosDuration.fromJson),
      );

  final ros2.RosDuration currentTeleopDuration;

  @override
  String get rosType => 'nav2_msgs/msg/AssistedTeleop_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'current_teleop_duration': currentTeleopDuration.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssistedTeleopFeedback &&
          other.currentTeleopDuration == currentTeleopDuration);

  @override
  int get hashCode => Object.hashAll([
        currentTeleopDuration,
      ]);

  @override
  String toString() => 'AssistedTeleopFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/BackUp_Goal`
final class BackUpGoal implements RosMessage {
  BackUpGoal({
    ros2.Point? target,
    this.speed = 0,
    ros2.RosDuration? timeAllowance,
  })  : target = target ?? ros2.Point(),
        timeAllowance = timeAllowance ?? ros2.RosDuration();

  factory BackUpGoal.fromJson(Map<String, Object?> json) => BackUpGoal(
        target: Field.asMessage(json['target'], ros2.Point.fromJson),
        speed: Field.doubleAt(json, 'speed'),
        timeAllowance:
            Field.asMessage(json['time_allowance'], ros2.RosDuration.fromJson),
      );

  final ros2.Point target;
  final double speed;
  final ros2.RosDuration timeAllowance;

  @override
  String get rosType => 'nav2_msgs/msg/BackUp_Goal';

  @override
  Map<String, Object?> toJson() => {
        'target': target.toJson(),
        'speed': speed,
        'time_allowance': timeAllowance.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackUpGoal &&
          other.target == target &&
          other.speed == speed &&
          other.timeAllowance == timeAllowance);

  @override
  int get hashCode => Object.hashAll([
        target,
        speed,
        timeAllowance,
      ]);

  @override
  String toString() => 'BackUpGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/BackUp_Result`
final class BackUpResult implements RosMessage {
  BackUpResult({
    ros2.RosDuration? totalElapsedTime,
    this.errorCode = 0,
    this.errorMsg = '',
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory BackUpResult.fromJson(Map<String, Object?> json) => BackUpResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int unknown = 710;
  static const int timeout = 711;
  static const int tfError = 712;
  static const int invalidInput = 713;
  static const int collisionAhead = 714;

  final ros2.RosDuration totalElapsedTime;
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/BackUp_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackUpResult &&
          other.totalElapsedTime == totalElapsedTime &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'BackUpResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/BackUp_Feedback`
final class BackUpFeedback implements RosMessage {
  const BackUpFeedback({
    this.distanceTraveled = 0,
  });

  factory BackUpFeedback.fromJson(Map<String, Object?> json) => BackUpFeedback(
        distanceTraveled: Field.doubleAt(json, 'distance_traveled'),
      );

  final double distanceTraveled;

  @override
  String get rosType => 'nav2_msgs/msg/BackUp_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'distance_traveled': distanceTraveled,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackUpFeedback && other.distanceTraveled == distanceTraveled);

  @override
  int get hashCode => Object.hashAll([
        distanceTraveled,
      ]);

  @override
  String toString() => 'BackUpFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/ComputeAndTrackRoute_Goal`
final class ComputeAndTrackRouteGoal implements RosMessage {
  ComputeAndTrackRouteGoal({
    this.startId = 0,
    ros2.PoseStamped? start,
    this.goalId = 0,
    ros2.PoseStamped? goal,
    this.useStart = false,
    this.usePoses = false,
  })  : start = start ?? ros2.PoseStamped(),
        goal = goal ?? ros2.PoseStamped();

  factory ComputeAndTrackRouteGoal.fromJson(Map<String, Object?> json) =>
      ComputeAndTrackRouteGoal(
        startId: Field.intAt(json, 'start_id'),
        start: Field.asMessage(json['start'], ros2.PoseStamped.fromJson),
        goalId: Field.intAt(json, 'goal_id'),
        goal: Field.asMessage(json['goal'], ros2.PoseStamped.fromJson),
        useStart: Field.boolAt(json, 'use_start'),
        usePoses: Field.boolAt(json, 'use_poses'),
      );

  final int startId;
  final ros2.PoseStamped start;
  final int goalId;
  final ros2.PoseStamped goal;

  /// Whether to use the start field or find the start pose in TF
  final bool useStart;

  /// Whether to use the poses or the IDs fields for request
  final bool usePoses;

  @override
  String get rosType => 'nav2_msgs/msg/ComputeAndTrackRoute_Goal';

  @override
  Map<String, Object?> toJson() => {
        'start_id': startId,
        'start': start.toJson(),
        'goal_id': goalId,
        'goal': goal.toJson(),
        'use_start': useStart,
        'use_poses': usePoses,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputeAndTrackRouteGoal &&
          other.startId == startId &&
          other.start == start &&
          other.goalId == goalId &&
          other.goal == goal &&
          other.useStart == useStart &&
          other.usePoses == usePoses);

  @override
  int get hashCode => Object.hashAll([
        startId,
        start,
        goalId,
        goal,
        useStart,
        usePoses,
      ]);

  @override
  String toString() => 'ComputeAndTrackRouteGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/ComputeAndTrackRoute_Result`
final class ComputeAndTrackRouteResult implements RosMessage {
  ComputeAndTrackRouteResult({
    ros2.RosDuration? executionDuration,
    this.errorCode = 0,
  }) : executionDuration = executionDuration ?? ros2.RosDuration();

  factory ComputeAndTrackRouteResult.fromJson(Map<String, Object?> json) =>
      ComputeAndTrackRouteResult(
        executionDuration: Field.asMessage(
            json['execution_duration'], ros2.RosDuration.fromJson),
        errorCode: Field.intAt(json, 'error_code', 0),
      );

  static const int none = 0;
  static const int unknown = 400;
  static const int tfError = 401;
  static const int noValidGraph = 402;
  static const int indeterminantNodesOnGraph = 403;
  static const int timeout = 404;
  static const int noValidRoute = 405;
  static const int operationFailed = 406;
  static const int invalidEdgeScorerUse = 407;

  final ros2.RosDuration executionDuration;
  final int errorCode;

  @override
  String get rosType => 'nav2_msgs/msg/ComputeAndTrackRoute_Result';

  @override
  Map<String, Object?> toJson() => {
        'execution_duration': executionDuration.toJson(),
        'error_code': errorCode,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputeAndTrackRouteResult &&
          other.executionDuration == executionDuration &&
          other.errorCode == errorCode);

  @override
  int get hashCode => Object.hashAll([
        executionDuration,
        errorCode,
      ]);

  @override
  String toString() => 'ComputeAndTrackRouteResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/ComputeAndTrackRoute_Feedback`
final class ComputeAndTrackRouteFeedback implements RosMessage {
  ComputeAndTrackRouteFeedback({
    this.lastNodeId = 0,
    this.nextNodeId = 0,
    this.currentEdgeId = 0,
    RosRoute? route,
    ros2.RosPath? path,
    this.operationsTriggered = const [],
    this.rerouted = false,
  })  : route = route ?? RosRoute(),
        path = path ?? ros2.RosPath();

  factory ComputeAndTrackRouteFeedback.fromJson(Map<String, Object?> json) =>
      ComputeAndTrackRouteFeedback(
        lastNodeId: Field.intAt(json, 'last_node_id'),
        nextNodeId: Field.intAt(json, 'next_node_id'),
        currentEdgeId: Field.intAt(json, 'current_edge_id'),
        route: Field.asMessage(json['route'], RosRoute.fromJson),
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        operationsTriggered: Field.asStringList(json['operations_triggered']),
        rerouted: Field.boolAt(json, 'rerouted'),
      );

  final int lastNodeId;
  final int nextNodeId;
  final int currentEdgeId;
  final RosRoute route;
  final ros2.RosPath path;
  final List<String> operationsTriggered;
  final bool rerouted;

  @override
  String get rosType => 'nav2_msgs/msg/ComputeAndTrackRoute_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'last_node_id': lastNodeId,
        'next_node_id': nextNodeId,
        'current_edge_id': currentEdgeId,
        'route': route.toJson(),
        'path': path.toJson(),
        'operations_triggered': operationsTriggered,
        'rerouted': rerouted,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputeAndTrackRouteFeedback &&
          other.lastNodeId == lastNodeId &&
          other.nextNodeId == nextNodeId &&
          other.currentEdgeId == currentEdgeId &&
          other.route == route &&
          other.path == path &&
          _listEquals(other.operationsTriggered, operationsTriggered) &&
          other.rerouted == rerouted);

  @override
  int get hashCode => Object.hashAll([
        lastNodeId,
        nextNodeId,
        currentEdgeId,
        route,
        path,
        ...operationsTriggered,
        rerouted,
      ]);

  @override
  String toString() => 'ComputeAndTrackRouteFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/ComputePathThroughPoses_Goal`
final class ComputePathThroughPosesGoal implements RosMessage {
  ComputePathThroughPosesGoal({
    this.goals = const [],
    ros2.PoseStamped? start,
    this.plannerId = '',
    this.useStart = false,
  }) : start = start ?? ros2.PoseStamped();

  factory ComputePathThroughPosesGoal.fromJson(Map<String, Object?> json) =>
      ComputePathThroughPosesGoal(
        goals: Field.asList<ros2.PoseStamped>(
            json['goals'], ros2.PoseStamped.fromJson),
        start: Field.asMessage(json['start'], ros2.PoseStamped.fromJson),
        plannerId: Field.stringAt(json, 'planner_id'),
        useStart: Field.boolAt(json, 'use_start'),
      );

  final List<ros2.PoseStamped> goals;
  final ros2.PoseStamped start;
  final String plannerId;

  /// If false, use current robot pose as path start, if true, use start above instead
  final bool useStart;

  @override
  String get rosType => 'nav2_msgs/msg/ComputePathThroughPoses_Goal';

  @override
  Map<String, Object?> toJson() => {
        'goals': goals.map((ros2.PoseStamped e) => e.toJson()).toList(),
        'start': start.toJson(),
        'planner_id': plannerId,
        'use_start': useStart,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputePathThroughPosesGoal &&
          _listEquals(other.goals, goals) &&
          other.start == start &&
          other.plannerId == plannerId &&
          other.useStart == useStart);

  @override
  int get hashCode => Object.hashAll([
        ...goals,
        start,
        plannerId,
        useStart,
      ]);

  @override
  String toString() => 'ComputePathThroughPosesGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/ComputePathThroughPoses_Result`
final class ComputePathThroughPosesResult implements RosMessage {
  ComputePathThroughPosesResult({
    ros2.RosPath? path,
    ros2.RosDuration? planningTime,
    this.errorCode = 0,
    this.errorMsg = '',
  })  : path = path ?? ros2.RosPath(),
        planningTime = planningTime ?? ros2.RosDuration();

  factory ComputePathThroughPosesResult.fromJson(Map<String, Object?> json) =>
      ComputePathThroughPosesResult(
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        planningTime:
            Field.asMessage(json['planning_time'], ros2.RosDuration.fromJson),
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int unknown = 300;
  static const int invalidPlanner = 301;
  static const int tfError = 302;
  static const int startOutsideMap = 303;
  static const int goalOutsideMap = 304;
  static const int startOccupied = 305;
  static const int goalOccupied = 306;
  static const int timeout = 307;
  static const int noValidPath = 308;
  static const int noViapointsGiven = 309;

  final ros2.RosPath path;
  final ros2.RosDuration planningTime;
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/ComputePathThroughPoses_Result';

  @override
  Map<String, Object?> toJson() => {
        'path': path.toJson(),
        'planning_time': planningTime.toJson(),
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputePathThroughPosesResult &&
          other.path == path &&
          other.planningTime == planningTime &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        path,
        planningTime,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'ComputePathThroughPosesResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/ComputePathThroughPoses_Feedback`
final class ComputePathThroughPosesFeedback implements RosMessage {
  const ComputePathThroughPosesFeedback();

  factory ComputePathThroughPosesFeedback.fromJson(Map<String, Object?> json) =>
      ComputePathThroughPosesFeedback();

  @override
  String get rosType => 'nav2_msgs/msg/ComputePathThroughPoses_Feedback';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ComputePathThroughPosesFeedback;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'ComputePathThroughPosesFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/ComputePathToPose_Goal`
final class ComputePathToPoseGoal implements RosMessage {
  ComputePathToPoseGoal({
    ros2.PoseStamped? goal,
    ros2.PoseStamped? start,
    this.plannerId = '',
    this.useStart = false,
  })  : goal = goal ?? ros2.PoseStamped(),
        start = start ?? ros2.PoseStamped();

  factory ComputePathToPoseGoal.fromJson(Map<String, Object?> json) =>
      ComputePathToPoseGoal(
        goal: Field.asMessage(json['goal'], ros2.PoseStamped.fromJson),
        start: Field.asMessage(json['start'], ros2.PoseStamped.fromJson),
        plannerId: Field.stringAt(json, 'planner_id'),
        useStart: Field.boolAt(json, 'use_start'),
      );

  final ros2.PoseStamped goal;
  final ros2.PoseStamped start;
  final String plannerId;

  /// If false, use current robot pose as path start, if true, use start above instead
  final bool useStart;

  @override
  String get rosType => 'nav2_msgs/msg/ComputePathToPose_Goal';

  @override
  Map<String, Object?> toJson() => {
        'goal': goal.toJson(),
        'start': start.toJson(),
        'planner_id': plannerId,
        'use_start': useStart,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputePathToPoseGoal &&
          other.goal == goal &&
          other.start == start &&
          other.plannerId == plannerId &&
          other.useStart == useStart);

  @override
  int get hashCode => Object.hashAll([
        goal,
        start,
        plannerId,
        useStart,
      ]);

  @override
  String toString() => 'ComputePathToPoseGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/ComputePathToPose_Result`
final class ComputePathToPoseResult implements RosMessage {
  ComputePathToPoseResult({
    ros2.RosPath? path,
    ros2.RosDuration? planningTime,
    this.errorCode = 0,
    this.errorMsg = '',
  })  : path = path ?? ros2.RosPath(),
        planningTime = planningTime ?? ros2.RosDuration();

  factory ComputePathToPoseResult.fromJson(Map<String, Object?> json) =>
      ComputePathToPoseResult(
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        planningTime:
            Field.asMessage(json['planning_time'], ros2.RosDuration.fromJson),
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int unknown = 200;
  static const int invalidPlanner = 201;
  static const int tfError = 202;
  static const int startOutsideMap = 203;
  static const int goalOutsideMap = 204;
  static const int startOccupied = 205;
  static const int goalOccupied = 206;
  static const int timeout = 207;
  static const int noValidPath = 208;

  final ros2.RosPath path;
  final ros2.RosDuration planningTime;
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/ComputePathToPose_Result';

  @override
  Map<String, Object?> toJson() => {
        'path': path.toJson(),
        'planning_time': planningTime.toJson(),
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputePathToPoseResult &&
          other.path == path &&
          other.planningTime == planningTime &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        path,
        planningTime,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'ComputePathToPoseResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/ComputePathToPose_Feedback`
final class ComputePathToPoseFeedback implements RosMessage {
  const ComputePathToPoseFeedback();

  factory ComputePathToPoseFeedback.fromJson(Map<String, Object?> json) =>
      ComputePathToPoseFeedback();

  @override
  String get rosType => 'nav2_msgs/msg/ComputePathToPose_Feedback';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ComputePathToPoseFeedback;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'ComputePathToPoseFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/ComputeRoute_Goal`
final class ComputeRouteGoal implements RosMessage {
  ComputeRouteGoal({
    this.startId = 0,
    ros2.PoseStamped? start,
    this.goalId = 0,
    ros2.PoseStamped? goal,
    this.useStart = false,
    this.usePoses = false,
  })  : start = start ?? ros2.PoseStamped(),
        goal = goal ?? ros2.PoseStamped();

  factory ComputeRouteGoal.fromJson(Map<String, Object?> json) =>
      ComputeRouteGoal(
        startId: Field.intAt(json, 'start_id'),
        start: Field.asMessage(json['start'], ros2.PoseStamped.fromJson),
        goalId: Field.intAt(json, 'goal_id'),
        goal: Field.asMessage(json['goal'], ros2.PoseStamped.fromJson),
        useStart: Field.boolAt(json, 'use_start'),
        usePoses: Field.boolAt(json, 'use_poses'),
      );

  final int startId;
  final ros2.PoseStamped start;
  final int goalId;
  final ros2.PoseStamped goal;

  /// Whether to use the start field or find the start pose in TF
  final bool useStart;

  /// Whether to use the poses or the IDs fields for request
  final bool usePoses;

  @override
  String get rosType => 'nav2_msgs/msg/ComputeRoute_Goal';

  @override
  Map<String, Object?> toJson() => {
        'start_id': startId,
        'start': start.toJson(),
        'goal_id': goalId,
        'goal': goal.toJson(),
        'use_start': useStart,
        'use_poses': usePoses,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputeRouteGoal &&
          other.startId == startId &&
          other.start == start &&
          other.goalId == goalId &&
          other.goal == goal &&
          other.useStart == useStart &&
          other.usePoses == usePoses);

  @override
  int get hashCode => Object.hashAll([
        startId,
        start,
        goalId,
        goal,
        useStart,
        usePoses,
      ]);

  @override
  String toString() => 'ComputeRouteGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/ComputeRoute_Result`
final class ComputeRouteResult implements RosMessage {
  ComputeRouteResult({
    ros2.RosDuration? planningTime,
    ros2.RosPath? path,
    RosRoute? route,
    this.errorCode = 0,
  })  : planningTime = planningTime ?? ros2.RosDuration(),
        path = path ?? ros2.RosPath(),
        route = route ?? RosRoute();

  factory ComputeRouteResult.fromJson(Map<String, Object?> json) =>
      ComputeRouteResult(
        planningTime:
            Field.asMessage(json['planning_time'], ros2.RosDuration.fromJson),
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        route: Field.asMessage(json['route'], RosRoute.fromJson),
        errorCode: Field.intAt(json, 'error_code', 0),
      );

  static const int none = 0;
  static const int unknown = 400;
  static const int tfError = 401;
  static const int noValidGraph = 402;
  static const int indeterminantNodesOnGraph = 403;
  static const int timeout = 404;
  static const int noValidRoute = 405;
  static const int invalidEdgeScorerUse = 407;

  final ros2.RosDuration planningTime;
  final ros2.RosPath path;
  final RosRoute route;
  final int errorCode;

  @override
  String get rosType => 'nav2_msgs/msg/ComputeRoute_Result';

  @override
  Map<String, Object?> toJson() => {
        'planning_time': planningTime.toJson(),
        'path': path.toJson(),
        'route': route.toJson(),
        'error_code': errorCode,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputeRouteResult &&
          other.planningTime == planningTime &&
          other.path == path &&
          other.route == route &&
          other.errorCode == errorCode);

  @override
  int get hashCode => Object.hashAll([
        planningTime,
        path,
        route,
        errorCode,
      ]);

  @override
  String toString() => 'ComputeRouteResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/ComputeRoute_Feedback`
final class ComputeRouteFeedback implements RosMessage {
  const ComputeRouteFeedback();

  factory ComputeRouteFeedback.fromJson(Map<String, Object?> json) =>
      ComputeRouteFeedback();

  @override
  String get rosType => 'nav2_msgs/msg/ComputeRoute_Feedback';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ComputeRouteFeedback;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'ComputeRouteFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/DockRobot_Goal`
final class DockRobotGoal implements RosMessage {
  DockRobotGoal({
    this.useDockId = true,
    this.dockId = '',
    ros2.PoseStamped? dockPose,
    this.dockType = '',
    this.maxStagingTime = 1000.0,
    this.navigateToStagingPose = true,
  }) : dockPose = dockPose ?? ros2.PoseStamped();

  factory DockRobotGoal.fromJson(Map<String, Object?> json) => DockRobotGoal(
        useDockId: Field.boolAt(json, 'use_dock_id', true),
        dockId: Field.stringAt(json, 'dock_id'),
        dockPose: Field.asMessage(json['dock_pose'], ros2.PoseStamped.fromJson),
        dockType: Field.stringAt(json, 'dock_type'),
        maxStagingTime: Field.doubleAt(json, 'max_staging_time', 1000.0),
        navigateToStagingPose:
            Field.boolAt(json, 'navigate_to_staging_pose', true),
      );

  /// Whether to use the dock_id or dock_pose fields
  final bool useDockId;

  /// Dock name or ID to dock at, from given dock database
  final String dockId;

  /// Dock pose
  final ros2.PoseStamped dockPose;

  /// If using dock_pose, what type of dock it is. Not necessary if only using one type of dock.
  final String dockType;

  /// Maximum time for navigation to get to the dock's staging pose.
  final double maxStagingTime;

  /// Whether or not to navigate to staging pose or assume robot is already at staging pose within tolerance to execute behavior
  final bool navigateToStagingPose;

  @override
  String get rosType => 'nav2_msgs/msg/DockRobot_Goal';

  @override
  Map<String, Object?> toJson() => {
        'use_dock_id': useDockId,
        'dock_id': dockId,
        'dock_pose': dockPose.toJson(),
        'dock_type': dockType,
        'max_staging_time': maxStagingTime,
        'navigate_to_staging_pose': navigateToStagingPose,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DockRobotGoal &&
          other.useDockId == useDockId &&
          other.dockId == dockId &&
          other.dockPose == dockPose &&
          other.dockType == dockType &&
          other.maxStagingTime == maxStagingTime &&
          other.navigateToStagingPose == navigateToStagingPose);

  @override
  int get hashCode => Object.hashAll([
        useDockId,
        dockId,
        dockPose,
        dockType,
        maxStagingTime,
        navigateToStagingPose,
      ]);

  @override
  String toString() => 'DockRobotGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/DockRobot_Result`
final class DockRobotResult implements RosMessage {
  const DockRobotResult({
    this.success = true,
    this.errorCode = 0,
    this.numRetries = 0,
    this.errorMsg = '',
  });

  factory DockRobotResult.fromJson(Map<String, Object?> json) =>
      DockRobotResult(
        success: Field.boolAt(json, 'success', true),
        errorCode: Field.intAt(json, 'error_code', 0),
        numRetries: Field.intAt(json, 'num_retries', 0),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int dockNotInDb = 901;
  static const int dockNotValid = 902;
  static const int failedToStage = 903;
  static const int failedToDetectDock = 904;
  static const int failedToControl = 905;
  static const int failedToCharge = 906;
  static const int unknown = 999;

  /// docking success status
  final bool success;

  /// Contextual error code, if any
  final int errorCode;

  /// Number of retries attempted
  final int numRetries;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/DockRobot_Result';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
        'error_code': errorCode,
        'num_retries': numRetries,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DockRobotResult &&
          other.success == success &&
          other.errorCode == errorCode &&
          other.numRetries == numRetries &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        success,
        errorCode,
        numRetries,
        errorMsg,
      ]);

  @override
  String toString() => 'DockRobotResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/DockRobot_Feedback`
final class DockRobotFeedback implements RosMessage {
  DockRobotFeedback({
    this.state = 0,
    ros2.RosDuration? dockingTime,
    this.numRetries = 0,
  }) : dockingTime = dockingTime ?? ros2.RosDuration();

  factory DockRobotFeedback.fromJson(Map<String, Object?> json) =>
      DockRobotFeedback(
        state: Field.intAt(json, 'state'),
        dockingTime:
            Field.asMessage(json['docking_time'], ros2.RosDuration.fromJson),
        numRetries: Field.intAt(json, 'num_retries', 0),
      );

  static const int none = 0;
  static const int navToStagingPose = 1;
  static const int initialPerception = 2;
  static const int controlling = 3;
  static const int waitForCharge = 4;
  static const int retry = 5;

  /// Current docking state
  final int state;

  /// Docking time elapsed
  final ros2.RosDuration dockingTime;

  /// Number of retries attempted
  final int numRetries;

  @override
  String get rosType => 'nav2_msgs/msg/DockRobot_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'state': state,
        'docking_time': dockingTime.toJson(),
        'num_retries': numRetries,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DockRobotFeedback &&
          other.state == state &&
          other.dockingTime == dockingTime &&
          other.numRetries == numRetries);

  @override
  int get hashCode => Object.hashAll([
        state,
        dockingTime,
        numRetries,
      ]);

  @override
  String toString() => 'DockRobotFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/DriveOnHeading_Goal`
final class DriveOnHeadingGoal implements RosMessage {
  DriveOnHeadingGoal({
    ros2.Point? target,
    this.speed = 0,
    ros2.RosDuration? timeAllowance,
  })  : target = target ?? ros2.Point(),
        timeAllowance = timeAllowance ?? ros2.RosDuration();

  factory DriveOnHeadingGoal.fromJson(Map<String, Object?> json) =>
      DriveOnHeadingGoal(
        target: Field.asMessage(json['target'], ros2.Point.fromJson),
        speed: Field.doubleAt(json, 'speed'),
        timeAllowance:
            Field.asMessage(json['time_allowance'], ros2.RosDuration.fromJson),
      );

  final ros2.Point target;
  final double speed;
  final ros2.RosDuration timeAllowance;

  @override
  String get rosType => 'nav2_msgs/msg/DriveOnHeading_Goal';

  @override
  Map<String, Object?> toJson() => {
        'target': target.toJson(),
        'speed': speed,
        'time_allowance': timeAllowance.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriveOnHeadingGoal &&
          other.target == target &&
          other.speed == speed &&
          other.timeAllowance == timeAllowance);

  @override
  int get hashCode => Object.hashAll([
        target,
        speed,
        timeAllowance,
      ]);

  @override
  String toString() => 'DriveOnHeadingGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/DriveOnHeading_Result`
final class DriveOnHeadingResult implements RosMessage {
  DriveOnHeadingResult({
    ros2.RosDuration? totalElapsedTime,
    this.errorCode = 0,
    this.errorMsg = '',
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory DriveOnHeadingResult.fromJson(Map<String, Object?> json) =>
      DriveOnHeadingResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int unknown = 720;
  static const int timeout = 721;
  static const int tfError = 722;
  static const int collisionAhead = 723;
  static const int invalidInput = 724;

  final ros2.RosDuration totalElapsedTime;
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/DriveOnHeading_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriveOnHeadingResult &&
          other.totalElapsedTime == totalElapsedTime &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'DriveOnHeadingResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/DriveOnHeading_Feedback`
final class DriveOnHeadingFeedback implements RosMessage {
  const DriveOnHeadingFeedback({
    this.distanceTraveled = 0,
  });

  factory DriveOnHeadingFeedback.fromJson(Map<String, Object?> json) =>
      DriveOnHeadingFeedback(
        distanceTraveled: Field.doubleAt(json, 'distance_traveled'),
      );

  final double distanceTraveled;

  @override
  String get rosType => 'nav2_msgs/msg/DriveOnHeading_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'distance_traveled': distanceTraveled,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriveOnHeadingFeedback &&
          other.distanceTraveled == distanceTraveled);

  @override
  int get hashCode => Object.hashAll([
        distanceTraveled,
      ]);

  @override
  String toString() => 'DriveOnHeadingFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/DummyBehavior_Goal`
final class DummyBehaviorGoal implements RosMessage {
  DummyBehaviorGoal({
    ros2.StringMsg? command,
  }) : command = command ?? ros2.StringMsg();

  factory DummyBehaviorGoal.fromJson(Map<String, Object?> json) =>
      DummyBehaviorGoal(
        command: Field.asMessage(json['command'], ros2.StringMsg.fromJson),
      );

  final ros2.StringMsg command;

  @override
  String get rosType => 'nav2_msgs/msg/DummyBehavior_Goal';

  @override
  Map<String, Object?> toJson() => {
        'command': command.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DummyBehaviorGoal && other.command == command);

  @override
  int get hashCode => Object.hashAll([
        command,
      ]);

  @override
  String toString() => 'DummyBehaviorGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/DummyBehavior_Result`
final class DummyBehaviorResult implements RosMessage {
  DummyBehaviorResult({
    ros2.RosDuration? totalElapsedTime,
    this.errorCode = 0,
    this.errorMsg = '',
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory DummyBehaviorResult.fromJson(Map<String, Object?> json) =>
      DummyBehaviorResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  final ros2.RosDuration totalElapsedTime;
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/DummyBehavior_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DummyBehaviorResult &&
          other.totalElapsedTime == totalElapsedTime &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'DummyBehaviorResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/DummyBehavior_Feedback`
final class DummyBehaviorFeedback implements RosMessage {
  const DummyBehaviorFeedback();

  factory DummyBehaviorFeedback.fromJson(Map<String, Object?> json) =>
      DummyBehaviorFeedback();

  @override
  String get rosType => 'nav2_msgs/msg/DummyBehavior_Feedback';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DummyBehaviorFeedback;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'DummyBehaviorFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/FollowGPSWaypoints_Goal`
final class FollowGPSWaypointsGoal implements RosMessage {
  const FollowGPSWaypointsGoal({
    this.numberOfLoops = 0,
    this.goalIndex = 0,
    this.gpsPoses = const [],
  });

  factory FollowGPSWaypointsGoal.fromJson(Map<String, Object?> json) =>
      FollowGPSWaypointsGoal(
        numberOfLoops: Field.intAt(json, 'number_of_loops'),
        goalIndex: Field.intAt(json, 'goal_index', 0),
        gpsPoses: Field.asList<GeoPose>(json['gps_poses'], GeoPose.fromJson),
      );

  final int numberOfLoops;
  final int goalIndex;
  final List<GeoPose> gpsPoses;

  @override
  String get rosType => 'nav2_msgs/msg/FollowGPSWaypoints_Goal';

  @override
  Map<String, Object?> toJson() => {
        'number_of_loops': numberOfLoops,
        'goal_index': goalIndex,
        'gps_poses': gpsPoses.map((GeoPose e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowGPSWaypointsGoal &&
          other.numberOfLoops == numberOfLoops &&
          other.goalIndex == goalIndex &&
          _listEquals(other.gpsPoses, gpsPoses));

  @override
  int get hashCode => Object.hashAll([
        numberOfLoops,
        goalIndex,
        ...gpsPoses,
      ]);

  @override
  String toString() => 'FollowGPSWaypointsGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/FollowGPSWaypoints_Result`
final class FollowGPSWaypointsResult implements RosMessage {
  const FollowGPSWaypointsResult({
    this.missedWaypoints = const [],
    this.errorCode = 0,
    this.errorMsg = '',
  });

  factory FollowGPSWaypointsResult.fromJson(Map<String, Object?> json) =>
      FollowGPSWaypointsResult(
        missedWaypoints: Field.asList<MissedWaypoint>(
            json['missed_waypoints'], MissedWaypoint.fromJson),
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int unknown = 600;
  static const int taskExecutorFailed = 601;

  final List<MissedWaypoint> missedWaypoints;
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/FollowGPSWaypoints_Result';

  @override
  Map<String, Object?> toJson() => {
        'missed_waypoints':
            missedWaypoints.map((MissedWaypoint e) => e.toJson()).toList(),
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowGPSWaypointsResult &&
          _listEquals(other.missedWaypoints, missedWaypoints) &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        ...missedWaypoints,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'FollowGPSWaypointsResult(${toJson()})';
}

/// feedback
///
/// `nav2_msgs/msg/FollowGPSWaypoints_Feedback`
final class FollowGPSWaypointsFeedback implements RosMessage {
  const FollowGPSWaypointsFeedback({
    this.currentWaypoint = 0,
  });

  factory FollowGPSWaypointsFeedback.fromJson(Map<String, Object?> json) =>
      FollowGPSWaypointsFeedback(
        currentWaypoint: Field.intAt(json, 'current_waypoint'),
      );

  final int currentWaypoint;

  @override
  String get rosType => 'nav2_msgs/msg/FollowGPSWaypoints_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'current_waypoint': currentWaypoint,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowGPSWaypointsFeedback &&
          other.currentWaypoint == currentWaypoint);

  @override
  int get hashCode => Object.hashAll([
        currentWaypoint,
      ]);

  @override
  String toString() => 'FollowGPSWaypointsFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/FollowObject_Goal`
final class FollowObjectGoal implements RosMessage {
  FollowObjectGoal({
    this.poseTopic = '',
    this.trackedFrame = '',
    ros2.RosDuration? maxDuration,
  }) : maxDuration = maxDuration ?? ros2.RosDuration();

  factory FollowObjectGoal.fromJson(Map<String, Object?> json) =>
      FollowObjectGoal(
        poseTopic: Field.stringAt(json, 'pose_topic'),
        trackedFrame: Field.stringAt(json, 'tracked_frame'),
        maxDuration:
            Field.asMessage(json['max_duration'], ros2.RosDuration.fromJson),
      );

  /// Topic to publish the pose of the object to follow
  final String poseTopic;

  /// Target frame to follow (Optional, used if pose_topic is not set)
  final String trackedFrame;
  final ros2.RosDuration maxDuration;

  @override
  String get rosType => 'nav2_msgs/msg/FollowObject_Goal';

  @override
  Map<String, Object?> toJson() => {
        'pose_topic': poseTopic,
        'tracked_frame': trackedFrame,
        'max_duration': maxDuration.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowObjectGoal &&
          other.poseTopic == poseTopic &&
          other.trackedFrame == trackedFrame &&
          other.maxDuration == maxDuration);

  @override
  int get hashCode => Object.hashAll([
        poseTopic,
        trackedFrame,
        maxDuration,
      ]);

  @override
  String toString() => 'FollowObjectGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/FollowObject_Result`
final class FollowObjectResult implements RosMessage {
  FollowObjectResult({
    ros2.RosDuration? totalElapsedTime,
    this.errorCode = 0,
    this.numRetries = 0,
    this.errorMsg = '',
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory FollowObjectResult.fromJson(Map<String, Object?> json) =>
      FollowObjectResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
        errorCode: Field.intAt(json, 'error_code', 0),
        numRetries: Field.intAt(json, 'num_retries', 0),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int tfError = 901;
  static const int failedToDetectObject = 902;
  static const int failedToControl = 903;
  static const int timeout = 904;
  static const int unknown = 999;

  final ros2.RosDuration totalElapsedTime;

  /// Contextual error code, if any
  final int errorCode;

  /// Number of retries attempted
  final int numRetries;

  /// Error message, if any
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/FollowObject_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
        'error_code': errorCode,
        'num_retries': numRetries,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowObjectResult &&
          other.totalElapsedTime == totalElapsedTime &&
          other.errorCode == errorCode &&
          other.numRetries == numRetries &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
        errorCode,
        numRetries,
        errorMsg,
      ]);

  @override
  String toString() => 'FollowObjectResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/FollowObject_Feedback`
final class FollowObjectFeedback implements RosMessage {
  FollowObjectFeedback({
    this.state = 0,
    ros2.RosDuration? followingTime,
    this.numRetries = 0,
  }) : followingTime = followingTime ?? ros2.RosDuration();

  factory FollowObjectFeedback.fromJson(Map<String, Object?> json) =>
      FollowObjectFeedback(
        state: Field.intAt(json, 'state'),
        followingTime:
            Field.asMessage(json['following_time'], ros2.RosDuration.fromJson),
        numRetries: Field.intAt(json, 'num_retries', 0),
      );

  static const int none = 0;
  static const int initialPerception = 1;
  static const int controlling = 2;
  static const int stopping = 3;
  static const int retry = 4;

  /// Current following state
  final int state;
  final ros2.RosDuration followingTime;

  /// Number of retries attempted
  final int numRetries;

  @override
  String get rosType => 'nav2_msgs/msg/FollowObject_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'state': state,
        'following_time': followingTime.toJson(),
        'num_retries': numRetries,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowObjectFeedback &&
          other.state == state &&
          other.followingTime == followingTime &&
          other.numRetries == numRetries);

  @override
  int get hashCode => Object.hashAll([
        state,
        followingTime,
        numRetries,
      ]);

  @override
  String toString() => 'FollowObjectFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/FollowPath_Goal`
final class FollowPathGoal implements RosMessage {
  FollowPathGoal({
    ros2.RosPath? path,
    this.controllerId = '',
    this.goalCheckerId = '',
    this.progressCheckerId = '',
  }) : path = path ?? ros2.RosPath();

  factory FollowPathGoal.fromJson(Map<String, Object?> json) => FollowPathGoal(
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        controllerId: Field.stringAt(json, 'controller_id'),
        goalCheckerId: Field.stringAt(json, 'goal_checker_id'),
        progressCheckerId: Field.stringAt(json, 'progress_checker_id'),
      );

  final ros2.RosPath path;
  final String controllerId;
  final String goalCheckerId;
  final String progressCheckerId;

  @override
  String get rosType => 'nav2_msgs/msg/FollowPath_Goal';

  @override
  Map<String, Object?> toJson() => {
        'path': path.toJson(),
        'controller_id': controllerId,
        'goal_checker_id': goalCheckerId,
        'progress_checker_id': progressCheckerId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowPathGoal &&
          other.path == path &&
          other.controllerId == controllerId &&
          other.goalCheckerId == goalCheckerId &&
          other.progressCheckerId == progressCheckerId);

  @override
  int get hashCode => Object.hashAll([
        path,
        controllerId,
        goalCheckerId,
        progressCheckerId,
      ]);

  @override
  String toString() => 'FollowPathGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/FollowPath_Result`
final class FollowPathResult implements RosMessage {
  FollowPathResult({
    ros2.EmptyMsg? result,
    this.errorCode = 0,
    this.errorMsg = '',
  }) : result = result ?? ros2.EmptyMsg();

  factory FollowPathResult.fromJson(Map<String, Object?> json) =>
      FollowPathResult(
        result: Field.asMessage(json['result'], ros2.EmptyMsg.fromJson),
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int unknown = 100;
  static const int invalidController = 101;
  static const int tfError = 102;
  static const int invalidPath = 103;
  static const int patienceExceeded = 104;
  static const int failedToMakeProgress = 105;
  static const int noValidControl = 106;
  static const int controllerTimedOut = 107;

  final ros2.EmptyMsg result;
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/FollowPath_Result';

  @override
  Map<String, Object?> toJson() => {
        'result': result.toJson(),
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowPathResult &&
          other.result == result &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        result,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'FollowPathResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/FollowPath_Feedback`
final class FollowPathFeedback implements RosMessage {
  const FollowPathFeedback({
    this.distanceToGoal = 0,
    this.speed = 0,
  });

  factory FollowPathFeedback.fromJson(Map<String, Object?> json) =>
      FollowPathFeedback(
        distanceToGoal: Field.doubleAt(json, 'distance_to_goal'),
        speed: Field.doubleAt(json, 'speed'),
      );

  final double distanceToGoal;
  final double speed;

  @override
  String get rosType => 'nav2_msgs/msg/FollowPath_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'distance_to_goal': distanceToGoal,
        'speed': speed,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowPathFeedback &&
          other.distanceToGoal == distanceToGoal &&
          other.speed == speed);

  @override
  int get hashCode => Object.hashAll([
        distanceToGoal,
        speed,
      ]);

  @override
  String toString() => 'FollowPathFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/FollowWaypoints_Goal`
final class FollowWaypointsGoal implements RosMessage {
  const FollowWaypointsGoal({
    this.numberOfLoops = 0,
    this.goalIndex = 0,
    this.poses = const [],
  });

  factory FollowWaypointsGoal.fromJson(Map<String, Object?> json) =>
      FollowWaypointsGoal(
        numberOfLoops: Field.intAt(json, 'number_of_loops'),
        goalIndex: Field.intAt(json, 'goal_index', 0),
        poses: Field.asList<ros2.PoseStamped>(
            json['poses'], ros2.PoseStamped.fromJson),
      );

  final int numberOfLoops;
  final int goalIndex;
  final List<ros2.PoseStamped> poses;

  @override
  String get rosType => 'nav2_msgs/msg/FollowWaypoints_Goal';

  @override
  Map<String, Object?> toJson() => {
        'number_of_loops': numberOfLoops,
        'goal_index': goalIndex,
        'poses': poses.map((ros2.PoseStamped e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowWaypointsGoal &&
          other.numberOfLoops == numberOfLoops &&
          other.goalIndex == goalIndex &&
          _listEquals(other.poses, poses));

  @override
  int get hashCode => Object.hashAll([
        numberOfLoops,
        goalIndex,
        ...poses,
      ]);

  @override
  String toString() => 'FollowWaypointsGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/FollowWaypoints_Result`
final class FollowWaypointsResult implements RosMessage {
  const FollowWaypointsResult({
    this.missedWaypoints = const [],
    this.errorCode = 0,
    this.errorMsg = '',
  });

  factory FollowWaypointsResult.fromJson(Map<String, Object?> json) =>
      FollowWaypointsResult(
        missedWaypoints: Field.asList<MissedWaypoint>(
            json['missed_waypoints'], MissedWaypoint.fromJson),
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int unknown = 600;
  static const int taskExecutorFailed = 601;

  final List<MissedWaypoint> missedWaypoints;
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/FollowWaypoints_Result';

  @override
  Map<String, Object?> toJson() => {
        'missed_waypoints':
            missedWaypoints.map((MissedWaypoint e) => e.toJson()).toList(),
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowWaypointsResult &&
          _listEquals(other.missedWaypoints, missedWaypoints) &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        ...missedWaypoints,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'FollowWaypointsResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/FollowWaypoints_Feedback`
final class FollowWaypointsFeedback implements RosMessage {
  const FollowWaypointsFeedback({
    this.currentWaypoint = 0,
  });

  factory FollowWaypointsFeedback.fromJson(Map<String, Object?> json) =>
      FollowWaypointsFeedback(
        currentWaypoint: Field.intAt(json, 'current_waypoint'),
      );

  final int currentWaypoint;

  @override
  String get rosType => 'nav2_msgs/msg/FollowWaypoints_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'current_waypoint': currentWaypoint,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowWaypointsFeedback &&
          other.currentWaypoint == currentWaypoint);

  @override
  int get hashCode => Object.hashAll([
        currentWaypoint,
      ]);

  @override
  String toString() => 'FollowWaypointsFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/NavigateThroughPoses_Goal`
final class NavigateThroughPosesGoal implements RosMessage {
  const NavigateThroughPosesGoal({
    this.poses = const [],
    this.behaviorTree = '',
  });

  factory NavigateThroughPosesGoal.fromJson(Map<String, Object?> json) =>
      NavigateThroughPosesGoal(
        poses: Field.asList<ros2.PoseStamped>(
            json['poses'], ros2.PoseStamped.fromJson),
        behaviorTree: Field.stringAt(json, 'behavior_tree'),
      );

  final List<ros2.PoseStamped> poses;
  final String behaviorTree;

  @override
  String get rosType => 'nav2_msgs/msg/NavigateThroughPoses_Goal';

  @override
  Map<String, Object?> toJson() => {
        'poses': poses.map((ros2.PoseStamped e) => e.toJson()).toList(),
        'behavior_tree': behaviorTree,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NavigateThroughPosesGoal &&
          _listEquals(other.poses, poses) &&
          other.behaviorTree == behaviorTree);

  @override
  int get hashCode => Object.hashAll([
        ...poses,
        behaviorTree,
      ]);

  @override
  String toString() => 'NavigateThroughPosesGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/NavigateThroughPoses_Result`
final class NavigateThroughPosesResult implements RosMessage {
  const NavigateThroughPosesResult({
    this.errorCode = 0,
    this.errorMsg = '',
  });

  factory NavigateThroughPosesResult.fromJson(Map<String, Object?> json) =>
      NavigateThroughPosesResult(
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;

  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/NavigateThroughPoses_Result';

  @override
  Map<String, Object?> toJson() => {
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NavigateThroughPosesResult &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'NavigateThroughPosesResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/NavigateThroughPoses_Feedback`
final class NavigateThroughPosesFeedback implements RosMessage {
  NavigateThroughPosesFeedback({
    ros2.PoseStamped? currentPose,
    ros2.RosDuration? navigationTime,
    ros2.RosDuration? estimatedTimeRemaining,
    this.numberOfRecoveries = 0,
    this.distanceRemaining = 0,
    this.numberOfPosesRemaining = 0,
  })  : currentPose = currentPose ?? ros2.PoseStamped(),
        navigationTime = navigationTime ?? ros2.RosDuration(),
        estimatedTimeRemaining = estimatedTimeRemaining ?? ros2.RosDuration();

  factory NavigateThroughPosesFeedback.fromJson(Map<String, Object?> json) =>
      NavigateThroughPosesFeedback(
        currentPose:
            Field.asMessage(json['current_pose'], ros2.PoseStamped.fromJson),
        navigationTime:
            Field.asMessage(json['navigation_time'], ros2.RosDuration.fromJson),
        estimatedTimeRemaining: Field.asMessage(
            json['estimated_time_remaining'], ros2.RosDuration.fromJson),
        numberOfRecoveries: Field.intAt(json, 'number_of_recoveries'),
        distanceRemaining: Field.doubleAt(json, 'distance_remaining'),
        numberOfPosesRemaining: Field.intAt(json, 'number_of_poses_remaining'),
      );

  final ros2.PoseStamped currentPose;
  final ros2.RosDuration navigationTime;
  final ros2.RosDuration estimatedTimeRemaining;
  final int numberOfRecoveries;
  final double distanceRemaining;
  final int numberOfPosesRemaining;

  @override
  String get rosType => 'nav2_msgs/msg/NavigateThroughPoses_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'current_pose': currentPose.toJson(),
        'navigation_time': navigationTime.toJson(),
        'estimated_time_remaining': estimatedTimeRemaining.toJson(),
        'number_of_recoveries': numberOfRecoveries,
        'distance_remaining': distanceRemaining,
        'number_of_poses_remaining': numberOfPosesRemaining,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NavigateThroughPosesFeedback &&
          other.currentPose == currentPose &&
          other.navigationTime == navigationTime &&
          other.estimatedTimeRemaining == estimatedTimeRemaining &&
          other.numberOfRecoveries == numberOfRecoveries &&
          other.distanceRemaining == distanceRemaining &&
          other.numberOfPosesRemaining == numberOfPosesRemaining);

  @override
  int get hashCode => Object.hashAll([
        currentPose,
        navigationTime,
        estimatedTimeRemaining,
        numberOfRecoveries,
        distanceRemaining,
        numberOfPosesRemaining,
      ]);

  @override
  String toString() => 'NavigateThroughPosesFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/NavigateToPose_Goal`
final class NavigateToPoseGoal implements RosMessage {
  NavigateToPoseGoal({
    ros2.PoseStamped? pose,
    this.behaviorTree = '',
  }) : pose = pose ?? ros2.PoseStamped();

  factory NavigateToPoseGoal.fromJson(Map<String, Object?> json) =>
      NavigateToPoseGoal(
        pose: Field.asMessage(json['pose'], ros2.PoseStamped.fromJson),
        behaviorTree: Field.stringAt(json, 'behavior_tree'),
      );

  final ros2.PoseStamped pose;
  final String behaviorTree;

  @override
  String get rosType => 'nav2_msgs/msg/NavigateToPose_Goal';

  @override
  Map<String, Object?> toJson() => {
        'pose': pose.toJson(),
        'behavior_tree': behaviorTree,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NavigateToPoseGoal &&
          other.pose == pose &&
          other.behaviorTree == behaviorTree);

  @override
  int get hashCode => Object.hashAll([
        pose,
        behaviorTree,
      ]);

  @override
  String toString() => 'NavigateToPoseGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/NavigateToPose_Result`
final class NavigateToPoseResult implements RosMessage {
  const NavigateToPoseResult({
    this.errorCode = 0,
    this.errorMsg = '',
  });

  factory NavigateToPoseResult.fromJson(Map<String, Object?> json) =>
      NavigateToPoseResult(
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;

  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/NavigateToPose_Result';

  @override
  Map<String, Object?> toJson() => {
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NavigateToPoseResult &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'NavigateToPoseResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/NavigateToPose_Feedback`
final class NavigateToPoseFeedback implements RosMessage {
  NavigateToPoseFeedback({
    ros2.PoseStamped? currentPose,
    ros2.RosDuration? navigationTime,
    ros2.RosDuration? estimatedTimeRemaining,
    this.numberOfRecoveries = 0,
    this.distanceRemaining = 0,
  })  : currentPose = currentPose ?? ros2.PoseStamped(),
        navigationTime = navigationTime ?? ros2.RosDuration(),
        estimatedTimeRemaining = estimatedTimeRemaining ?? ros2.RosDuration();

  factory NavigateToPoseFeedback.fromJson(Map<String, Object?> json) =>
      NavigateToPoseFeedback(
        currentPose:
            Field.asMessage(json['current_pose'], ros2.PoseStamped.fromJson),
        navigationTime:
            Field.asMessage(json['navigation_time'], ros2.RosDuration.fromJson),
        estimatedTimeRemaining: Field.asMessage(
            json['estimated_time_remaining'], ros2.RosDuration.fromJson),
        numberOfRecoveries: Field.intAt(json, 'number_of_recoveries'),
        distanceRemaining: Field.doubleAt(json, 'distance_remaining'),
      );

  final ros2.PoseStamped currentPose;
  final ros2.RosDuration navigationTime;
  final ros2.RosDuration estimatedTimeRemaining;
  final int numberOfRecoveries;
  final double distanceRemaining;

  @override
  String get rosType => 'nav2_msgs/msg/NavigateToPose_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'current_pose': currentPose.toJson(),
        'navigation_time': navigationTime.toJson(),
        'estimated_time_remaining': estimatedTimeRemaining.toJson(),
        'number_of_recoveries': numberOfRecoveries,
        'distance_remaining': distanceRemaining,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NavigateToPoseFeedback &&
          other.currentPose == currentPose &&
          other.navigationTime == navigationTime &&
          other.estimatedTimeRemaining == estimatedTimeRemaining &&
          other.numberOfRecoveries == numberOfRecoveries &&
          other.distanceRemaining == distanceRemaining);

  @override
  int get hashCode => Object.hashAll([
        currentPose,
        navigationTime,
        estimatedTimeRemaining,
        numberOfRecoveries,
        distanceRemaining,
      ]);

  @override
  String toString() => 'NavigateToPoseFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/SmoothPath_Goal`
final class SmoothPathGoal implements RosMessage {
  SmoothPathGoal({
    ros2.RosPath? path,
    this.smootherId = '',
    ros2.RosDuration? maxSmoothingDuration,
    this.checkForCollisions = false,
  })  : path = path ?? ros2.RosPath(),
        maxSmoothingDuration = maxSmoothingDuration ?? ros2.RosDuration();

  factory SmoothPathGoal.fromJson(Map<String, Object?> json) => SmoothPathGoal(
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        smootherId: Field.stringAt(json, 'smoother_id'),
        maxSmoothingDuration: Field.asMessage(
            json['max_smoothing_duration'], ros2.RosDuration.fromJson),
        checkForCollisions: Field.boolAt(json, 'check_for_collisions'),
      );

  final ros2.RosPath path;
  final String smootherId;
  final ros2.RosDuration maxSmoothingDuration;
  final bool checkForCollisions;

  @override
  String get rosType => 'nav2_msgs/msg/SmoothPath_Goal';

  @override
  Map<String, Object?> toJson() => {
        'path': path.toJson(),
        'smoother_id': smootherId,
        'max_smoothing_duration': maxSmoothingDuration.toJson(),
        'check_for_collisions': checkForCollisions,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmoothPathGoal &&
          other.path == path &&
          other.smootherId == smootherId &&
          other.maxSmoothingDuration == maxSmoothingDuration &&
          other.checkForCollisions == checkForCollisions);

  @override
  int get hashCode => Object.hashAll([
        path,
        smootherId,
        maxSmoothingDuration,
        checkForCollisions,
      ]);

  @override
  String toString() => 'SmoothPathGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/SmoothPath_Result`
final class SmoothPathResult implements RosMessage {
  SmoothPathResult({
    ros2.RosPath? path,
    ros2.RosDuration? smoothingDuration,
    this.wasCompleted = false,
    this.errorCode = 0,
    this.errorMsg = '',
  })  : path = path ?? ros2.RosPath(),
        smoothingDuration = smoothingDuration ?? ros2.RosDuration();

  factory SmoothPathResult.fromJson(Map<String, Object?> json) =>
      SmoothPathResult(
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        smoothingDuration: Field.asMessage(
            json['smoothing_duration'], ros2.RosDuration.fromJson),
        wasCompleted: Field.boolAt(json, 'was_completed'),
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int unknown = 500;
  static const int invalidSmoother = 501;
  static const int timeout = 502;
  static const int smoothedPathInCollision = 503;
  static const int failedToSmoothPath = 504;
  static const int invalidPath = 505;

  final ros2.RosPath path;
  final ros2.RosDuration smoothingDuration;
  final bool wasCompleted;
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/SmoothPath_Result';

  @override
  Map<String, Object?> toJson() => {
        'path': path.toJson(),
        'smoothing_duration': smoothingDuration.toJson(),
        'was_completed': wasCompleted,
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmoothPathResult &&
          other.path == path &&
          other.smoothingDuration == smoothingDuration &&
          other.wasCompleted == wasCompleted &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        path,
        smoothingDuration,
        wasCompleted,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'SmoothPathResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/SmoothPath_Feedback`
final class SmoothPathFeedback implements RosMessage {
  const SmoothPathFeedback();

  factory SmoothPathFeedback.fromJson(Map<String, Object?> json) =>
      SmoothPathFeedback();

  @override
  String get rosType => 'nav2_msgs/msg/SmoothPath_Feedback';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SmoothPathFeedback;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'SmoothPathFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/Spin_Goal`
final class SpinGoal implements RosMessage {
  SpinGoal({
    this.targetYaw = 0,
    ros2.RosDuration? timeAllowance,
  }) : timeAllowance = timeAllowance ?? ros2.RosDuration();

  factory SpinGoal.fromJson(Map<String, Object?> json) => SpinGoal(
        targetYaw: Field.doubleAt(json, 'target_yaw'),
        timeAllowance:
            Field.asMessage(json['time_allowance'], ros2.RosDuration.fromJson),
      );

  final double targetYaw;
  final ros2.RosDuration timeAllowance;

  @override
  String get rosType => 'nav2_msgs/msg/Spin_Goal';

  @override
  Map<String, Object?> toJson() => {
        'target_yaw': targetYaw,
        'time_allowance': timeAllowance.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpinGoal &&
          other.targetYaw == targetYaw &&
          other.timeAllowance == timeAllowance);

  @override
  int get hashCode => Object.hashAll([
        targetYaw,
        timeAllowance,
      ]);

  @override
  String toString() => 'SpinGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/Spin_Result`
final class SpinResult implements RosMessage {
  SpinResult({
    ros2.RosDuration? totalElapsedTime,
    this.errorCode = 0,
    this.errorMsg = '',
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory SpinResult.fromJson(Map<String, Object?> json) => SpinResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int unknown = 700;
  static const int timeout = 701;
  static const int tfError = 702;
  static const int collisionAhead = 703;

  final ros2.RosDuration totalElapsedTime;
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/Spin_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpinResult &&
          other.totalElapsedTime == totalElapsedTime &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'SpinResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/Spin_Feedback`
final class SpinFeedback implements RosMessage {
  const SpinFeedback({
    this.angularDistanceTraveled = 0,
  });

  factory SpinFeedback.fromJson(Map<String, Object?> json) => SpinFeedback(
        angularDistanceTraveled:
            Field.doubleAt(json, 'angular_distance_traveled'),
      );

  final double angularDistanceTraveled;

  @override
  String get rosType => 'nav2_msgs/msg/Spin_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'angular_distance_traveled': angularDistanceTraveled,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpinFeedback &&
          other.angularDistanceTraveled == angularDistanceTraveled);

  @override
  int get hashCode => Object.hashAll([
        angularDistanceTraveled,
      ]);

  @override
  String toString() => 'SpinFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/UndockRobot_Goal`
final class UndockRobotGoal implements RosMessage {
  const UndockRobotGoal({
    this.dockType = '',
    this.maxUndockingTime = 30.0,
  });

  factory UndockRobotGoal.fromJson(Map<String, Object?> json) =>
      UndockRobotGoal(
        dockType: Field.stringAt(json, 'dock_type'),
        maxUndockingTime: Field.doubleAt(json, 'max_undocking_time', 30.0),
      );

  final String dockType;

  /// Maximum time to undock
  final double maxUndockingTime;

  @override
  String get rosType => 'nav2_msgs/msg/UndockRobot_Goal';

  @override
  Map<String, Object?> toJson() => {
        'dock_type': dockType,
        'max_undocking_time': maxUndockingTime,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UndockRobotGoal &&
          other.dockType == dockType &&
          other.maxUndockingTime == maxUndockingTime);

  @override
  int get hashCode => Object.hashAll([
        dockType,
        maxUndockingTime,
      ]);

  @override
  String toString() => 'UndockRobotGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/UndockRobot_Result`
final class UndockRobotResult implements RosMessage {
  const UndockRobotResult({
    this.success = true,
    this.errorCode = 0,
    this.errorMsg = '',
  });

  factory UndockRobotResult.fromJson(Map<String, Object?> json) =>
      UndockRobotResult(
        success: Field.boolAt(json, 'success', true),
        errorCode: Field.intAt(json, 'error_code', 0),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  static const int none = 0;
  static const int dockNotValid = 902;
  static const int failedToControl = 905;
  static const int unknown = 999;

  /// docking success status
  final bool success;

  /// Contextual error code, if any
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/UndockRobot_Result';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UndockRobotResult &&
          other.success == success &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        success,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'UndockRobotResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/UndockRobot_Feedback`
final class UndockRobotFeedback implements RosMessage {
  const UndockRobotFeedback();

  factory UndockRobotFeedback.fromJson(Map<String, Object?> json) =>
      UndockRobotFeedback();

  @override
  String get rosType => 'nav2_msgs/msg/UndockRobot_Feedback';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UndockRobotFeedback;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'UndockRobotFeedback(${toJson()})';
}

/// goal definition
///
/// `nav2_msgs/msg/Wait_Goal`
final class WaitGoal implements RosMessage {
  WaitGoal({
    ros2.RosDuration? time,
  }) : time = time ?? ros2.RosDuration();

  factory WaitGoal.fromJson(Map<String, Object?> json) => WaitGoal(
        time: Field.asMessage(json['time'], ros2.RosDuration.fromJson),
      );

  final ros2.RosDuration time;

  @override
  String get rosType => 'nav2_msgs/msg/Wait_Goal';

  @override
  Map<String, Object?> toJson() => {
        'time': time.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is WaitGoal && other.time == time);

  @override
  int get hashCode => Object.hashAll([
        time,
      ]);

  @override
  String toString() => 'WaitGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/Wait_Result`
final class WaitResult implements RosMessage {
  WaitResult({
    ros2.RosDuration? totalElapsedTime,
    this.errorCode = 0,
    this.errorMsg = '',
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory WaitResult.fromJson(Map<String, Object?> json) => WaitResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
        errorCode: Field.intAt(json, 'error_code'),
        errorMsg: Field.stringAt(json, 'error_msg'),
      );

  final ros2.RosDuration totalElapsedTime;
  final int errorCode;
  final String errorMsg;

  @override
  String get rosType => 'nav2_msgs/msg/Wait_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
        'error_code': errorCode,
        'error_msg': errorMsg,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaitResult &&
          other.totalElapsedTime == totalElapsedTime &&
          other.errorCode == errorCode &&
          other.errorMsg == errorMsg);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
        errorCode,
        errorMsg,
      ]);

  @override
  String toString() => 'WaitResult(${toJson()})';
}

/// feedback definition
///
/// `nav2_msgs/msg/Wait_Feedback`
final class WaitFeedback implements RosMessage {
  WaitFeedback({
    ros2.RosDuration? timeLeft,
  }) : timeLeft = timeLeft ?? ros2.RosDuration();

  factory WaitFeedback.fromJson(Map<String, Object?> json) => WaitFeedback(
        timeLeft: Field.asMessage(json['time_left'], ros2.RosDuration.fromJson),
      );

  final ros2.RosDuration timeLeft;

  @override
  String get rosType => 'nav2_msgs/msg/Wait_Feedback';

  @override
  Map<String, Object?> toJson() => {
        'time_left': timeLeft.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaitFeedback && other.timeLeft == timeLeft);

  @override
  int get hashCode => Object.hashAll([
        timeLeft,
      ]);

  @override
  String toString() => 'WaitFeedback(${toJson()})';
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

/// Registers every message in `nav2_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerNav2Msgs() {
  MessageRegistry.register(const MessageCodec<BehaviorTreeLog>(
    rosType: 'nav2_msgs/msg/BehaviorTreeLog',
    fromJson: BehaviorTreeLog.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<BehaviorTreeStatusChange>(
    rosType: 'nav2_msgs/msg/BehaviorTreeStatusChange',
    fromJson: BehaviorTreeStatusChange.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<CollisionDetectorState>(
    rosType: 'nav2_msgs/msg/CollisionDetectorState',
    fromJson: CollisionDetectorState.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<CollisionMonitorState>(
    rosType: 'nav2_msgs/msg/CollisionMonitorState',
    fromJson: CollisionMonitorState.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Costmap>(
    rosType: 'nav2_msgs/msg/Costmap',
    fromJson: Costmap.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<CostmapFilterInfo>(
    rosType: 'nav2_msgs/msg/CostmapFilterInfo',
    fromJson: CostmapFilterInfo.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<CostmapMetaData>(
    rosType: 'nav2_msgs/msg/CostmapMetaData',
    fromJson: CostmapMetaData.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<CostmapUpdate>(
    rosType: 'nav2_msgs/msg/CostmapUpdate',
    fromJson: CostmapUpdate.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<EdgeCost>(
    rosType: 'nav2_msgs/msg/EdgeCost',
    fromJson: EdgeCost.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MissedWaypoint>(
    rosType: 'nav2_msgs/msg/MissedWaypoint',
    fromJson: MissedWaypoint.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Particle>(
    rosType: 'nav2_msgs/msg/Particle',
    fromJson: Particle.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ParticleCloud>(
    rosType: 'nav2_msgs/msg/ParticleCloud',
    fromJson: ParticleCloud.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<RosRoute>(
    rosType: 'nav2_msgs/msg/Route',
    fromJson: RosRoute.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<RouteEdge>(
    rosType: 'nav2_msgs/msg/RouteEdge',
    fromJson: RouteEdge.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<RouteNode>(
    rosType: 'nav2_msgs/msg/RouteNode',
    fromJson: RouteNode.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SpeedLimit>(
    rosType: 'nav2_msgs/msg/SpeedLimit',
    fromJson: SpeedLimit.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<VoxelGrid>(
    rosType: 'nav2_msgs/msg/VoxelGrid',
    fromJson: VoxelGrid.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ClearCostmapAroundPoseRequest>(
    rosType: 'nav2_msgs/msg/ClearCostmapAroundPose_Request',
    fromJson: ClearCostmapAroundPoseRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ClearCostmapAroundPoseResponse>(
    rosType: 'nav2_msgs/msg/ClearCostmapAroundPose_Response',
    fromJson: ClearCostmapAroundPoseResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ClearCostmapAroundRobotRequest>(
    rosType: 'nav2_msgs/msg/ClearCostmapAroundRobot_Request',
    fromJson: ClearCostmapAroundRobotRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ClearCostmapAroundRobotResponse>(
    rosType: 'nav2_msgs/msg/ClearCostmapAroundRobot_Response',
    fromJson: ClearCostmapAroundRobotResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ClearCostmapExceptRegionRequest>(
    rosType: 'nav2_msgs/msg/ClearCostmapExceptRegion_Request',
    fromJson: ClearCostmapExceptRegionRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ClearCostmapExceptRegionResponse>(
    rosType: 'nav2_msgs/msg/ClearCostmapExceptRegion_Response',
    fromJson: ClearCostmapExceptRegionResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ClearEntireCostmapRequest>(
    rosType: 'nav2_msgs/msg/ClearEntireCostmap_Request',
    fromJson: ClearEntireCostmapRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ClearEntireCostmapResponse>(
    rosType: 'nav2_msgs/msg/ClearEntireCostmap_Response',
    fromJson: ClearEntireCostmapResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DynamicEdgesRequest>(
    rosType: 'nav2_msgs/msg/DynamicEdges_Request',
    fromJson: DynamicEdgesRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DynamicEdgesResponse>(
    rosType: 'nav2_msgs/msg/DynamicEdges_Response',
    fromJson: DynamicEdgesResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetCostRequest>(
    rosType: 'nav2_msgs/msg/GetCost_Request',
    fromJson: GetCostRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetCostResponse>(
    rosType: 'nav2_msgs/msg/GetCost_Response',
    fromJson: GetCostResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetCostmapRequest>(
    rosType: 'nav2_msgs/msg/GetCostmap_Request',
    fromJson: GetCostmapRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetCostmapResponse>(
    rosType: 'nav2_msgs/msg/GetCostmap_Response',
    fromJson: GetCostmapResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<IsPathValidRequest>(
    rosType: 'nav2_msgs/msg/IsPathValid_Request',
    fromJson: IsPathValidRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<IsPathValidResponse>(
    rosType: 'nav2_msgs/msg/IsPathValid_Response',
    fromJson: IsPathValidResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<LoadMapRequest>(
    rosType: 'nav2_msgs/msg/LoadMap_Request',
    fromJson: LoadMapRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<LoadMapResponse>(
    rosType: 'nav2_msgs/msg/LoadMap_Response',
    fromJson: LoadMapResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ManageLifecycleNodesRequest>(
    rosType: 'nav2_msgs/msg/ManageLifecycleNodes_Request',
    fromJson: ManageLifecycleNodesRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ManageLifecycleNodesResponse>(
    rosType: 'nav2_msgs/msg/ManageLifecycleNodes_Response',
    fromJson: ManageLifecycleNodesResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ReloadDockDatabaseRequest>(
    rosType: 'nav2_msgs/msg/ReloadDockDatabase_Request',
    fromJson: ReloadDockDatabaseRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ReloadDockDatabaseResponse>(
    rosType: 'nav2_msgs/msg/ReloadDockDatabase_Response',
    fromJson: ReloadDockDatabaseResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SaveMapRequest>(
    rosType: 'nav2_msgs/msg/SaveMap_Request',
    fromJson: SaveMapRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SaveMapResponse>(
    rosType: 'nav2_msgs/msg/SaveMap_Response',
    fromJson: SaveMapResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SetInitialPoseRequest>(
    rosType: 'nav2_msgs/msg/SetInitialPose_Request',
    fromJson: SetInitialPoseRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SetInitialPoseResponse>(
    rosType: 'nav2_msgs/msg/SetInitialPose_Response',
    fromJson: SetInitialPoseResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SetRouteGraphRequest>(
    rosType: 'nav2_msgs/msg/SetRouteGraph_Request',
    fromJson: SetRouteGraphRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SetRouteGraphResponse>(
    rosType: 'nav2_msgs/msg/SetRouteGraph_Response',
    fromJson: SetRouteGraphResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ToggleRequest>(
    rosType: 'nav2_msgs/msg/Toggle_Request',
    fromJson: ToggleRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ToggleResponse>(
    rosType: 'nav2_msgs/msg/Toggle_Response',
    fromJson: ToggleResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<AssistedTeleopGoal>(
    rosType: 'nav2_msgs/msg/AssistedTeleop_Goal',
    fromJson: AssistedTeleopGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<AssistedTeleopResult>(
    rosType: 'nav2_msgs/msg/AssistedTeleop_Result',
    fromJson: AssistedTeleopResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<AssistedTeleopFeedback>(
    rosType: 'nav2_msgs/msg/AssistedTeleop_Feedback',
    fromJson: AssistedTeleopFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<BackUpGoal>(
    rosType: 'nav2_msgs/msg/BackUp_Goal',
    fromJson: BackUpGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<BackUpResult>(
    rosType: 'nav2_msgs/msg/BackUp_Result',
    fromJson: BackUpResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<BackUpFeedback>(
    rosType: 'nav2_msgs/msg/BackUp_Feedback',
    fromJson: BackUpFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ComputeAndTrackRouteGoal>(
    rosType: 'nav2_msgs/msg/ComputeAndTrackRoute_Goal',
    fromJson: ComputeAndTrackRouteGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ComputeAndTrackRouteResult>(
    rosType: 'nav2_msgs/msg/ComputeAndTrackRoute_Result',
    fromJson: ComputeAndTrackRouteResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ComputeAndTrackRouteFeedback>(
    rosType: 'nav2_msgs/msg/ComputeAndTrackRoute_Feedback',
    fromJson: ComputeAndTrackRouteFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ComputePathThroughPosesGoal>(
    rosType: 'nav2_msgs/msg/ComputePathThroughPoses_Goal',
    fromJson: ComputePathThroughPosesGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ComputePathThroughPosesResult>(
    rosType: 'nav2_msgs/msg/ComputePathThroughPoses_Result',
    fromJson: ComputePathThroughPosesResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ComputePathThroughPosesFeedback>(
    rosType: 'nav2_msgs/msg/ComputePathThroughPoses_Feedback',
    fromJson: ComputePathThroughPosesFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ComputePathToPoseGoal>(
    rosType: 'nav2_msgs/msg/ComputePathToPose_Goal',
    fromJson: ComputePathToPoseGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ComputePathToPoseResult>(
    rosType: 'nav2_msgs/msg/ComputePathToPose_Result',
    fromJson: ComputePathToPoseResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ComputePathToPoseFeedback>(
    rosType: 'nav2_msgs/msg/ComputePathToPose_Feedback',
    fromJson: ComputePathToPoseFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ComputeRouteGoal>(
    rosType: 'nav2_msgs/msg/ComputeRoute_Goal',
    fromJson: ComputeRouteGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ComputeRouteResult>(
    rosType: 'nav2_msgs/msg/ComputeRoute_Result',
    fromJson: ComputeRouteResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ComputeRouteFeedback>(
    rosType: 'nav2_msgs/msg/ComputeRoute_Feedback',
    fromJson: ComputeRouteFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DockRobotGoal>(
    rosType: 'nav2_msgs/msg/DockRobot_Goal',
    fromJson: DockRobotGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DockRobotResult>(
    rosType: 'nav2_msgs/msg/DockRobot_Result',
    fromJson: DockRobotResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DockRobotFeedback>(
    rosType: 'nav2_msgs/msg/DockRobot_Feedback',
    fromJson: DockRobotFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DriveOnHeadingGoal>(
    rosType: 'nav2_msgs/msg/DriveOnHeading_Goal',
    fromJson: DriveOnHeadingGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DriveOnHeadingResult>(
    rosType: 'nav2_msgs/msg/DriveOnHeading_Result',
    fromJson: DriveOnHeadingResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DriveOnHeadingFeedback>(
    rosType: 'nav2_msgs/msg/DriveOnHeading_Feedback',
    fromJson: DriveOnHeadingFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DummyBehaviorGoal>(
    rosType: 'nav2_msgs/msg/DummyBehavior_Goal',
    fromJson: DummyBehaviorGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DummyBehaviorResult>(
    rosType: 'nav2_msgs/msg/DummyBehavior_Result',
    fromJson: DummyBehaviorResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DummyBehaviorFeedback>(
    rosType: 'nav2_msgs/msg/DummyBehavior_Feedback',
    fromJson: DummyBehaviorFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowGPSWaypointsGoal>(
    rosType: 'nav2_msgs/msg/FollowGPSWaypoints_Goal',
    fromJson: FollowGPSWaypointsGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowGPSWaypointsResult>(
    rosType: 'nav2_msgs/msg/FollowGPSWaypoints_Result',
    fromJson: FollowGPSWaypointsResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowGPSWaypointsFeedback>(
    rosType: 'nav2_msgs/msg/FollowGPSWaypoints_Feedback',
    fromJson: FollowGPSWaypointsFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowObjectGoal>(
    rosType: 'nav2_msgs/msg/FollowObject_Goal',
    fromJson: FollowObjectGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowObjectResult>(
    rosType: 'nav2_msgs/msg/FollowObject_Result',
    fromJson: FollowObjectResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowObjectFeedback>(
    rosType: 'nav2_msgs/msg/FollowObject_Feedback',
    fromJson: FollowObjectFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowPathGoal>(
    rosType: 'nav2_msgs/msg/FollowPath_Goal',
    fromJson: FollowPathGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowPathResult>(
    rosType: 'nav2_msgs/msg/FollowPath_Result',
    fromJson: FollowPathResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowPathFeedback>(
    rosType: 'nav2_msgs/msg/FollowPath_Feedback',
    fromJson: FollowPathFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowWaypointsGoal>(
    rosType: 'nav2_msgs/msg/FollowWaypoints_Goal',
    fromJson: FollowWaypointsGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowWaypointsResult>(
    rosType: 'nav2_msgs/msg/FollowWaypoints_Result',
    fromJson: FollowWaypointsResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<FollowWaypointsFeedback>(
    rosType: 'nav2_msgs/msg/FollowWaypoints_Feedback',
    fromJson: FollowWaypointsFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<NavigateThroughPosesGoal>(
    rosType: 'nav2_msgs/msg/NavigateThroughPoses_Goal',
    fromJson: NavigateThroughPosesGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<NavigateThroughPosesResult>(
    rosType: 'nav2_msgs/msg/NavigateThroughPoses_Result',
    fromJson: NavigateThroughPosesResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<NavigateThroughPosesFeedback>(
    rosType: 'nav2_msgs/msg/NavigateThroughPoses_Feedback',
    fromJson: NavigateThroughPosesFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<NavigateToPoseGoal>(
    rosType: 'nav2_msgs/msg/NavigateToPose_Goal',
    fromJson: NavigateToPoseGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<NavigateToPoseResult>(
    rosType: 'nav2_msgs/msg/NavigateToPose_Result',
    fromJson: NavigateToPoseResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<NavigateToPoseFeedback>(
    rosType: 'nav2_msgs/msg/NavigateToPose_Feedback',
    fromJson: NavigateToPoseFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SmoothPathGoal>(
    rosType: 'nav2_msgs/msg/SmoothPath_Goal',
    fromJson: SmoothPathGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SmoothPathResult>(
    rosType: 'nav2_msgs/msg/SmoothPath_Result',
    fromJson: SmoothPathResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SmoothPathFeedback>(
    rosType: 'nav2_msgs/msg/SmoothPath_Feedback',
    fromJson: SmoothPathFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SpinGoal>(
    rosType: 'nav2_msgs/msg/Spin_Goal',
    fromJson: SpinGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SpinResult>(
    rosType: 'nav2_msgs/msg/Spin_Result',
    fromJson: SpinResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SpinFeedback>(
    rosType: 'nav2_msgs/msg/Spin_Feedback',
    fromJson: SpinFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UndockRobotGoal>(
    rosType: 'nav2_msgs/msg/UndockRobot_Goal',
    fromJson: UndockRobotGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UndockRobotResult>(
    rosType: 'nav2_msgs/msg/UndockRobot_Result',
    fromJson: UndockRobotResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UndockRobotFeedback>(
    rosType: 'nav2_msgs/msg/UndockRobot_Feedback',
    fromJson: UndockRobotFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<WaitGoal>(
    rosType: 'nav2_msgs/msg/Wait_Goal',
    fromJson: WaitGoal.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<WaitResult>(
    rosType: 'nav2_msgs/msg/Wait_Result',
    fromJson: WaitResult.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<WaitFeedback>(
    rosType: 'nav2_msgs/msg/Wait_Feedback',
    fromJson: WaitFeedback.fromJson,
    toJson: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<ClearCostmapAroundPoseRequest,
      ClearCostmapAroundPoseResponse>(
    serviceType: 'nav2_msgs/srv/ClearCostmapAroundPose',
    encodeRequest: _toJson,
    decodeResponse: ClearCostmapAroundPoseResponse.fromJson,
    decodeRequest: ClearCostmapAroundPoseRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<ClearCostmapAroundRobotRequest,
      ClearCostmapAroundRobotResponse>(
    serviceType: 'nav2_msgs/srv/ClearCostmapAroundRobot',
    encodeRequest: _toJson,
    decodeResponse: ClearCostmapAroundRobotResponse.fromJson,
    decodeRequest: ClearCostmapAroundRobotRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<ClearCostmapExceptRegionRequest,
      ClearCostmapExceptRegionResponse>(
    serviceType: 'nav2_msgs/srv/ClearCostmapExceptRegion',
    encodeRequest: _toJson,
    decodeResponse: ClearCostmapExceptRegionResponse.fromJson,
    decodeRequest: ClearCostmapExceptRegionRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<ClearEntireCostmapRequest, ClearEntireCostmapResponse>(
    serviceType: 'nav2_msgs/srv/ClearEntireCostmap',
    encodeRequest: _toJson,
    decodeResponse: ClearEntireCostmapResponse.fromJson,
    decodeRequest: ClearEntireCostmapRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<DynamicEdgesRequest, DynamicEdgesResponse>(
    serviceType: 'nav2_msgs/srv/DynamicEdges',
    encodeRequest: _toJson,
    decodeResponse: DynamicEdgesResponse.fromJson,
    decodeRequest: DynamicEdgesRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<GetCostRequest, GetCostResponse>(
    serviceType: 'nav2_msgs/srv/GetCost',
    encodeRequest: _toJson,
    decodeResponse: GetCostResponse.fromJson,
    decodeRequest: GetCostRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<GetCostmapRequest, GetCostmapResponse>(
    serviceType: 'nav2_msgs/srv/GetCostmap',
    encodeRequest: _toJson,
    decodeResponse: GetCostmapResponse.fromJson,
    decodeRequest: GetCostmapRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<IsPathValidRequest, IsPathValidResponse>(
    serviceType: 'nav2_msgs/srv/IsPathValid',
    encodeRequest: _toJson,
    decodeResponse: IsPathValidResponse.fromJson,
    decodeRequest: IsPathValidRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<LoadMapRequest, LoadMapResponse>(
    serviceType: 'nav2_msgs/srv/LoadMap',
    encodeRequest: _toJson,
    decodeResponse: LoadMapResponse.fromJson,
    decodeRequest: LoadMapRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<ManageLifecycleNodesRequest,
      ManageLifecycleNodesResponse>(
    serviceType: 'nav2_msgs/srv/ManageLifecycleNodes',
    encodeRequest: _toJson,
    decodeResponse: ManageLifecycleNodesResponse.fromJson,
    decodeRequest: ManageLifecycleNodesRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<ReloadDockDatabaseRequest, ReloadDockDatabaseResponse>(
    serviceType: 'nav2_msgs/srv/ReloadDockDatabase',
    encodeRequest: _toJson,
    decodeResponse: ReloadDockDatabaseResponse.fromJson,
    decodeRequest: ReloadDockDatabaseRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<SaveMapRequest, SaveMapResponse>(
    serviceType: 'nav2_msgs/srv/SaveMap',
    encodeRequest: _toJson,
    decodeResponse: SaveMapResponse.fromJson,
    decodeRequest: SaveMapRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<SetInitialPoseRequest, SetInitialPoseResponse>(
    serviceType: 'nav2_msgs/srv/SetInitialPose',
    encodeRequest: _toJson,
    decodeResponse: SetInitialPoseResponse.fromJson,
    decodeRequest: SetInitialPoseRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<SetRouteGraphRequest, SetRouteGraphResponse>(
    serviceType: 'nav2_msgs/srv/SetRouteGraph',
    encodeRequest: _toJson,
    decodeResponse: SetRouteGraphResponse.fromJson,
    decodeRequest: SetRouteGraphRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<ToggleRequest, ToggleResponse>(
    serviceType: 'nav2_msgs/srv/Toggle',
    encodeRequest: _toJson,
    decodeResponse: ToggleResponse.fromJson,
    decodeRequest: ToggleRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ActionRegistry.register(const ActionCodec<AssistedTeleopGoal,
      AssistedTeleopFeedback, AssistedTeleopResult>(
    actionType: 'nav2_msgs/action/AssistedTeleop',
    encodeGoal: _toJson,
    decodeFeedback: AssistedTeleopFeedback.fromJson,
    decodeResult: AssistedTeleopResult.fromJson,
  ));
  ActionRegistry.register(
      const ActionCodec<BackUpGoal, BackUpFeedback, BackUpResult>(
    actionType: 'nav2_msgs/action/BackUp',
    encodeGoal: _toJson,
    decodeFeedback: BackUpFeedback.fromJson,
    decodeResult: BackUpResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<ComputeAndTrackRouteGoal,
      ComputeAndTrackRouteFeedback, ComputeAndTrackRouteResult>(
    actionType: 'nav2_msgs/action/ComputeAndTrackRoute',
    encodeGoal: _toJson,
    decodeFeedback: ComputeAndTrackRouteFeedback.fromJson,
    decodeResult: ComputeAndTrackRouteResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<ComputePathThroughPosesGoal,
      ComputePathThroughPosesFeedback, ComputePathThroughPosesResult>(
    actionType: 'nav2_msgs/action/ComputePathThroughPoses',
    encodeGoal: _toJson,
    decodeFeedback: ComputePathThroughPosesFeedback.fromJson,
    decodeResult: ComputePathThroughPosesResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<ComputePathToPoseGoal,
      ComputePathToPoseFeedback, ComputePathToPoseResult>(
    actionType: 'nav2_msgs/action/ComputePathToPose',
    encodeGoal: _toJson,
    decodeFeedback: ComputePathToPoseFeedback.fromJson,
    decodeResult: ComputePathToPoseResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<ComputeRouteGoal,
      ComputeRouteFeedback, ComputeRouteResult>(
    actionType: 'nav2_msgs/action/ComputeRoute',
    encodeGoal: _toJson,
    decodeFeedback: ComputeRouteFeedback.fromJson,
    decodeResult: ComputeRouteResult.fromJson,
  ));
  ActionRegistry.register(
      const ActionCodec<DockRobotGoal, DockRobotFeedback, DockRobotResult>(
    actionType: 'nav2_msgs/action/DockRobot',
    encodeGoal: _toJson,
    decodeFeedback: DockRobotFeedback.fromJson,
    decodeResult: DockRobotResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<DriveOnHeadingGoal,
      DriveOnHeadingFeedback, DriveOnHeadingResult>(
    actionType: 'nav2_msgs/action/DriveOnHeading',
    encodeGoal: _toJson,
    decodeFeedback: DriveOnHeadingFeedback.fromJson,
    decodeResult: DriveOnHeadingResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<DummyBehaviorGoal,
      DummyBehaviorFeedback, DummyBehaviorResult>(
    actionType: 'nav2_msgs/action/DummyBehavior',
    encodeGoal: _toJson,
    decodeFeedback: DummyBehaviorFeedback.fromJson,
    decodeResult: DummyBehaviorResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<FollowGPSWaypointsGoal,
      FollowGPSWaypointsFeedback, FollowGPSWaypointsResult>(
    actionType: 'nav2_msgs/action/FollowGPSWaypoints',
    encodeGoal: _toJson,
    decodeFeedback: FollowGPSWaypointsFeedback.fromJson,
    decodeResult: FollowGPSWaypointsResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<FollowObjectGoal,
      FollowObjectFeedback, FollowObjectResult>(
    actionType: 'nav2_msgs/action/FollowObject',
    encodeGoal: _toJson,
    decodeFeedback: FollowObjectFeedback.fromJson,
    decodeResult: FollowObjectResult.fromJson,
  ));
  ActionRegistry.register(
      const ActionCodec<FollowPathGoal, FollowPathFeedback, FollowPathResult>(
    actionType: 'nav2_msgs/action/FollowPath',
    encodeGoal: _toJson,
    decodeFeedback: FollowPathFeedback.fromJson,
    decodeResult: FollowPathResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<FollowWaypointsGoal,
      FollowWaypointsFeedback, FollowWaypointsResult>(
    actionType: 'nav2_msgs/action/FollowWaypoints',
    encodeGoal: _toJson,
    decodeFeedback: FollowWaypointsFeedback.fromJson,
    decodeResult: FollowWaypointsResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<NavigateThroughPosesGoal,
      NavigateThroughPosesFeedback, NavigateThroughPosesResult>(
    actionType: 'nav2_msgs/action/NavigateThroughPoses',
    encodeGoal: _toJson,
    decodeFeedback: NavigateThroughPosesFeedback.fromJson,
    decodeResult: NavigateThroughPosesResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<NavigateToPoseGoal,
      NavigateToPoseFeedback, NavigateToPoseResult>(
    actionType: 'nav2_msgs/action/NavigateToPose',
    encodeGoal: _toJson,
    decodeFeedback: NavigateToPoseFeedback.fromJson,
    decodeResult: NavigateToPoseResult.fromJson,
  ));
  ActionRegistry.register(
      const ActionCodec<SmoothPathGoal, SmoothPathFeedback, SmoothPathResult>(
    actionType: 'nav2_msgs/action/SmoothPath',
    encodeGoal: _toJson,
    decodeFeedback: SmoothPathFeedback.fromJson,
    decodeResult: SmoothPathResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<SpinGoal, SpinFeedback, SpinResult>(
    actionType: 'nav2_msgs/action/Spin',
    encodeGoal: _toJson,
    decodeFeedback: SpinFeedback.fromJson,
    decodeResult: SpinResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<UndockRobotGoal,
      UndockRobotFeedback, UndockRobotResult>(
    actionType: 'nav2_msgs/action/UndockRobot',
    encodeGoal: _toJson,
    decodeFeedback: UndockRobotFeedback.fromJson,
    decodeResult: UndockRobotResult.fromJson,
  ));
  ActionRegistry.register(const ActionCodec<WaitGoal, WaitFeedback, WaitResult>(
    actionType: 'nav2_msgs/action/Wait',
    encodeGoal: _toJson,
    decodeFeedback: WaitFeedback.fromJson,
    decodeResult: WaitResult.fromJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
