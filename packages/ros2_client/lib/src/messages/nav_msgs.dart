import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'conversions.dart';
import 'geometry_msgs.dart';
import 'message.dart';
import 'std_msgs.dart';

/// `nav_msgs/msg/Odometry`.
@immutable
final class Odometry implements RosMessage {
  const Odometry({
    this.header = const Header(),
    this.childFrameId = '',
    this.pose = const Pose(),
    this.twist = const Twist(),
  });

  factory Odometry.fromJson(Map<String, Object?> json) => Odometry(
        header: Field.asMessage(json['header'], Header.fromJson),
        childFrameId: Field.asString(json['child_frame_id']),
        // pose and twist are wrapped in *WithCovariance in the real message.
        pose: Field.asMessage(
            (json['pose'] as Map<String, Object?>?)?['pose'], Pose.fromJson),
        twist: Field.asMessage(
            (json['twist'] as Map<String, Object?>?)?['twist'], Twist.fromJson),
      );

  final Header header;
  final String childFrameId;
  final Pose pose;
  final Twist twist;

  @override
  String get rosType => 'nav_msgs/msg/Odometry';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'child_frame_id': childFrameId,
        'pose': {'pose': pose.toJson(), 'covariance': List.filled(36, 0.0)},
        'twist': {'twist': twist.toJson(), 'covariance': List.filled(36, 0.0)},
      };

  @override
  String toString() => 'Odometry($pose, $twist)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Odometry &&
          other.header == header &&
          other.childFrameId == childFrameId &&
          other.pose == pose &&
          other.twist == twist);

  @override
  int get hashCode => Object.hash(
        header,
        childFrameId,
        pose,
        twist,
      );
}

/// `nav_msgs/msg/MapMetaData`.
@immutable
final class MapMetaData implements RosMessage {
  const MapMetaData({
    this.resolution = 0,
    this.width = 0,
    this.height = 0,
    this.origin = const Pose(),
  });

  factory MapMetaData.fromJson(Map<String, Object?> json) => MapMetaData(
        resolution: Field.asDouble(json['resolution']),
        width: Field.asInt(json['width']),
        height: Field.asInt(json['height']),
        origin: Field.asMessage(json['origin'], Pose.fromJson),
      );

  /// Metres per cell.
  final double resolution;
  final int width, height;
  final Pose origin;

  @override
  String get rosType => 'nav_msgs/msg/MapMetaData';

  @override
  Map<String, Object?> toJson() => {
        'resolution': resolution,
        'width': width,
        'height': height,
        'origin': origin.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapMetaData &&
          other.resolution == resolution &&
          other.width == width &&
          other.height == height &&
          other.origin == origin);

  @override
  int get hashCode => Object.hash(
        resolution,
        width,
        height,
        origin,
      );
}

/// `nav_msgs/msg/OccupancyGrid`.
@immutable
final class OccupancyGrid implements RosMessage {
  const OccupancyGrid({
    this.header = const Header(),
    this.info = const MapMetaData(),
    required this.data,
  });

  factory OccupancyGrid.fromJson(Map<String, Object?> json) => OccupancyGrid(
        header: Field.asMessage(json['header'], Header.fromJson),
        info: Field.asMessage(json['info'], MapMetaData.fromJson),
        data: Field.asInt8List(json['data']),
      );

  final Header header;
  final MapMetaData info;

  /// Occupancy in `0..100`, or -1 for unknown. Row-major from the origin.
  final Int8List data;

  /// Occupancy at grid cell (`col`, `row`), or `null` if out of bounds.
  int? at(int col, int row) {
    if (col < 0 || row < 0 || col >= info.width || row >= info.height) {
      return null;
    }
    return data[row * info.width + col];
  }

  @override
  String get rosType => 'nav_msgs/msg/OccupancyGrid';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'info': info.toJson(),
        'data': Field.encodeNumbers(data),
      };

  @override
  String toString() => 'OccupancyGrid(${info.width}x${info.height})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OccupancyGrid &&
          other.header == header &&
          other.info == info &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hash(
        header,
        info,
        Object.hashAll(data),
      );
}

/// `nav_msgs/msg/Path`.
@immutable
final class RosPath implements RosMessage {
  const RosPath({this.header = const Header(), this.poses = const []});

  factory RosPath.fromJson(Map<String, Object?> json) => RosPath(
        header: Field.asMessage(json['header'], Header.fromJson),
        poses: Field.asList(json['poses'], PoseStamped.fromJson),
      );

  final Header header;
  final List<PoseStamped> poses;

  @override
  String get rosType => 'nav_msgs/msg/Path';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'poses': poses.map((p) => p.toJson()).toList(),
      };

  @override
  String toString() => 'RosPath(${poses.length} poses)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RosPath &&
          other.header == header &&
          _listEquals(other.poses, poses));

  @override
  int get hashCode => Object.hash(
        header,
        Object.hashAll(poses),
      );
}

/// Registers every `nav_msgs` codec.
void registerNavMsgs() {
  MessageRegistry.register(const MessageCodec<Odometry>(
      rosType: 'nav_msgs/msg/Odometry',
      fromJson: Odometry.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<MapMetaData>(
      rosType: 'nav_msgs/msg/MapMetaData',
      fromJson: MapMetaData.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<OccupancyGrid>(
      rosType: 'nav_msgs/msg/OccupancyGrid',
      fromJson: OccupancyGrid.fromJson,
      toJson: _toJson));
  MessageRegistry.register(const MessageCodec<RosPath>(
      rosType: 'nav_msgs/msg/Path',
      fromJson: RosPath.fromJson,
      toJson: _toJson));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();

/// Element-wise comparison, so two structurally identical messages holding
/// separate typed-data buffers still compare equal.
bool _listEquals(List<Object?> a, List<Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
