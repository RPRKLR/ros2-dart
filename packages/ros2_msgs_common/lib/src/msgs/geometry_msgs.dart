// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package geometry_msgs

import 'dart:typed_data';

import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;

/// This expresses acceleration in free space broken into its linear and angular parts.
///
/// `geometry_msgs/msg/Accel`
final class Accel implements RosMessage {
  Accel({
    ros2.Vector3? linear,
    ros2.Vector3? angular,
  })  : linear = linear ?? ros2.Vector3(),
        angular = angular ?? ros2.Vector3();

  factory Accel.fromJson(Map<String, Object?> json) => Accel(
        linear: Field.asMessage(json['linear'], ros2.Vector3.fromJson),
        angular: Field.asMessage(json['angular'], ros2.Vector3.fromJson),
      );

  final ros2.Vector3 linear;
  final ros2.Vector3 angular;

  @override
  String get rosType => 'geometry_msgs/msg/Accel';

  @override
  Map<String, Object?> toJson() => {
        'linear': linear.toJson(),
        'angular': angular.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Accel && other.linear == linear && other.angular == angular);

  @override
  int get hashCode => Object.hashAll([
        linear,
        angular,
      ]);

  @override
  String toString() => 'Accel(${toJson()})';
}

/// An accel with reference coordinate frame and timestamp
///
/// `geometry_msgs/msg/AccelStamped`
final class AccelStamped implements RosMessage {
  AccelStamped({
    ros2.Header? header,
    Accel? accel,
  })  : header = header ?? ros2.Header(),
        accel = accel ?? Accel();

  factory AccelStamped.fromJson(Map<String, Object?> json) => AccelStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        accel: Field.asMessage(json['accel'], Accel.fromJson),
      );

  final ros2.Header header;
  final Accel accel;

  @override
  String get rosType => 'geometry_msgs/msg/AccelStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'accel': accel.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccelStamped && other.header == header && other.accel == accel);

  @override
  int get hashCode => Object.hashAll([
        header,
        accel,
      ]);

  @override
  String toString() => 'AccelStamped(${toJson()})';
}

/// This expresses acceleration in free space with uncertainty.
///
/// `geometry_msgs/msg/AccelWithCovariance`
final class AccelWithCovariance implements RosMessage {
  AccelWithCovariance({
    Accel? accel,
    Float64List? covariance,
  })  : accel = accel ?? Accel(),
        covariance = covariance ?? Float64List(0);

  factory AccelWithCovariance.fromJson(Map<String, Object?> json) =>
      AccelWithCovariance(
        accel: Field.asMessage(json['accel'], Accel.fromJson),
        covariance: Field.asFloat64List(json['covariance']),
      );

  final Accel accel;

  /// Fixed length: 36.
  final Float64List covariance;

  @override
  String get rosType => 'geometry_msgs/msg/AccelWithCovariance';

  @override
  Map<String, Object?> toJson() => {
        'accel': accel.toJson(),
        'covariance': Field.encodeNumbers(covariance),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccelWithCovariance &&
          other.accel == accel &&
          _listEquals(other.covariance, covariance));

  @override
  int get hashCode => Object.hashAll([
        accel,
        ...covariance,
      ]);

  @override
  String toString() => 'AccelWithCovariance(${toJson()})';
}

/// This represents an estimated accel with reference coordinate frame and timestamp.
///
/// `geometry_msgs/msg/AccelWithCovarianceStamped`
final class AccelWithCovarianceStamped implements RosMessage {
  AccelWithCovarianceStamped({
    ros2.Header? header,
    AccelWithCovariance? accel,
  })  : header = header ?? ros2.Header(),
        accel = accel ?? AccelWithCovariance();

