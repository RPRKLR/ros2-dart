// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package nav2_msgs

import 'dart:typed_data';

import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;
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
    this.previousStatus = '',
    this.currentStatus = '',
  }) : timestamp = timestamp ?? ros2.RosTime();

  factory BehaviorTreeStatusChange.fromJson(Map<String, Object?> json) =>
      BehaviorTreeStatusChange(
        timestamp: Field.asMessage(json['timestamp'], ros2.RosTime.fromJson),
        nodeName: Field.asString(json['node_name']),
        previousStatus: Field.asString(json['previous_status']),
        currentStatus: Field.asString(json['current_status']),
      );

  /// internal behavior tree event timestamp. Typically this is wall clock time
  final ros2.RosTime timestamp;
  final String nodeName;

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
        'previous_status': previousStatus,
        'current_status': currentStatus,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BehaviorTreeStatusChange &&
          other.timestamp == timestamp &&
          other.nodeName == nodeName &&
          other.previousStatus == previousStatus &&
          other.currentStatus == currentStatus);

  @override
  int get hashCode => Object.hashAll([
        timestamp,
        nodeName,
        previousStatus,
        currentStatus,
      ]);

  @override
  String toString() => 'BehaviorTreeStatusChange(${toJson()})';
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
        actionType: Field.asInt(json['action_type']),
        polygonName: Field.asString(json['polygon_name']),
      );

  /// No action
  static const int doNothing = 0;

  /// Stop the robot
  static const int stop = 1;

  /// Slowdown in percentage from current operating speed
  static const int slowdown = 2;

  /// Keep constant time interval before collision
  static const int approach = 3;

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
        type: Field.asInt(json['type']),
        filterMaskTopic: Field.asString(json['filter_mask_topic']),
        base: Field.asDouble(json['base']),
        multiplier: Field.asDouble(json['multiplier']),
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
        layer: Field.asString(json['layer']),
        resolution: Field.asDouble(json['resolution']),
        sizeX: Field.asInt(json['size_x']),
        sizeY: Field.asInt(json['size_y']),
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

/// Edge cost to use with nav2_msgs/srv/DynamicEdges to adjust route edge costs
///
/// `nav2_msgs/msg/EdgeCost`
final class EdgeCost implements RosMessage {
  const EdgeCost({
    this.edgeid = 0,
    this.cost = 0,
  });

