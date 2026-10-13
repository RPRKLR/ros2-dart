// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package geographic_msgs

import 'dart:typed_data';

import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;
import 'unique_identifier_msgs.dart';

/// Geographic map bounding box.
///
/// The two GeoPoints denote diagonally opposite corners of the box.
///
/// If min_pt.latitude is NaN, the bounding box is "global", matching
/// any valid latitude, longitude and altitude.
///
/// If min_pt.altitude is NaN, the bounding box is two-dimensional and
/// matches any altitude within the specified latitude and longitude
/// range.
///
/// `geographic_msgs/msg/BoundingBox`
final class BoundingBox implements RosMessage {
  BoundingBox({
    GeoPoint? minPt,
    GeoPoint? maxPt,
  })  : minPt = minPt ?? GeoPoint(),
        maxPt = maxPt ?? GeoPoint();

  factory BoundingBox.fromJson(Map<String, Object?> json) => BoundingBox(
        minPt: Field.asMessage(json['min_pt'], GeoPoint.fromJson),
        maxPt: Field.asMessage(json['max_pt'], GeoPoint.fromJson),
      );

  /// lowest and most Southwestern corner
  final GeoPoint minPt;

  /// highest and most Northeastern corner
  final GeoPoint maxPt;

  @override
  String get rosType => 'geographic_msgs/msg/BoundingBox';

  @override
  Map<String, Object?> toJson() => {
        'min_pt': minPt.toJson(),
        'max_pt': maxPt.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoundingBox && other.minPt == minPt && other.maxPt == maxPt);

  @override
  int get hashCode => Object.hashAll([
        minPt,
        maxPt,
      ]);

  @override
  String toString() => 'BoundingBox(${toJson()})';
}

/// `geographic_msgs/msg/GeoPath`
final class GeoPath implements RosMessage {
  GeoPath({
    ros2.Header? header,
    this.poses = const [],
  }) : header = header ?? ros2.Header();

  factory GeoPath.fromJson(Map<String, Object?> json) => GeoPath(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        poses: Field.asList<GeoPoseStamped>(
            json['poses'], GeoPoseStamped.fromJson),
      );

  final ros2.Header header;
  final List<GeoPoseStamped> poses;

  @override
  String get rosType => 'geographic_msgs/msg/GeoPath';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'poses': poses.map((GeoPoseStamped e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoPath &&
          other.header == header &&
          _listEquals(other.poses, poses));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...poses,
      ]);

  @override
  String toString() => 'GeoPath(${toJson()})';
}

/// Geographic point, using the WGS 84 reference ellipsoid.
///
/// `geographic_msgs/msg/GeoPoint`
final class GeoPoint implements RosMessage {
  const GeoPoint({
    this.latitude = 0,
    this.longitude = 0,
    this.altitude = 0,
  });

  factory GeoPoint.fromJson(Map<String, Object?> json) => GeoPoint(
        latitude: Field.doubleAt(json, 'latitude'),
        longitude: Field.doubleAt(json, 'longitude'),
        altitude: Field.doubleAt(json, 'altitude'),
      );

  final double latitude;
  final double longitude;
  final double altitude;

  @override
  String get rosType => 'geographic_msgs/msg/GeoPoint';

  @override
  Map<String, Object?> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoPoint &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.altitude == altitude);

  @override
  int get hashCode => Object.hashAll([
        latitude,
        longitude,
        altitude,
      ]);

  @override
  String toString() => 'GeoPoint(${toJson()})';
}

/// `geographic_msgs/msg/GeoPointStamped`
final class GeoPointStamped implements RosMessage {
  GeoPointStamped({
    ros2.Header? header,
    GeoPoint? position,
  })  : header = header ?? ros2.Header(),
        position = position ?? GeoPoint();

  factory GeoPointStamped.fromJson(Map<String, Object?> json) =>
      GeoPointStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        position: Field.asMessage(json['position'], GeoPoint.fromJson),
      );

  final ros2.Header header;
  final GeoPoint position;

  @override
  String get rosType => 'geographic_msgs/msg/GeoPointStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'position': position.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoPointStamped &&
          other.header == header &&
          other.position == position);

  @override
  int get hashCode => Object.hashAll([
        header,
        position,
      ]);

  @override
  String toString() => 'GeoPointStamped(${toJson()})';
}