  factory AccelWithCovarianceStamped.fromJson(Map<String, Object?> json) =>
      AccelWithCovarianceStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        accel: Field.asMessage(json['accel'], AccelWithCovariance.fromJson),
      );

  final ros2.Header header;
  final AccelWithCovariance accel;

  @override
  String get rosType => 'geometry_msgs/msg/AccelWithCovarianceStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'accel': accel.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccelWithCovarianceStamped &&
          other.header == header &&
          other.accel == accel);

  @override
  int get hashCode => Object.hashAll([
        header,
        accel,
      ]);

  @override
  String toString() => 'AccelWithCovarianceStamped(${toJson()})';
}

/// Mass [kg]
///
/// `geometry_msgs/msg/Inertia`
final class Inertia implements RosMessage {
  Inertia({
    this.m = 0,
    ros2.Vector3? com,
    this.ixx = 0,
    this.ixy = 0,
    this.ixz = 0,
    this.iyy = 0,
    this.iyz = 0,
    this.izz = 0,
  }) : com = com ?? ros2.Vector3();

  factory Inertia.fromJson(Map<String, Object?> json) => Inertia(
        m: Field.asDouble(json['m']),
        com: Field.asMessage(json['com'], ros2.Vector3.fromJson),
        ixx: Field.asDouble(json['ixx']),
        ixy: Field.asDouble(json['ixy']),
        ixz: Field.asDouble(json['ixz']),
        iyy: Field.asDouble(json['iyy']),
        iyz: Field.asDouble(json['iyz']),
        izz: Field.asDouble(json['izz']),
      );

  final double m;
  final ros2.Vector3 com;
  final double ixx;
  final double ixy;
  final double ixz;
  final double iyy;
  final double iyz;
  final double izz;

  @override
  String get rosType => 'geometry_msgs/msg/Inertia';

  @override
  Map<String, Object?> toJson() => {
        'm': m,
        'com': com.toJson(),
        'ixx': ixx,
        'ixy': ixy,
        'ixz': ixz,
        'iyy': iyy,
        'iyz': iyz,
        'izz': izz,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Inertia &&
          other.m == m &&
          other.com == com &&
          other.ixx == ixx &&
          other.ixy == ixy &&
          other.ixz == ixz &&
          other.iyy == iyy &&
          other.iyz == iyz &&
          other.izz == izz);

  @override
  int get hashCode => Object.hashAll([
        m,
        com,
        ixx,
        ixy,
        ixz,
        iyy,
        iyz,
        izz,
      ]);

  @override
  String toString() => 'Inertia(${toJson()})';
}

/// An Inertia with a time stamp and reference frame.
///
/// `geometry_msgs/msg/InertiaStamped`
final class InertiaStamped implements RosMessage {
  InertiaStamped({
    ros2.Header? header,
    Inertia? inertia,
  })  : header = header ?? ros2.Header(),
        inertia = inertia ?? Inertia();

  factory InertiaStamped.fromJson(Map<String, Object?> json) => InertiaStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        inertia: Field.asMessage(json['inertia'], Inertia.fromJson),
      );

  final ros2.Header header;
  final Inertia inertia;

  @override
  String get rosType => 'geometry_msgs/msg/InertiaStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'inertia': inertia.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InertiaStamped &&
          other.header == header &&
          other.inertia == inertia);

  @override
  int get hashCode => Object.hashAll([
        header,
        inertia,
      ]);

  @override
  String toString() => 'InertiaStamped(${toJson()})';
}

/// This contains the position of a point in free space(with 32 bits of precision).
/// It is recommended to use Point wherever possible instead of Point32.
///
/// This recommendation is to promote interoperability.
///
/// This message is designed to take up less space when sending
/// lots of points at once, as in the case of a PointCloud.
///
/// `geometry_msgs/msg/Point32`
final class Point32 implements RosMessage {
  const Point32({
    this.x = 0,
    this.y = 0,
    this.z = 0,
  });

  factory Point32.fromJson(Map<String, Object?> json) => Point32(
        x: Field.asDouble(json['x']),
        y: Field.asDouble(json['y']),
        z: Field.asDouble(json['z']),
      );

  final double x;
  final double y;
  final double z;