  factory EdgeCost.fromJson(Map<String, Object?> json) => EdgeCost(
        edgeid: Field.asInt(json['edgeid']),
        cost: Field.asDouble(json['cost']),
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
        weight: Field.asDouble(json['weight']),
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
        routeCost: Field.asDouble(json['route_cost']),
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
        edgeid: Field.asInt(json['edgeid']),
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
        nodeid: Field.asInt(json['nodeid']),
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
        percentage: Field.asBool(json['percentage']),
        speedLimit: Field.asDouble(json['speed_limit']),
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
        sizeX: Field.asInt(json['size_x']),
        sizeY: Field.asInt(json['size_y']),
        sizeZ: Field.asInt(json['size_z']),
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

/// Clears the costmap within a distance
///
/// `nav2_msgs/msg/ClearCostmapAroundRobot_Request`
final class ClearCostmapAroundRobotRequest implements RosMessage {
  const ClearCostmapAroundRobotRequest({
    this.resetDistance = 0,
  });

  factory ClearCostmapAroundRobotRequest.fromJson(Map<String, Object?> json) =>
      ClearCostmapAroundRobotRequest(
        resetDistance: Field.asDouble(json['reset_distance']),
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
        resetDistance: Field.asDouble(json['reset_distance']),
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
        success: Field.asBool(json['success']),
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
        isValid: Field.asBool(json['is_valid']),
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
        mapUrl: Field.asString(json['map_url']),
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
        result: Field.asInt(json['result']),
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
        command: Field.asInt(json['command']),
      );

  static const int startup = 0;
  static const int pause = 1;
  static const int resume = 2;
  static const int reset = 3;
  static const int shutdown = 4;

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
        success: Field.asBool(json['success']),
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
        mapTopic: Field.asString(json['map_topic']),
        mapUrl: Field.asString(json['map_url']),
        imageFormat: Field.asString(json['image_format']),
        mapMode: Field.asString(json['map_mode']),
        freeThresh: Field.asDouble(json['free_thresh']),
        occupiedThresh: Field.asDouble(json['occupied_thresh']),
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
        result: Field.asBool(json['result']),
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
        graphFilepath: Field.asString(json['graph_filepath']),
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
        success: Field.asBool(json['success']),
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
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory AssistedTeleopResult.fromJson(Map<String, Object?> json) =>
      AssistedTeleopResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
      );

  final ros2.RosDuration totalElapsedTime;

  @override
  String get rosType => 'nav2_msgs/msg/AssistedTeleop_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssistedTeleopResult &&
          other.totalElapsedTime == totalElapsedTime);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
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
        speed: Field.asDouble(json['speed']),
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
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory BackUpResult.fromJson(Map<String, Object?> json) => BackUpResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
      );

  final ros2.RosDuration totalElapsedTime;

  @override
  String get rosType => 'nav2_msgs/msg/BackUp_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackUpResult && other.totalElapsedTime == totalElapsedTime);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
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
        distanceTraveled: Field.asDouble(json['distance_traveled']),
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
        startId: Field.asInt(json['start_id']),
        start: Field.asMessage(json['start'], ros2.PoseStamped.fromJson),
        goalId: Field.asInt(json['goal_id']),
        goal: Field.asMessage(json['goal'], ros2.PoseStamped.fromJson),
        useStart: Field.asBool(json['use_start']),
        usePoses: Field.asBool(json['use_poses']),
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
  }) : executionDuration = executionDuration ?? ros2.RosDuration();

  factory ComputeAndTrackRouteResult.fromJson(Map<String, Object?> json) =>
      ComputeAndTrackRouteResult(
        executionDuration: Field.asMessage(
            json['execution_duration'], ros2.RosDuration.fromJson),
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

  @override
  String get rosType => 'nav2_msgs/msg/ComputeAndTrackRoute_Result';

  @override
  Map<String, Object?> toJson() => {
        'execution_duration': executionDuration.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputeAndTrackRouteResult &&
          other.executionDuration == executionDuration);

  @override
  int get hashCode => Object.hashAll([
        executionDuration,
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
        lastNodeId: Field.asInt(json['last_node_id']),
        nextNodeId: Field.asInt(json['next_node_id']),
        currentEdgeId: Field.asInt(json['current_edge_id']),
        route: Field.asMessage(json['route'], RosRoute.fromJson),
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        operationsTriggered: Field.asStringList(json['operations_triggered']),
        rerouted: Field.asBool(json['rerouted']),
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
        plannerId: Field.asString(json['planner_id']),
        useStart: Field.asBool(json['use_start']),
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
  })  : path = path ?? ros2.RosPath(),
        planningTime = planningTime ?? ros2.RosDuration();

  factory ComputePathThroughPosesResult.fromJson(Map<String, Object?> json) =>
      ComputePathThroughPosesResult(
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        planningTime:
            Field.asMessage(json['planning_time'], ros2.RosDuration.fromJson),
      );

  final ros2.RosPath path;
  final ros2.RosDuration planningTime;

  @override
  String get rosType => 'nav2_msgs/msg/ComputePathThroughPoses_Result';

  @override
  Map<String, Object?> toJson() => {
        'path': path.toJson(),
        'planning_time': planningTime.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputePathThroughPosesResult &&
          other.path == path &&
          other.planningTime == planningTime);

  @override
  int get hashCode => Object.hashAll([
        path,
        planningTime,
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
        plannerId: Field.asString(json['planner_id']),
        useStart: Field.asBool(json['use_start']),
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
  })  : path = path ?? ros2.RosPath(),
        planningTime = planningTime ?? ros2.RosDuration();

  factory ComputePathToPoseResult.fromJson(Map<String, Object?> json) =>
      ComputePathToPoseResult(
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        planningTime:
            Field.asMessage(json['planning_time'], ros2.RosDuration.fromJson),
      );

  final ros2.RosPath path;
  final ros2.RosDuration planningTime;

  @override
  String get rosType => 'nav2_msgs/msg/ComputePathToPose_Result';

  @override
  Map<String, Object?> toJson() => {
        'path': path.toJson(),
        'planning_time': planningTime.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputePathToPoseResult &&
          other.path == path &&
          other.planningTime == planningTime);

  @override
  int get hashCode => Object.hashAll([
        path,
        planningTime,
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
        startId: Field.asInt(json['start_id']),
        start: Field.asMessage(json['start'], ros2.PoseStamped.fromJson),
        goalId: Field.asInt(json['goal_id']),
        goal: Field.asMessage(json['goal'], ros2.PoseStamped.fromJson),
        useStart: Field.asBool(json['use_start']),
        usePoses: Field.asBool(json['use_poses']),
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
  })  : planningTime = planningTime ?? ros2.RosDuration(),
        path = path ?? ros2.RosPath(),
        route = route ?? RosRoute();

  factory ComputeRouteResult.fromJson(Map<String, Object?> json) =>
      ComputeRouteResult(
        planningTime:
            Field.asMessage(json['planning_time'], ros2.RosDuration.fromJson),
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        route: Field.asMessage(json['route'], RosRoute.fromJson),
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

  @override
  String get rosType => 'nav2_msgs/msg/ComputeRoute_Result';

  @override
  Map<String, Object?> toJson() => {
        'planning_time': planningTime.toJson(),
        'path': path.toJson(),
        'route': route.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComputeRouteResult &&
          other.planningTime == planningTime &&
          other.path == path &&
          other.route == route);

  @override
  int get hashCode => Object.hashAll([
        planningTime,
        path,
        route,
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
        speed: Field.asDouble(json['speed']),
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
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory DriveOnHeadingResult.fromJson(Map<String, Object?> json) =>
      DriveOnHeadingResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
      );

  final ros2.RosDuration totalElapsedTime;

  @override
  String get rosType => 'nav2_msgs/msg/DriveOnHeading_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriveOnHeadingResult &&
          other.totalElapsedTime == totalElapsedTime);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
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
        distanceTraveled: Field.asDouble(json['distance_traveled']),
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
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory DummyBehaviorResult.fromJson(Map<String, Object?> json) =>
      DummyBehaviorResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
      );

  final ros2.RosDuration totalElapsedTime;

  @override
  String get rosType => 'nav2_msgs/msg/DummyBehavior_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DummyBehaviorResult &&
          other.totalElapsedTime == totalElapsedTime);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
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
/// `nav2_msgs/msg/FollowPath_Goal`
final class FollowPathGoal implements RosMessage {
  FollowPathGoal({
    ros2.RosPath? path,
    this.controllerId = '',
    this.goalCheckerId = '',
  }) : path = path ?? ros2.RosPath();