/// Geographic pose, using the WGS 84 reference ellipsoid.
///
/// Orientation uses the East-North-Up (ENU) frame of reference.
/// (But, what about singularities at the poles?)
///
/// `geographic_msgs/msg/GeoPose`
final class GeoPose implements RosMessage {
  GeoPose({
    GeoPoint? position,
    ros2.Quaternion? orientation,
  })  : position = position ?? GeoPoint(),
        orientation = orientation ?? ros2.Quaternion();

  factory GeoPose.fromJson(Map<String, Object?> json) => GeoPose(
        position: Field.asMessage(json['position'], GeoPoint.fromJson),
        orientation:
            Field.asMessage(json['orientation'], ros2.Quaternion.fromJson),
      );

  final GeoPoint position;
  final ros2.Quaternion orientation;

  @override
  String get rosType => 'geographic_msgs/msg/GeoPose';

  @override
  Map<String, Object?> toJson() => {
        'position': position.toJson(),
        'orientation': orientation.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoPose &&
          other.position == position &&
          other.orientation == orientation);

  @override
  int get hashCode => Object.hashAll([
        position,
        orientation,
      ]);

  @override
  String toString() => 'GeoPose(${toJson()})';
}

/// `geographic_msgs/msg/GeoPoseStamped`
final class GeoPoseStamped implements RosMessage {
  GeoPoseStamped({
    ros2.Header? header,
    GeoPose? pose,
  })  : header = header ?? ros2.Header(),
        pose = pose ?? GeoPose();

  factory GeoPoseStamped.fromJson(Map<String, Object?> json) => GeoPoseStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        pose: Field.asMessage(json['pose'], GeoPose.fromJson),
      );

  final ros2.Header header;
  final GeoPose pose;

  @override
  String get rosType => 'geographic_msgs/msg/GeoPoseStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'pose': pose.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoPoseStamped && other.header == header && other.pose == pose);

  @override
  int get hashCode => Object.hashAll([
        header,
        pose,
      ]);

  @override
  String toString() => 'GeoPoseStamped(${toJson()})';
}

/// Geographic pose, using the WGS 84 reference ellipsoid.
///
/// Orientation uses the East-North-Up (ENU) frame of reference.
/// (But, what about singularities at the poles?)
///
/// `geographic_msgs/msg/GeoPoseWithCovariance`
final class GeoPoseWithCovariance implements RosMessage {
  GeoPoseWithCovariance({
    GeoPose? pose,
    Float64List? covariance,
  })  : pose = pose ?? GeoPose(),
        covariance = covariance ?? Float64List(36);

  factory GeoPoseWithCovariance.fromJson(Map<String, Object?> json) =>
      GeoPoseWithCovariance(
        pose: Field.asMessage(json['pose'], GeoPose.fromJson),
        covariance: json['covariance'] == null
            ? null
            : Field.asFloat64List(json['covariance']),
      );

  final GeoPose pose;

  /// Fixed length: 36.
  final Float64List covariance;

  @override
  String get rosType => 'geographic_msgs/msg/GeoPoseWithCovariance';

  @override
  Map<String, Object?> toJson() => {
        'pose': pose.toJson(),
        'covariance': Field.encodeNumbers(covariance),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoPoseWithCovariance &&
          other.pose == pose &&
          _listEquals(other.covariance, covariance));

  @override
  int get hashCode => Object.hashAll([
        pose,
        ...covariance,
      ]);

  @override
  String toString() => 'GeoPoseWithCovariance(${toJson()})';
}

/// `geographic_msgs/msg/GeoPoseWithCovarianceStamped`
final class GeoPoseWithCovarianceStamped implements RosMessage {
  GeoPoseWithCovarianceStamped({
    ros2.Header? header,
    GeoPoseWithCovariance? pose,
  })  : header = header ?? ros2.Header(),
        pose = pose ?? GeoPoseWithCovariance();

  factory GeoPoseWithCovarianceStamped.fromJson(Map<String, Object?> json) =>
      GeoPoseWithCovarianceStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        pose: Field.asMessage(json['pose'], GeoPoseWithCovariance.fromJson),
      );

  final ros2.Header header;
  final GeoPoseWithCovariance pose;

  @override
  String get rosType => 'geographic_msgs/msg/GeoPoseWithCovarianceStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'pose': pose.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoPoseWithCovarianceStamped &&
          other.header == header &&
          other.pose == pose);

  @override
  int get hashCode => Object.hashAll([
        header,
        pose,
      ]);

  @override
  String toString() => 'GeoPoseWithCovarianceStamped(${toJson()})';
}