  @override
  String get rosType => 'geometry_msgs/msg/Point32';

  @override
  Map<String, Object?> toJson() => {
        'x': x,
        'y': y,
        'z': z,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Point32 && other.x == x && other.y == y && other.z == z);

  @override
  int get hashCode => Object.hashAll([
        x,
        y,
        z,
      ]);

  @override
  String toString() => 'Point32(${toJson()})';
}

/// This represents a Point with reference coordinate frame and timestamp
///
/// `geometry_msgs/msg/PointStamped`
final class PointStamped implements RosMessage {
  PointStamped({
    ros2.Header? header,
    ros2.Point? point,
  })  : header = header ?? ros2.Header(),
        point = point ?? ros2.Point();

  factory PointStamped.fromJson(Map<String, Object?> json) => PointStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        point: Field.asMessage(json['point'], ros2.Point.fromJson),
      );

  final ros2.Header header;
  final ros2.Point point;

  @override
  String get rosType => 'geometry_msgs/msg/PointStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'point': point.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PointStamped && other.header == header && other.point == point);

  @override
  int get hashCode => Object.hashAll([
        header,
        point,
      ]);

  @override
  String toString() => 'PointStamped(${toJson()})';
}

/// A specification of a polygon where the first and last points are assumed to be connected
///
/// `geometry_msgs/msg/Polygon`
final class Polygon implements RosMessage {
  const Polygon({
    this.points = const [],
  });

  factory Polygon.fromJson(Map<String, Object?> json) => Polygon(
        points: Field.asList<Point32>(json['points'], Point32.fromJson),
      );

  final List<Point32> points;

  @override
  String get rosType => 'geometry_msgs/msg/Polygon';

  @override
  Map<String, Object?> toJson() => {
        'points': points.map((Point32 e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Polygon && _listEquals(other.points, points));

  @override
  int get hashCode => Object.hashAll([
        ...points,
      ]);

  @override
  String toString() => 'Polygon(${toJson()})';
}

/// A specification of a polygon where the first and last points are assumed to be connected
/// It includes a unique identification field for disambiguating multiple instances
///
/// `geometry_msgs/msg/PolygonInstance`
final class PolygonInstance implements RosMessage {
  PolygonInstance({
    Polygon? polygon,
    this.id = 0,
  }) : polygon = polygon ?? Polygon();

  factory PolygonInstance.fromJson(Map<String, Object?> json) =>
      PolygonInstance(
        polygon: Field.asMessage(json['polygon'], Polygon.fromJson),
        id: Field.asInt(json['id']),
      );

  final Polygon polygon;
  final int id;

  @override
  String get rosType => 'geometry_msgs/msg/PolygonInstance';

  @override
  Map<String, Object?> toJson() => {
        'polygon': polygon.toJson(),
        'id': id,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PolygonInstance && other.polygon == polygon && other.id == id);

  @override
  int get hashCode => Object.hashAll([
        polygon,
        id,
      ]);

  @override
  String toString() => 'PolygonInstance(${toJson()})';
}

/// This represents a Polygon with reference coordinate frame and timestamp
/// It includes a unique identification field for disambiguating multiple instances
///
/// `geometry_msgs/msg/PolygonInstanceStamped`
final class PolygonInstanceStamped implements RosMessage {
  PolygonInstanceStamped({
    ros2.Header? header,
    PolygonInstance? polygon,
  })  : header = header ?? ros2.Header(),
        polygon = polygon ?? PolygonInstance();

  factory PolygonInstanceStamped.fromJson(Map<String, Object?> json) =>
      PolygonInstanceStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        polygon: Field.asMessage(json['polygon'], PolygonInstance.fromJson),
      );

  final ros2.Header header;
  final PolygonInstance polygon;

  @override
  String get rosType => 'geometry_msgs/msg/PolygonInstanceStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'polygon': polygon.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PolygonInstanceStamped &&
          other.header == header &&
          other.polygon == polygon);