  factory FollowPathGoal.fromJson(Map<String, Object?> json) => FollowPathGoal(
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        controllerId: Field.asString(json['controller_id']),
        goalCheckerId: Field.asString(json['goal_checker_id']),
      );

  final ros2.RosPath path;
  final String controllerId;
  final String goalCheckerId;

  @override
  String get rosType => 'nav2_msgs/msg/FollowPath_Goal';

  @override
  Map<String, Object?> toJson() => {
        'path': path.toJson(),
        'controller_id': controllerId,
        'goal_checker_id': goalCheckerId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowPathGoal &&
          other.path == path &&
          other.controllerId == controllerId &&
          other.goalCheckerId == goalCheckerId);

  @override
  int get hashCode => Object.hashAll([
        path,
        controllerId,
        goalCheckerId,
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
  }) : result = result ?? ros2.EmptyMsg();

  factory FollowPathResult.fromJson(Map<String, Object?> json) =>
      FollowPathResult(
        result: Field.asMessage(json['result'], ros2.EmptyMsg.fromJson),
      );

  final ros2.EmptyMsg result;

  @override
  String get rosType => 'nav2_msgs/msg/FollowPath_Result';

  @override
  Map<String, Object?> toJson() => {
        'result': result.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowPathResult && other.result == result);

  @override
  int get hashCode => Object.hashAll([
        result,
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
        distanceToGoal: Field.asDouble(json['distance_to_goal']),
        speed: Field.asDouble(json['speed']),
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
    this.poses = const [],
  });

  factory FollowWaypointsGoal.fromJson(Map<String, Object?> json) =>
      FollowWaypointsGoal(
        poses: Field.asList<ros2.PoseStamped>(
            json['poses'], ros2.PoseStamped.fromJson),
      );

  final List<ros2.PoseStamped> poses;

  @override
  String get rosType => 'nav2_msgs/msg/FollowWaypoints_Goal';