/// Geographic map for a specified region.
///
/// `geographic_msgs/msg/GeographicMap`
final class GeographicMap implements RosMessage {
  GeographicMap({
    ros2.Header? header,
    UUID? id,
    BoundingBox? bounds,
    this.points = const [],
    this.features = const [],
    this.props = const [],
  })  : header = header ?? ros2.Header(),
        id = id ?? UUID(),
        bounds = bounds ?? BoundingBox();

  factory GeographicMap.fromJson(Map<String, Object?> json) => GeographicMap(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        id: Field.asMessage(json['id'], UUID.fromJson),
        bounds: Field.asMessage(json['bounds'], BoundingBox.fromJson),
        points: Field.asList<WayPoint>(json['points'], WayPoint.fromJson),
        features:
            Field.asList<MapFeature>(json['features'], MapFeature.fromJson),
        props: Field.asList<KeyValue>(json['props'], KeyValue.fromJson),
      );

  /// stamp specifies time
  final ros2.Header header;

  /// identifier for this map
  final UUID id;

  /// 2D bounding box containing map
  final BoundingBox bounds;

  /// way-points
  final List<WayPoint> points;

  /// map features
  final List<MapFeature> features;

  /// map properties
  final List<KeyValue> props;

  @override
  String get rosType => 'geographic_msgs/msg/GeographicMap';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'id': id.toJson(),
        'bounds': bounds.toJson(),
        'points': points.map((WayPoint e) => e.toJson()).toList(),
        'features': features.map((MapFeature e) => e.toJson()).toList(),
        'props': props.map((KeyValue e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeographicMap &&
          other.header == header &&
          other.id == id &&
          other.bounds == bounds &&
          _listEquals(other.points, points) &&
          _listEquals(other.features, features) &&
          _listEquals(other.props, props));

  @override
  int get hashCode => Object.hashAll([
        header,
        id,
        bounds,
        ...points,
        ...features,
        ...props,
      ]);

  @override
  String toString() => 'GeographicMap(${toJson()})';
}

/// A list of geographic map changes.
///
/// `geographic_msgs/msg/GeographicMapChanges`
final class GeographicMapChanges implements RosMessage {
  GeographicMapChanges({
    ros2.Header? header,
    GeographicMap? diffs,
    this.deletes = const [],
  })  : header = header ?? ros2.Header(),
        diffs = diffs ?? GeographicMap();

  factory GeographicMapChanges.fromJson(Map<String, Object?> json) =>
      GeographicMapChanges(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        diffs: Field.asMessage(json['diffs'], GeographicMap.fromJson),
        deletes: Field.asList<UUID>(json['deletes'], UUID.fromJson),
      );

  /// stamp specifies time of change
  final ros2.Header header;

  /// new and changed points and features
  final GeographicMap diffs;

  /// deleted map components
  final List<UUID> deletes;

  @override
  String get rosType => 'geographic_msgs/msg/GeographicMapChanges';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'diffs': diffs.toJson(),
        'deletes': deletes.map((UUID e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeographicMapChanges &&
          other.header == header &&
          other.diffs == diffs &&
          _listEquals(other.deletes, deletes));

  @override
  int get hashCode => Object.hashAll([
        header,
        diffs,
        ...deletes,
      ]);

  @override
  String toString() => 'GeographicMapChanges(${toJson()})';
}

/// Geographic map tag (key, value) pair
///
/// This is equivalent to diagnostic_msgs/KeyValue, repeated here to
/// avoid introducing a trivial stack dependency.
///
/// `geographic_msgs/msg/KeyValue`
final class KeyValue implements RosMessage {
  const KeyValue({
    this.key = '',
    this.value = '',
  });

  factory KeyValue.fromJson(Map<String, Object?> json) => KeyValue(
        key: Field.stringAt(json, 'key'),
        value: Field.stringAt(json, 'value'),
      );

  /// tag label
  final String key;

  /// corresponding value
  final String value;

  @override
  String get rosType => 'geographic_msgs/msg/KeyValue';

  @override
  Map<String, Object?> toJson() => {
        'key': key,
        'value': value,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValue && other.key == key && other.value == value);

  @override
  int get hashCode => Object.hashAll([
        key,
        value,
      ]);

  @override
  String toString() => 'KeyValue(${toJson()})';
}

/// Geographic map feature.
///
/// A list of WayPoint IDs for features like streets, highways, hiking
/// trails, the outlines of buildings and parking lots in sequential
/// order.
///
/// Feature lists may also contain other feature lists as members.
///
/// `geographic_msgs/msg/MapFeature`
final class MapFeature implements RosMessage {
  MapFeature({
    UUID? id,
    this.components = const [],
    this.props = const [],
  }) : id = id ?? UUID();