  @override
  int get hashCode => Object.hashAll([
        header,
        polygon,
      ]);

  @override
  String toString() => 'PolygonInstanceStamped(${toJson()})';
}

/// This represents a Polygon with reference coordinate frame and timestamp
///
/// `geometry_msgs/msg/PolygonStamped`
final class PolygonStamped implements RosMessage {
  PolygonStamped({
    ros2.Header? header,
    Polygon? polygon,
  })  : header = header ?? ros2.Header(),
        polygon = polygon ?? Polygon();

  factory PolygonStamped.fromJson(Map<String, Object?> json) => PolygonStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        polygon: Field.asMessage(json['polygon'], Polygon.fromJson),
      );

  final ros2.Header header;
  final Polygon polygon;

  @override
  String get rosType => 'geometry_msgs/msg/PolygonStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'polygon': polygon.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PolygonStamped &&
          other.header == header &&
          other.polygon == polygon);

  @override
  int get hashCode => Object.hashAll([
        header,
        polygon,
      ]);

  @override
  String toString() => 'PolygonStamped(${toJson()})';
}

/// Deprecated as of Foxy and will potentially be removed in any following release.
/// Please use the full 3D pose.
///
/// `geometry_msgs/msg/Pose2D`
final class Pose2D implements RosMessage {
  const Pose2D({
    this.x = 0,
    this.y = 0,
    this.theta = 0,
  });

  factory Pose2D.fromJson(Map<String, Object?> json) => Pose2D(
        x: Field.asDouble(json['x']),
        y: Field.asDouble(json['y']),
        theta: Field.asDouble(json['theta']),
      );

  final double x;
  final double y;
  final double theta;

  @override
  String get rosType => 'geometry_msgs/msg/Pose2D';

  @override
  Map<String, Object?> toJson() => {
        'x': x,
        'y': y,
        'theta': theta,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pose2D && other.x == x && other.y == y && other.theta == theta);

  @override
  int get hashCode => Object.hashAll([
        x,
        y,
        theta,
      ]);

  @override
  String toString() => 'Pose2D(${toJson()})';
}

/// An array of poses with a header for global reference.
///
/// `geometry_msgs/msg/PoseArray`
final class PoseArray implements RosMessage {
  PoseArray({
    ros2.Header? header,
    this.poses = const [],
  }) : header = header ?? ros2.Header();

  factory PoseArray.fromJson(Map<String, Object?> json) => PoseArray(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        poses: Field.asList<ros2.Pose>(json['poses'], ros2.Pose.fromJson),
      );

  final ros2.Header header;
  final List<ros2.Pose> poses;

  @override
  String get rosType => 'geometry_msgs/msg/PoseArray';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'poses': poses.map((ros2.Pose e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoseArray &&
          other.header == header &&
          _listEquals(other.poses, poses));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...poses,
      ]);

  @override
  String toString() => 'PoseArray(${toJson()})';
}

/// This represents a pose in free space with uncertainty.
///
/// `geometry_msgs/msg/PoseWithCovariance`
final class PoseWithCovariance implements RosMessage {
  PoseWithCovariance({
    ros2.Pose? pose,
    Float64List? covariance,
  })  : pose = pose ?? ros2.Pose(),
        covariance = covariance ?? Float64List(0);

  factory PoseWithCovariance.fromJson(Map<String, Object?> json) =>
      PoseWithCovariance(
        pose: Field.asMessage(json['pose'], ros2.Pose.fromJson),
        covariance: Field.asFloat64List(json['covariance']),
      );

  final ros2.Pose pose;

  /// Fixed length: 36.
  final Float64List covariance;

  @override
  String get rosType => 'geometry_msgs/msg/PoseWithCovariance';

  @override
  Map<String, Object?> toJson() => {
        'pose': pose.toJson(),
        'covariance': Field.encodeNumbers(covariance),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoseWithCovariance &&
          other.pose == pose &&
          _listEquals(other.covariance, covariance));

