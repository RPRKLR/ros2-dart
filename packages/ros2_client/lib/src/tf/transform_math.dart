import 'dart:math' as math;

import '../messages/geometry_msgs.dart';

/// Rigid-body maths on the `geometry_msgs` value types.
///
/// ROS convention (REP-103): a [RosTransform] with `header.frame_id = parent`
/// and `child_frame_id = child` expresses the pose of *child* in *parent*, and
/// applying it to a point maps that point from child coordinates into parent
/// coordinates.
extension QuaternionMath on Quaternion {
  /// Hamilton product: the rotation `other` followed by this one.
  Quaternion operator *(Quaternion other) => Quaternion(
        w: w * other.w - x * other.x - y * other.y - z * other.z,
        x: w * other.x + x * other.w + y * other.z - z * other.y,
        y: w * other.y - x * other.z + y * other.w + z * other.x,
        z: w * other.z + x * other.y - y * other.x + z * other.w,
      );

  /// The inverse rotation. Unit quaternions invert by conjugation.
  Quaternion get inverse {
    final n = x * x + y * y + z * z + w * w;
    if (n == 0) return Quaternion.identity;
    return Quaternion(x: -x / n, y: -y / n, z: -z / n, w: w / n);
  }

  double get norm => math.sqrt(x * x + y * y + z * z + w * w);

  Quaternion get normalized {
    final n = norm;
    if (n == 0) return Quaternion.identity;
    return Quaternion(x: x / n, y: y / n, z: z / n, w: w / n);
  }

  /// Rotates [v] by this quaternion.
  Vector3 rotate(Vector3 v) {
    // v' = v + 2 * q_vec x (q_vec x v + w * v), which avoids building a matrix.
    final tx = 2 * (y * v.z - z * v.y);
    final ty = 2 * (z * v.x - x * v.z);
    final tz = 2 * (x * v.y - y * v.x);
    return Vector3(
      x: v.x + w * tx + (y * tz - z * ty),
      y: v.y + w * ty + (z * tx - x * tz),
      z: v.z + w * tz + (x * ty - y * tx),
    );
  }

  /// Roll, pitch and yaw in radians (XYZ fixed-axis, per REP-103).
  ({double roll, double pitch, double yaw}) get rpy {
    final sinrCosp = 2 * (w * x + y * z);
    final cosrCosp = 1 - 2 * (x * x + y * y);
    final roll = math.atan2(sinrCosp, cosrCosp);

    final sinp = 2 * (w * y - z * x);
    // Clamp: outside [-1, 1] is gimbal lock, where asin is undefined.
    final pitch = sinp.abs() >= 1
        ? (sinp.isNegative ? -math.pi / 2 : math.pi / 2)
        : math.asin(sinp);

    final sinyCosp = 2 * (w * z + x * y);
    final cosyCosp = 1 - 2 * (y * y + z * z);
    final yawValue = math.atan2(sinyCosp, cosyCosp);

    return (roll: roll, pitch: pitch, yaw: yawValue);
  }

  /// Spherical linear interpolation towards [other] by [t] in `0..1`.
  Quaternion slerp(Quaternion other, double t) {
    if (t <= 0) return this;
    if (t >= 1) return other;

    var dot = x * other.x + y * other.y + z * other.z + w * other.w;
    var target = other;
    // Take the shorter arc: q and -q are the same rotation.
    if (dot < 0) {
      dot = -dot;
      target = Quaternion(x: -other.x, y: -other.y, z: -other.z, w: -other.w);
    }

    // Nearly parallel: slerp is numerically unstable, and lerp is accurate.
    if (dot > 0.9995) {
      return Quaternion(
        x: x + (target.x - x) * t,
        y: y + (target.y - y) * t,
        z: z + (target.z - z) * t,
        w: w + (target.w - w) * t,
      ).normalized;
    }

    final theta0 = math.acos(dot);
    final theta = theta0 * t;
    final sinTheta = math.sin(theta);
    final sinTheta0 = math.sin(theta0);

    final s0 = math.cos(theta) - dot * sinTheta / sinTheta0;
    final s1 = sinTheta / sinTheta0;

    return Quaternion(
      x: s0 * x + s1 * target.x,
      y: s0 * y + s1 * target.y,
      z: s0 * z + s1 * target.z,
      w: s0 * w + s1 * target.w,
    );
  }
}

extension Vector3Math on Vector3 {
  Vector3 operator +(Vector3 other) =>
      Vector3(x: x + other.x, y: y + other.y, z: z + other.z);

  Vector3 operator -(Vector3 other) =>
      Vector3(x: x - other.x, y: y - other.y, z: z - other.z);

  Vector3 operator *(double s) => Vector3(x: x * s, y: y * s, z: z * s);

  Vector3 lerp(Vector3 other, double t) => Vector3(
        x: x + (other.x - x) * t,
        y: y + (other.y - y) * t,
        z: z + (other.z - z) * t,
      );

  Point toPoint() => Point(x: x, y: y, z: z);
}

extension PointMath on Point {
  Vector3 toVector3() => Vector3(x: x, y: y, z: z);
}

extension TransformMath on RosTransform {
  /// Composes with [child]: the result maps [child]'s frame into this one.
  ///
  /// If `this` is `T_a_b` and [child] is `T_b_c`, the result is `T_a_c`.
  RosTransform compose(RosTransform child) => RosTransform(
        translation: translation + rotation.rotate(child.translation),
        rotation: (rotation * child.rotation).normalized,
      );

  /// The inverse transform, mapping in the opposite direction.
  RosTransform get inverse {
    final invRotation = rotation.inverse;
    return RosTransform(
      translation: invRotation.rotate(translation) * -1.0,
      rotation: invRotation,
    );
  }

  /// Maps a point from the child frame into the parent frame.
  Point transformPoint(Point p) =>
      (rotation.rotate(p.toVector3()) + translation).toPoint();

  /// Maps a vector, applying rotation only — a direction has no origin.
  Vector3 transformVector(Vector3 v) => rotation.rotate(v);

  /// Maps a full pose from the child frame into the parent frame.
  Pose transformPose(Pose pose) => Pose(
        position: transformPoint(pose.position),
        orientation: (rotation * pose.orientation).normalized,
      );

  /// Interpolates towards [other] by [t] in `0..1`.
  RosTransform lerpTo(RosTransform other, double t) => RosTransform(
        translation: translation.lerp(other.translation, t),
        rotation: rotation.slerp(other.rotation, t),
      );

  static const RosTransform identity = RosTransform();
}