  factory MapFeature.fromJson(Map<String, Object?> json) => MapFeature(
        id: Field.asMessage(json['id'], UUID.fromJson),
        components: Field.asList<UUID>(json['components'], UUID.fromJson),
        props: Field.asList<KeyValue>(json['props'], KeyValue.fromJson),
      );

  /// Unique feature identifier
  final UUID id;

  /// Sequence of feature components
  final List<UUID> components;

  /// Key/value properties for this feature
  final List<KeyValue> props;

  @override
  String get rosType => 'geographic_msgs/msg/MapFeature';

  @override
  Map<String, Object?> toJson() => {
        'id': id.toJson(),
        'components': components.map((UUID e) => e.toJson()).toList(),
        'props': props.map((KeyValue e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapFeature &&
          other.id == id &&
          _listEquals(other.components, components) &&
          _listEquals(other.props, props));

  @override
  int get hashCode => Object.hashAll([
        id,
        ...components,
        ...props,
      ]);

  @override
  String toString() => 'MapFeature(${toJson()})';
}

/// Geographic map route network.
///
/// A directed graph of WayPoint nodes and RouteSegment edges.  This
/// information is extracted from the more-detailed contents of a
/// GeographicMap.  A RouteNetwork contains only the way points and
/// route segments of interest for path planning.
///
/// `geographic_msgs/msg/RouteNetwork`
final class RouteNetwork implements RosMessage {
  RouteNetwork({
    ros2.Header? header,
    UUID? id,
    BoundingBox? bounds,
    this.points = const [],
    this.segments = const [],
    this.props = const [],
  })  : header = header ?? ros2.Header(),
        id = id ?? UUID(),
        bounds = bounds ?? BoundingBox();

  factory RouteNetwork.fromJson(Map<String, Object?> json) => RouteNetwork(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        id: Field.asMessage(json['id'], UUID.fromJson),
        bounds: Field.asMessage(json['bounds'], BoundingBox.fromJson),
        points: Field.asList<WayPoint>(json['points'], WayPoint.fromJson),
        segments:
            Field.asList<RouteSegment>(json['segments'], RouteSegment.fromJson),
        props: Field.asList<KeyValue>(json['props'], KeyValue.fromJson),
      );

  final ros2.Header header;

  /// This route network identifier
  final UUID id;

  /// 2D bounding box for network
  final BoundingBox bounds;

  /// Way points in this network
  final List<WayPoint> points;

  /// Directed edges of this network
  final List<RouteSegment> segments;

  /// Network key/value properties
  final List<KeyValue> props;

  @override
  String get rosType => 'geographic_msgs/msg/RouteNetwork';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'id': id.toJson(),
        'bounds': bounds.toJson(),
        'points': points.map((WayPoint e) => e.toJson()).toList(),
        'segments': segments.map((RouteSegment e) => e.toJson()).toList(),
        'props': props.map((KeyValue e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteNetwork &&
          other.header == header &&
          other.id == id &&
          other.bounds == bounds &&
          _listEquals(other.points, points) &&
          _listEquals(other.segments, segments) &&
          _listEquals(other.props, props));

  @override
  int get hashCode => Object.hashAll([
        header,
        id,
        bounds,
        ...points,
        ...segments,
        ...props,
      ]);

  @override
  String toString() => 'RouteNetwork(${toJson()})';
}

/// Path through a route network.
///
/// A path is a sequence of RouteSegment edges.  This information is
/// extracted from a RouteNetwork graph.  A RoutePath lists the route
/// segments needed to reach some chosen goal.
///
/// `geographic_msgs/msg/RoutePath`
final class RoutePath implements RosMessage {
  RoutePath({
    ros2.Header? header,
    UUID? network,
    this.segments = const [],
    this.props = const [],
  })  : header = header ?? ros2.Header(),
        network = network ?? UUID();

  factory RoutePath.fromJson(Map<String, Object?> json) => RoutePath(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        network: Field.asMessage(json['network'], UUID.fromJson),
        segments: Field.asList<UUID>(json['segments'], UUID.fromJson),
        props: Field.asList<KeyValue>(json['props'], KeyValue.fromJson),
      );

  final ros2.Header header;

  /// Route network containing this path
  final UUID network;

  /// Sequence of RouteSegment IDs
  final List<UUID> segments;

  /// Key/value properties
  final List<KeyValue> props;

  @override
  String get rosType => 'geographic_msgs/msg/RoutePath';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'network': network.toJson(),
        'segments': segments.map((UUID e) => e.toJson()).toList(),
        'props': props.map((KeyValue e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutePath &&
          other.header == header &&
          other.network == network &&
          _listEquals(other.segments, segments) &&
          _listEquals(other.props, props));

  @override
  int get hashCode => Object.hashAll([
        header,
        network,
        ...segments,
        ...props,
      ]);

  @override
  String toString() => 'RoutePath(${toJson()})';
}

/// Route network segment.
///
/// This is one directed edge of a RouteNetwork graph. It represents a
/// known path from one way point to another.  If the path is two-way,
/// there will be another RouteSegment with "start" and "end" reversed.
///
/// `geographic_msgs/msg/RouteSegment`
final class RouteSegment implements RosMessage {
  RouteSegment({
    UUID? id,
    UUID? start,
    UUID? end,
    this.props = const [],
  })  : id = id ?? UUID(),
        start = start ?? UUID(),
        end = end ?? UUID();

  factory RouteSegment.fromJson(Map<String, Object?> json) => RouteSegment(
        id: Field.asMessage(json['id'], UUID.fromJson),
        start: Field.asMessage(json['start'], UUID.fromJson),
        end: Field.asMessage(json['end'], UUID.fromJson),
        props: Field.asList<KeyValue>(json['props'], KeyValue.fromJson),
      );

  /// Unique identifier for this segment
  final UUID id;

  /// beginning way point of segment
  final UUID start;

  /// ending way point of segment
  final UUID end;

  /// segment properties
  final List<KeyValue> props;

  @override
  String get rosType => 'geographic_msgs/msg/RouteSegment';

  @override
  Map<String, Object?> toJson() => {
        'id': id.toJson(),
        'start': start.toJson(),
        'end': end.toJson(),
        'props': props.map((KeyValue e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteSegment &&
          other.id == id &&
          other.start == start &&
          other.end == end &&
          _listEquals(other.props, props));

  @override
  int get hashCode => Object.hashAll([
        id,
        start,
        end,
        ...props,
      ]);

  @override
  String toString() => 'RouteSegment(${toJson()})';
}

/// Way-point element for a geographic map.
///
/// `geographic_msgs/msg/WayPoint`
final class WayPoint implements RosMessage {
  WayPoint({
    UUID? id,
    GeoPoint? position,
    this.props = const [],
  })  : id = id ?? UUID(),
        position = position ?? GeoPoint();

  factory WayPoint.fromJson(Map<String, Object?> json) => WayPoint(
        id: Field.asMessage(json['id'], UUID.fromJson),
        position: Field.asMessage(json['position'], GeoPoint.fromJson),
        props: Field.asList<KeyValue>(json['props'], KeyValue.fromJson),
      );

  /// Unique way-point identifier
  final UUID id;

  /// Position relative to WGS 84 ellipsoid
  final GeoPoint position;

  /// Key/value properties for this point
  final List<KeyValue> props;

  @override
  String get rosType => 'geographic_msgs/msg/WayPoint';

  @override
  Map<String, Object?> toJson() => {
        'id': id.toJson(),
        'position': position.toJson(),
        'props': props.map((KeyValue e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WayPoint &&
          other.id == id &&
          other.position == position &&
          _listEquals(other.props, props));

  @override
  int get hashCode => Object.hashAll([
        id,
        position,
        ...props,
      ]);

  @override
  String toString() => 'WayPoint(${toJson()})';
}

/// Searches for given start and goal the nearest route segments
/// and determine the path through the RouteNetwork
///
/// `geographic_msgs/msg/GetGeoPath_Request`
final class GetGeoPathRequest implements RosMessage {
  GetGeoPathRequest({
    GeoPoint? start,
    GeoPoint? goal,
  })  : start = start ?? GeoPoint(),
        goal = goal ?? GeoPoint();

  factory GetGeoPathRequest.fromJson(Map<String, Object?> json) =>
      GetGeoPathRequest(
        start: Field.asMessage(json['start'], GeoPoint.fromJson),
        goal: Field.asMessage(json['goal'], GeoPoint.fromJson),
      );

  /// starting point
  final GeoPoint start;

  /// goal point
  final GeoPoint goal;

  @override
  String get rosType => 'geographic_msgs/msg/GetGeoPath_Request';

  @override
  Map<String, Object?> toJson() => {
        'start': start.toJson(),
        'goal': goal.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetGeoPathRequest &&
          other.start == start &&
          other.goal == goal);

  @override
  int get hashCode => Object.hashAll([
        start,
        goal,
      ]);

  @override
  String toString() => 'GetGeoPathRequest(${toJson()})';
}

/// `geographic_msgs/msg/GetGeoPath_Response`
final class GetGeoPathResponse implements RosMessage {
  GetGeoPathResponse({
    this.success = false,
    this.status = '',
    GeoPath? plan,
    UUID? network,
    UUID? startSeg,
    UUID? goalSeg,
    this.distance = 0,
  })  : plan = plan ?? GeoPath(),
        network = network ?? UUID(),
        startSeg = startSeg ?? UUID(),
        goalSeg = goalSeg ?? UUID();

  factory GetGeoPathResponse.fromJson(Map<String, Object?> json) =>
      GetGeoPathResponse(
        success: Field.boolAt(json, 'success'),
        status: Field.stringAt(json, 'status'),
        plan: Field.asMessage(json['plan'], GeoPath.fromJson),
        network: Field.asMessage(json['network'], UUID.fromJson),
        startSeg: Field.asMessage(json['start_seg'], UUID.fromJson),
        goalSeg: Field.asMessage(json['goal_seg'], UUID.fromJson),
        distance: Field.doubleAt(json, 'distance'),
      );

  /// true if the call succeeded
  final bool success;

  /// more details
  final String status;

  /// path to follow
  final GeoPath plan;

  /// the uuid of the RouteNetwork
  final UUID network;

  /// the uuid of the starting RouteSegment
  final UUID startSeg;

  /// the uuid of the ending RouteSegment
  final UUID goalSeg;

  /// the length of the plan
  final double distance;

  @override
  String get rosType => 'geographic_msgs/msg/GetGeoPath_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
        'status': status,
        'plan': plan.toJson(),
        'network': network.toJson(),
        'start_seg': startSeg.toJson(),
        'goal_seg': goalSeg.toJson(),
        'distance': distance,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetGeoPathResponse &&
          other.success == success &&
          other.status == status &&
          other.plan == plan &&
          other.network == network &&
          other.startSeg == startSeg &&
          other.goalSeg == goalSeg &&
          other.distance == distance);

  @override
  int get hashCode => Object.hashAll([
        success,
        status,
        plan,
        network,
        startSeg,
        goalSeg,
        distance,
      ]);

  @override
  String toString() => 'GetGeoPathResponse(${toJson()})';
}

/// This service requests a region of a geographic map.
///
/// `geographic_msgs/msg/GetGeographicMap_Request`
final class GetGeographicMapRequest implements RosMessage {
  GetGeographicMapRequest({
    this.url = '',
    BoundingBox? bounds,
  }) : bounds = bounds ?? BoundingBox();

  factory GetGeographicMapRequest.fromJson(Map<String, Object?> json) =>
      GetGeographicMapRequest(
        url: Field.stringAt(json, 'url'),
        bounds: Field.asMessage(json['bounds'], BoundingBox.fromJson),
      );

  /// where to read map data
  final String url;
  final BoundingBox bounds;

  @override
  String get rosType => 'geographic_msgs/msg/GetGeographicMap_Request';

  @override
  Map<String, Object?> toJson() => {
        'url': url,
        'bounds': bounds.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetGeographicMapRequest &&
          other.url == url &&
          other.bounds == bounds);

  @override
  int get hashCode => Object.hashAll([
        url,
        bounds,
      ]);

  @override
  String toString() => 'GetGeographicMapRequest(${toJson()})';
}

/// `geographic_msgs/msg/GetGeographicMap_Response`
final class GetGeographicMapResponse implements RosMessage {
  GetGeographicMapResponse({
    this.success = false,
    this.status = '',
    GeographicMap? map,
  }) : map = map ?? GeographicMap();

  factory GetGeographicMapResponse.fromJson(Map<String, Object?> json) =>
      GetGeographicMapResponse(
        success: Field.boolAt(json, 'success'),
        status: Field.stringAt(json, 'status'),
        map: Field.asMessage(json['map'], GeographicMap.fromJson),
      );

  /// true if the call succeeded
  final bool success;

  /// more details
  final String status;
  final GeographicMap map;

  @override
  String get rosType => 'geographic_msgs/msg/GetGeographicMap_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
        'status': status,
        'map': map.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetGeographicMapResponse &&
          other.success == success &&
          other.status == status &&
          other.map == map);

  @override
  int get hashCode => Object.hashAll([
        success,
        status,
        map,
      ]);

  @override
  String toString() => 'GetGeographicMapResponse(${toJson()})';
}

/// Get a plan to traverse a route network from start to goal.
///
/// Similar to nav_msgs/GetPlan, but constrained to use the route network.
///
/// `geographic_msgs/msg/GetRoutePlan_Request`
final class GetRoutePlanRequest implements RosMessage {
  GetRoutePlanRequest({
    UUID? network,
    UUID? start,
    UUID? goal,
  })  : network = network ?? UUID(),
        start = start ?? UUID(),
        goal = goal ?? UUID();

  factory GetRoutePlanRequest.fromJson(Map<String, Object?> json) =>
      GetRoutePlanRequest(
        network: Field.asMessage(json['network'], UUID.fromJson),
        start: Field.asMessage(json['start'], UUID.fromJson),
        goal: Field.asMessage(json['goal'], UUID.fromJson),
      );

  /// route network to use
  final UUID network;

  /// starting way point
  final UUID start;

  /// goal way point
  final UUID goal;

  @override
  String get rosType => 'geographic_msgs/msg/GetRoutePlan_Request';

  @override
  Map<String, Object?> toJson() => {
        'network': network.toJson(),
        'start': start.toJson(),
        'goal': goal.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetRoutePlanRequest &&
          other.network == network &&
          other.start == start &&
          other.goal == goal);

  @override
  int get hashCode => Object.hashAll([
        network,
        start,
        goal,
      ]);

  @override
  String toString() => 'GetRoutePlanRequest(${toJson()})';
}

/// `geographic_msgs/msg/GetRoutePlan_Response`
final class GetRoutePlanResponse implements RosMessage {
  GetRoutePlanResponse({
    this.success = false,
    this.status = '',
    RoutePath? plan,
  }) : plan = plan ?? RoutePath();

  factory GetRoutePlanResponse.fromJson(Map<String, Object?> json) =>
      GetRoutePlanResponse(
        success: Field.boolAt(json, 'success'),
        status: Field.stringAt(json, 'status'),
        plan: Field.asMessage(json['plan'], RoutePath.fromJson),
      );

  /// true if the call succeeded
  final bool success;

  /// more details
  final String status;

  /// path to follow
  final RoutePath plan;

  @override
  String get rosType => 'geographic_msgs/msg/GetRoutePlan_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
        'status': status,
        'plan': plan.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetRoutePlanResponse &&
          other.success == success &&
          other.status == status &&
          other.plan == plan);

  @override
  int get hashCode => Object.hashAll([
        success,
        status,
        plan,
      ]);

  @override
  String toString() => 'GetRoutePlanResponse(${toJson()})';
}

/// This service updates a geographic map.
///
/// `geographic_msgs/msg/UpdateGeographicMap_Request`
final class UpdateGeographicMapRequest implements RosMessage {
  UpdateGeographicMapRequest({
    GeographicMapChanges? updates,
  }) : updates = updates ?? GeographicMapChanges();

  factory UpdateGeographicMapRequest.fromJson(Map<String, Object?> json) =>
      UpdateGeographicMapRequest(
        updates:
            Field.asMessage(json['updates'], GeographicMapChanges.fromJson),
      );

  final GeographicMapChanges updates;

  @override
  String get rosType => 'geographic_msgs/msg/UpdateGeographicMap_Request';

  @override
  Map<String, Object?> toJson() => {
        'updates': updates.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UpdateGeographicMapRequest && other.updates == updates);

  @override
  int get hashCode => Object.hashAll([
        updates,
      ]);

  @override
  String toString() => 'UpdateGeographicMapRequest(${toJson()})';
}

/// `geographic_msgs/msg/UpdateGeographicMap_Response`
final class UpdateGeographicMapResponse implements RosMessage {
  const UpdateGeographicMapResponse({
    this.success = false,
    this.status = '',
  });

  factory UpdateGeographicMapResponse.fromJson(Map<String, Object?> json) =>
      UpdateGeographicMapResponse(
        success: Field.boolAt(json, 'success'),
        status: Field.stringAt(json, 'status'),
      );

  /// true if the call succeeded
  final bool success;

  /// more details
  final String status;

  @override
  String get rosType => 'geographic_msgs/msg/UpdateGeographicMap_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
        'status': status,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UpdateGeographicMapResponse &&
          other.success == success &&
          other.status == status);

  @override
  int get hashCode => Object.hashAll([
        success,
        status,
      ]);

  @override
  String toString() => 'UpdateGeographicMapResponse(${toJson()})';
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

/// Registers every message in `geographic_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerGeographicMsgs() {
  MessageRegistry.register(const MessageCodec<BoundingBox>(
    rosType: 'geographic_msgs/msg/BoundingBox',
    fromJson: BoundingBox.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GeoPath>(
    rosType: 'geographic_msgs/msg/GeoPath',
    fromJson: GeoPath.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GeoPoint>(
    rosType: 'geographic_msgs/msg/GeoPoint',
    fromJson: GeoPoint.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GeoPointStamped>(
    rosType: 'geographic_msgs/msg/GeoPointStamped',
    fromJson: GeoPointStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GeoPose>(
    rosType: 'geographic_msgs/msg/GeoPose',
    fromJson: GeoPose.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GeoPoseStamped>(
    rosType: 'geographic_msgs/msg/GeoPoseStamped',
    fromJson: GeoPoseStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GeoPoseWithCovariance>(
    rosType: 'geographic_msgs/msg/GeoPoseWithCovariance',
    fromJson: GeoPoseWithCovariance.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GeoPoseWithCovarianceStamped>(
    rosType: 'geographic_msgs/msg/GeoPoseWithCovarianceStamped',
    fromJson: GeoPoseWithCovarianceStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GeographicMap>(
    rosType: 'geographic_msgs/msg/GeographicMap',
    fromJson: GeographicMap.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GeographicMapChanges>(
    rosType: 'geographic_msgs/msg/GeographicMapChanges',
    fromJson: GeographicMapChanges.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<KeyValue>(
    rosType: 'geographic_msgs/msg/KeyValue',
    fromJson: KeyValue.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MapFeature>(
    rosType: 'geographic_msgs/msg/MapFeature',
    fromJson: MapFeature.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<RouteNetwork>(
    rosType: 'geographic_msgs/msg/RouteNetwork',
    fromJson: RouteNetwork.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<RoutePath>(
    rosType: 'geographic_msgs/msg/RoutePath',
    fromJson: RoutePath.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<RouteSegment>(
    rosType: 'geographic_msgs/msg/RouteSegment',
    fromJson: RouteSegment.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<WayPoint>(
    rosType: 'geographic_msgs/msg/WayPoint',
    fromJson: WayPoint.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetGeoPathRequest>(
    rosType: 'geographic_msgs/msg/GetGeoPath_Request',
    fromJson: GetGeoPathRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetGeoPathResponse>(
    rosType: 'geographic_msgs/msg/GetGeoPath_Response',
    fromJson: GetGeoPathResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetGeographicMapRequest>(
    rosType: 'geographic_msgs/msg/GetGeographicMap_Request',
    fromJson: GetGeographicMapRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetGeographicMapResponse>(
    rosType: 'geographic_msgs/msg/GetGeographicMap_Response',
    fromJson: GetGeographicMapResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetRoutePlanRequest>(
    rosType: 'geographic_msgs/msg/GetRoutePlan_Request',
    fromJson: GetRoutePlanRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetRoutePlanResponse>(
    rosType: 'geographic_msgs/msg/GetRoutePlan_Response',
    fromJson: GetRoutePlanResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UpdateGeographicMapRequest>(
    rosType: 'geographic_msgs/msg/UpdateGeographicMap_Request',
    fromJson: UpdateGeographicMapRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UpdateGeographicMapResponse>(
    rosType: 'geographic_msgs/msg/UpdateGeographicMap_Response',
    fromJson: UpdateGeographicMapResponse.fromJson,
    toJson: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<GetGeoPathRequest, GetGeoPathResponse>(
    serviceType: 'geographic_msgs/srv/GetGeoPath',
    encodeRequest: _toJson,
    decodeResponse: GetGeoPathResponse.fromJson,
    decodeRequest: GetGeoPathRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<GetGeographicMapRequest, GetGeographicMapResponse>(
    serviceType: 'geographic_msgs/srv/GetGeographicMap',
    encodeRequest: _toJson,
    decodeResponse: GetGeographicMapResponse.fromJson,
    decodeRequest: GetGeographicMapRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<GetRoutePlanRequest, GetRoutePlanResponse>(
    serviceType: 'geographic_msgs/srv/GetRoutePlan',
    encodeRequest: _toJson,
    decodeResponse: GetRoutePlanResponse.fromJson,
    decodeRequest: GetRoutePlanRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<UpdateGeographicMapRequest,
      UpdateGeographicMapResponse>(
    serviceType: 'geographic_msgs/srv/UpdateGeographicMap',
    encodeRequest: _toJson,
    decodeResponse: UpdateGeographicMapResponse.fromJson,
    decodeRequest: UpdateGeographicMapRequest.fromJson,
    encodeResponse: _toJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