  @override
  int get hashCode => Object.hashAll([
        pose,
        ...covariance,
      ]);

  @override
  String toString() => 'PoseWithCovariance(${toJson()})';
}

/// This expresses an estimated pose with a reference coordinate frame and timestamp
///
/// `geometry_msgs/msg/PoseWithCovarianceStamped`
final class PoseWithCovarianceStamped implements RosMessage {
  PoseWithCovarianceStamped({
    ros2.Header? header,
    PoseWithCovariance? pose,
  })  : header = header ?? ros2.Header(),
        pose = pose ?? PoseWithCovariance();

  factory PoseWithCovarianceStamped.fromJson(Map<String, Object?> json) =>
      PoseWithCovarianceStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        pose: Field.asMessage(json['pose'], PoseWithCovariance.fromJson),
      );

  final ros2.Header header;
  final PoseWithCovariance pose;

  @override
  String get rosType => 'geometry_msgs/msg/PoseWithCovarianceStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'pose': pose.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoseWithCovarianceStamped &&
          other.header == header &&
          other.pose == pose);

  @override
  int get hashCode => Object.hashAll([
        header,
        pose,
      ]);

  @override
  String toString() => 'PoseWithCovarianceStamped(${toJson()})';
}

/// This represents an orientation with reference coordinate frame and timestamp.
///
/// `geometry_msgs/msg/QuaternionStamped`
final class QuaternionStamped implements RosMessage {
  QuaternionStamped({
    ros2.Header? header,
    ros2.Quaternion? quaternion,
  })  : header = header ?? ros2.Header(),
        quaternion = quaternion ?? ros2.Quaternion();

  factory QuaternionStamped.fromJson(Map<String, Object?> json) =>
      QuaternionStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        quaternion:
            Field.asMessage(json['quaternion'], ros2.Quaternion.fromJson),
      );

  final ros2.Header header;
  final ros2.Quaternion quaternion;

  @override
  String get rosType => 'geometry_msgs/msg/QuaternionStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'quaternion': quaternion.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuaternionStamped &&
          other.header == header &&
          other.quaternion == quaternion);

  @override
  int get hashCode => Object.hashAll([
        header,
        quaternion,
      ]);

  @override
  String toString() => 'QuaternionStamped(${toJson()})';
}

/// A twist with reference coordinate frame and timestamp
///
/// `geometry_msgs/msg/TwistStamped`
final class TwistStamped implements RosMessage {
  TwistStamped({
    ros2.Header? header,
    ros2.Twist? twist,
  })  : header = header ?? ros2.Header(),
        twist = twist ?? ros2.Twist();

  factory TwistStamped.fromJson(Map<String, Object?> json) => TwistStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        twist: Field.asMessage(json['twist'], ros2.Twist.fromJson),
      );

  final ros2.Header header;
  final ros2.Twist twist;

  @override
  String get rosType => 'geometry_msgs/msg/TwistStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'twist': twist.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TwistStamped && other.header == header && other.twist == twist);

  @override
  int get hashCode => Object.hashAll([
        header,
        twist,
      ]);

  @override
  String toString() => 'TwistStamped(${toJson()})';
}

/// This expresses velocity in free space with uncertainty.
///
/// `geometry_msgs/msg/TwistWithCovariance`
final class TwistWithCovariance implements RosMessage {
  TwistWithCovariance({
    ros2.Twist? twist,
    Float64List? covariance,
  })  : twist = twist ?? ros2.Twist(),
        covariance = covariance ?? Float64List(0);

  factory TwistWithCovariance.fromJson(Map<String, Object?> json) =>
      TwistWithCovariance(
        twist: Field.asMessage(json['twist'], ros2.Twist.fromJson),
        covariance: Field.asFloat64List(json['covariance']),
      );

  final ros2.Twist twist;

  /// Fixed length: 36.
  final Float64List covariance;

  @override
  String get rosType => 'geometry_msgs/msg/TwistWithCovariance';