  @override
  Map<String, Object?> toJson() => {
        'poses': poses.map((ros2.PoseStamped e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowWaypointsGoal && _listEquals(other.poses, poses));

  @override
  int get hashCode => Object.hashAll([
        ...poses,
      ]);

  @override
  String toString() => 'FollowWaypointsGoal(${toJson()})';
}

/// result definition
///
/// `nav2_msgs/msg/FollowWaypoints_Result`
final class FollowWaypointsResult implements RosMessage {
  FollowWaypointsResult({
    Int32List? missedWaypoints,
  }) : missedWaypoints = missedWaypoints ?? Int32List(0);

  factory FollowWaypointsResult.fromJson(Map<String, Object?> json) =>
      FollowWaypointsResult(
        missedWaypoints: Field.asInt32List(json['missed_waypoints']),
      );

  final Int32List missedWaypoints;

  @override
  String get rosType => 'nav2_msgs/msg/FollowWaypoints_Result';

  @override
  Map<String, Object?> toJson() => {
        'missed_waypoints': Field.encodeNumbers(missedWaypoints),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowWaypointsResult &&
          _listEquals(other.missedWaypoints, missedWaypoints));

  @override
  int get hashCode => Object.hashAll([
        ...missedWaypoints,
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
        currentWaypoint: Field.asInt(json['current_waypoint']),
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
        behaviorTree: Field.asString(json['behavior_tree']),
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
  NavigateThroughPosesResult({
    ros2.EmptyMsg? result,
  }) : result = result ?? ros2.EmptyMsg();

  factory NavigateThroughPosesResult.fromJson(Map<String, Object?> json) =>
      NavigateThroughPosesResult(
        result: Field.asMessage(json['result'], ros2.EmptyMsg.fromJson),
      );

  final ros2.EmptyMsg result;

  @override
  String get rosType => 'nav2_msgs/msg/NavigateThroughPoses_Result';

  @override
  Map<String, Object?> toJson() => {
        'result': result.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NavigateThroughPosesResult && other.result == result);

  @override
  int get hashCode => Object.hashAll([
        result,
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
        numberOfRecoveries: Field.asInt(json['number_of_recoveries']),
        distanceRemaining: Field.asDouble(json['distance_remaining']),
        numberOfPosesRemaining: Field.asInt(json['number_of_poses_remaining']),
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
        behaviorTree: Field.asString(json['behavior_tree']),
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
  NavigateToPoseResult({
    ros2.EmptyMsg? result,
  }) : result = result ?? ros2.EmptyMsg();

  factory NavigateToPoseResult.fromJson(Map<String, Object?> json) =>
      NavigateToPoseResult(
        result: Field.asMessage(json['result'], ros2.EmptyMsg.fromJson),
      );

  final ros2.EmptyMsg result;

  @override
  String get rosType => 'nav2_msgs/msg/NavigateToPose_Result';

  @override
  Map<String, Object?> toJson() => {
        'result': result.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NavigateToPoseResult && other.result == result);

  @override
  int get hashCode => Object.hashAll([
        result,
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
        numberOfRecoveries: Field.asInt(json['number_of_recoveries']),
        distanceRemaining: Field.asDouble(json['distance_remaining']),
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
        smootherId: Field.asString(json['smoother_id']),
        maxSmoothingDuration: Field.asMessage(
            json['max_smoothing_duration'], ros2.RosDuration.fromJson),
        checkForCollisions: Field.asBool(json['check_for_collisions']),
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
  })  : path = path ?? ros2.RosPath(),
        smoothingDuration = smoothingDuration ?? ros2.RosDuration();

  factory SmoothPathResult.fromJson(Map<String, Object?> json) =>
      SmoothPathResult(
        path: Field.asMessage(json['path'], ros2.RosPath.fromJson),
        smoothingDuration: Field.asMessage(
            json['smoothing_duration'], ros2.RosDuration.fromJson),
        wasCompleted: Field.asBool(json['was_completed']),
      );

  final ros2.RosPath path;
  final ros2.RosDuration smoothingDuration;
  final bool wasCompleted;

  @override
  String get rosType => 'nav2_msgs/msg/SmoothPath_Result';

  @override
  Map<String, Object?> toJson() => {
        'path': path.toJson(),
        'smoothing_duration': smoothingDuration.toJson(),
        'was_completed': wasCompleted,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmoothPathResult &&
          other.path == path &&
          other.smoothingDuration == smoothingDuration &&
          other.wasCompleted == wasCompleted);

  @override
  int get hashCode => Object.hashAll([
        path,
        smoothingDuration,
        wasCompleted,
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
        targetYaw: Field.asDouble(json['target_yaw']),
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
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory SpinResult.fromJson(Map<String, Object?> json) => SpinResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
      );

  final ros2.RosDuration totalElapsedTime;

  @override
  String get rosType => 'nav2_msgs/msg/Spin_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpinResult && other.totalElapsedTime == totalElapsedTime);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
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
            Field.asDouble(json['angular_distance_traveled']),
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
  }) : totalElapsedTime = totalElapsedTime ?? ros2.RosDuration();

  factory WaitResult.fromJson(Map<String, Object?> json) => WaitResult(
        totalElapsedTime: Field.asMessage(
            json['total_elapsed_time'], ros2.RosDuration.fromJson),
      );

  final ros2.RosDuration totalElapsedTime;

  @override
  String get rosType => 'nav2_msgs/msg/Wait_Result';

  @override
  Map<String, Object?> toJson() => {
        'total_elapsed_time': totalElapsedTime.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaitResult && other.totalElapsedTime == totalElapsedTime);

  @override
  int get hashCode => Object.hashAll([
        totalElapsedTime,
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
  MessageRegistry.register(const MessageCodec<EdgeCost>(
    rosType: 'nav2_msgs/msg/EdgeCost',
    fromJson: EdgeCost.fromJson,
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
  ActionRegistry.register(const ActionCodec<WaitGoal, WaitFeedback, WaitResult>(
    actionType: 'nav2_msgs/action/Wait',
    encodeGoal: _toJson,
    decodeFeedback: WaitFeedback.fromJson,
    decodeResult: WaitResult.fromJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