  @override
  Map<String, Object?> toJson() => {
        'twist': twist.toJson(),
        'covariance': Field.encodeNumbers(covariance),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TwistWithCovariance &&
          other.twist == twist &&
          _listEquals(other.covariance, covariance));

  @override
  int get hashCode => Object.hashAll([
        twist,
        ...covariance,
      ]);

  @override
  String toString() => 'TwistWithCovariance(${toJson()})';
}

/// This represents an estimated twist with reference coordinate frame and timestamp.
///
/// `geometry_msgs/msg/TwistWithCovarianceStamped`
final class TwistWithCovarianceStamped implements RosMessage {
  TwistWithCovarianceStamped({
    ros2.Header? header,
    TwistWithCovariance? twist,
  })  : header = header ?? ros2.Header(),
        twist = twist ?? TwistWithCovariance();

  factory TwistWithCovarianceStamped.fromJson(Map<String, Object?> json) =>
      TwistWithCovarianceStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        twist: Field.asMessage(json['twist'], TwistWithCovariance.fromJson),
      );

  final ros2.Header header;
  final TwistWithCovariance twist;

  @override
  String get rosType => 'geometry_msgs/msg/TwistWithCovarianceStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'twist': twist.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TwistWithCovarianceStamped &&
          other.header == header &&
          other.twist == twist);

  @override
  int get hashCode => Object.hashAll([
        header,
        twist,
      ]);

  @override
  String toString() => 'TwistWithCovarianceStamped(${toJson()})';
}

/// This represents a Vector3 with reference coordinate frame and timestamp
///
/// `geometry_msgs/msg/Vector3Stamped`
final class Vector3Stamped implements RosMessage {
  Vector3Stamped({
    ros2.Header? header,
    ros2.Vector3? vector,
  })  : header = header ?? ros2.Header(),
        vector = vector ?? ros2.Vector3();

  factory Vector3Stamped.fromJson(Map<String, Object?> json) => Vector3Stamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        vector: Field.asMessage(json['vector'], ros2.Vector3.fromJson),
      );

  final ros2.Header header;
  final ros2.Vector3 vector;

  @override
  String get rosType => 'geometry_msgs/msg/Vector3Stamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'vector': vector.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vector3Stamped &&
          other.header == header &&
          other.vector == vector);

  @override
  int get hashCode => Object.hashAll([
        header,
        vector,
      ]);

  @override
  String toString() => 'Vector3Stamped(${toJson()})';
}

/// This expresses the timestamped velocity vector of a frame 'body_frame_id' in the reference frame 'reference_frame_id' expressed from arbitrary observation frame 'header.frame_id'.
/// - If the 'body_frame_id' and 'header.frame_id' are identical, the velocity is observed and defined in the local coordinates system of the body
/// which is the usual use-case in mobile robotics and is also known as a body twist.
///
/// `geometry_msgs/msg/VelocityStamped`
final class VelocityStamped implements RosMessage {
  VelocityStamped({
    ros2.Header? header,
    this.bodyFrameId = '',
    this.referenceFrameId = '',
    ros2.Twist? velocity,
  })  : header = header ?? ros2.Header(),
        velocity = velocity ?? ros2.Twist();

  factory VelocityStamped.fromJson(Map<String, Object?> json) =>
      VelocityStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        bodyFrameId: Field.asString(json['body_frame_id']),
        referenceFrameId: Field.asString(json['reference_frame_id']),
        velocity: Field.asMessage(json['velocity'], ros2.Twist.fromJson),
      );

  final ros2.Header header;
  final String bodyFrameId;
  final String referenceFrameId;
  final ros2.Twist velocity;

  @override
  String get rosType => 'geometry_msgs/msg/VelocityStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'body_frame_id': bodyFrameId,
        'reference_frame_id': referenceFrameId,
        'velocity': velocity.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VelocityStamped &&
          other.header == header &&
          other.bodyFrameId == bodyFrameId &&
          other.referenceFrameId == referenceFrameId &&
          other.velocity == velocity);

  @override
  int get hashCode => Object.hashAll([
        header,
        bodyFrameId,
        referenceFrameId,
        velocity,
      ]);

  @override
  String toString() => 'VelocityStamped(${toJson()})';
}

/// A timestamped velocity of a body whose frame is 'body_frame_id', measured
/// relative to the reference frame 'reference_frame_id', with the velocity and
/// covariance both expressed in the basis of the observation frame
/// 'header.frame_id'.
///
/// - If 'body_frame_id' and 'header.frame_id' are identical, the velocity and
/// covariance are expressed in the body's own basis. This is functionally
/// equivalent to the body-twist convention used by
/// 'geometry_msgs/TwistStamped'.
///
/// This message is the covariance-bearing analogue of
/// 'geometry_msgs/VelocityStamped'.
///
/// `geometry_msgs/msg/VelocityWithCovarianceStamped`
final class VelocityWithCovarianceStamped implements RosMessage {
  VelocityWithCovarianceStamped({
    ros2.Header? header,
    this.bodyFrameId = '',
    this.referenceFrameId = '',
    TwistWithCovariance? velocity,
  })  : header = header ?? ros2.Header(),
        velocity = velocity ?? TwistWithCovariance();

  factory VelocityWithCovarianceStamped.fromJson(Map<String, Object?> json) =>
      VelocityWithCovarianceStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        bodyFrameId: Field.asString(json['body_frame_id']),
        referenceFrameId: Field.asString(json['reference_frame_id']),
        velocity:
            Field.asMessage(json['velocity'], TwistWithCovariance.fromJson),
      );

  final ros2.Header header;
  final String bodyFrameId;
  final String referenceFrameId;
  final TwistWithCovariance velocity;

  @override
  String get rosType => 'geometry_msgs/msg/VelocityWithCovarianceStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'body_frame_id': bodyFrameId,
        'reference_frame_id': referenceFrameId,
        'velocity': velocity.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VelocityWithCovarianceStamped &&
          other.header == header &&
          other.bodyFrameId == bodyFrameId &&
          other.referenceFrameId == referenceFrameId &&
          other.velocity == velocity);

  @override
  int get hashCode => Object.hashAll([
        header,
        bodyFrameId,
        referenceFrameId,
        velocity,
      ]);

  @override
  String toString() => 'VelocityWithCovarianceStamped(${toJson()})';
}

/// This represents force in free space, separated into its linear and angular parts.
///
/// `geometry_msgs/msg/Wrench`
final class Wrench implements RosMessage {
  Wrench({
    ros2.Vector3? force,
    ros2.Vector3? torque,
  })  : force = force ?? ros2.Vector3(),
        torque = torque ?? ros2.Vector3();

  factory Wrench.fromJson(Map<String, Object?> json) => Wrench(
        force: Field.asMessage(json['force'], ros2.Vector3.fromJson),
        torque: Field.asMessage(json['torque'], ros2.Vector3.fromJson),
      );

  final ros2.Vector3 force;
  final ros2.Vector3 torque;

  @override
  String get rosType => 'geometry_msgs/msg/Wrench';

  @override
  Map<String, Object?> toJson() => {
        'force': force.toJson(),
        'torque': torque.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wrench && other.force == force && other.torque == torque);

  @override
  int get hashCode => Object.hashAll([
        force,
        torque,
      ]);

  @override
  String toString() => 'Wrench(${toJson()})';
}

/// A wrench with reference coordinate frame and timestamp
///
/// `geometry_msgs/msg/WrenchStamped`
final class WrenchStamped implements RosMessage {
  WrenchStamped({
    ros2.Header? header,
    Wrench? wrench,
  })  : header = header ?? ros2.Header(),
        wrench = wrench ?? Wrench();

  factory WrenchStamped.fromJson(Map<String, Object?> json) => WrenchStamped(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        wrench: Field.asMessage(json['wrench'], Wrench.fromJson),
      );

  final ros2.Header header;
  final Wrench wrench;

  @override
  String get rosType => 'geometry_msgs/msg/WrenchStamped';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'wrench': wrench.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WrenchStamped &&
          other.header == header &&
          other.wrench == wrench);

  @override
  int get hashCode => Object.hashAll([
        header,
        wrench,
      ]);

  @override
  String toString() => 'WrenchStamped(${toJson()})';
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

/// Registers every message in `geometry_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerGeometryMsgs() {
  MessageRegistry.register(const MessageCodec<Accel>(
    rosType: 'geometry_msgs/msg/Accel',
    fromJson: Accel.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<AccelStamped>(
    rosType: 'geometry_msgs/msg/AccelStamped',
    fromJson: AccelStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<AccelWithCovariance>(
    rosType: 'geometry_msgs/msg/AccelWithCovariance',
    fromJson: AccelWithCovariance.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<AccelWithCovarianceStamped>(
    rosType: 'geometry_msgs/msg/AccelWithCovarianceStamped',
    fromJson: AccelWithCovarianceStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Inertia>(
    rosType: 'geometry_msgs/msg/Inertia',
    fromJson: Inertia.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<InertiaStamped>(
    rosType: 'geometry_msgs/msg/InertiaStamped',
    fromJson: InertiaStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Point32>(
    rosType: 'geometry_msgs/msg/Point32',
    fromJson: Point32.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<PointStamped>(
    rosType: 'geometry_msgs/msg/PointStamped',
    fromJson: PointStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Polygon>(
    rosType: 'geometry_msgs/msg/Polygon',
    fromJson: Polygon.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<PolygonInstance>(
    rosType: 'geometry_msgs/msg/PolygonInstance',
    fromJson: PolygonInstance.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<PolygonInstanceStamped>(
    rosType: 'geometry_msgs/msg/PolygonInstanceStamped',
    fromJson: PolygonInstanceStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<PolygonStamped>(
    rosType: 'geometry_msgs/msg/PolygonStamped',
    fromJson: PolygonStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Pose2D>(
    rosType: 'geometry_msgs/msg/Pose2D',
    fromJson: Pose2D.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<PoseArray>(
    rosType: 'geometry_msgs/msg/PoseArray',
    fromJson: PoseArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<PoseWithCovariance>(
    rosType: 'geometry_msgs/msg/PoseWithCovariance',
    fromJson: PoseWithCovariance.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<PoseWithCovarianceStamped>(
    rosType: 'geometry_msgs/msg/PoseWithCovarianceStamped',
    fromJson: PoseWithCovarianceStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<QuaternionStamped>(
    rosType: 'geometry_msgs/msg/QuaternionStamped',
    fromJson: QuaternionStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<TwistStamped>(
    rosType: 'geometry_msgs/msg/TwistStamped',
    fromJson: TwistStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<TwistWithCovariance>(
    rosType: 'geometry_msgs/msg/TwistWithCovariance',
    fromJson: TwistWithCovariance.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<TwistWithCovarianceStamped>(
    rosType: 'geometry_msgs/msg/TwistWithCovarianceStamped',
    fromJson: TwistWithCovarianceStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Vector3Stamped>(
    rosType: 'geometry_msgs/msg/Vector3Stamped',
    fromJson: Vector3Stamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<VelocityStamped>(
    rosType: 'geometry_msgs/msg/VelocityStamped',
    fromJson: VelocityStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<VelocityWithCovarianceStamped>(
    rosType: 'geometry_msgs/msg/VelocityWithCovarianceStamped',
    fromJson: VelocityWithCovarianceStamped.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Wrench>(
    rosType: 'geometry_msgs/msg/Wrench',
    fromJson: Wrench.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<WrenchStamped>(
    rosType: 'geometry_msgs/msg/WrenchStamped',
    fromJson: WrenchStamped.fromJson,
    toJson: _toJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
