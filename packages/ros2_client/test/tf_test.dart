import 'dart:math' as math;

import 'package:ros2_client/ros2_client.dart';
import 'package:test/test.dart';

RosTransformStamped tf(
  String parent,
  String child, {
  double x = 0,
  double y = 0,
  double z = 0,
  double yaw = 0,
  int sec = 0,
  int nanosec = 0,
}) =>
    RosTransformStamped(
      header:
          Header(frameId: parent, stamp: RosTime(sec: sec, nanosec: nanosec)),
      childFrameId: child,
      transform: RosTransform(
        translation: Vector3(x: x, y: y, z: z),
        rotation: Quaternion.fromYaw(yaw),
      ),
    );

/// Transform comparison has to be approximate: composition and slerp both
/// accumulate floating-point error.
void expectVector(Vector3 actual, double x, double y, double z,
    {double tol = 1e-9}) {
  expect(actual.x, closeTo(x, tol));
  expect(actual.y, closeTo(y, tol));
  expect(actual.z, closeTo(z, tol));
}

void main() {
  group('quaternion maths', () {
    test('fromYaw and yaw round-trip', () {
      for (final angle in [0.0, 0.5, 1.5, -2.0, math.pi / 2]) {
        expect(Quaternion.fromYaw(angle).yaw, closeTo(angle, 1e-9));
      }
    });

    test('multiplying by the inverse yields identity', () {
      final q = Quaternion.fromYaw(1.1);
      final r = q * q.inverse;
      expect(r.w.abs(), closeTo(1.0, 1e-9));
      expect(r.x, closeTo(0, 1e-9));
      expect(r.y, closeTo(0, 1e-9));
      expect(r.z, closeTo(0, 1e-9));
    });

    test('rotates a vector about +Z', () {
      final q = Quaternion.fromYaw(math.pi / 2);
      expectVector(q.rotate(const Vector3(x: 1)), 0, 1, 0, tol: 1e-9);
    });

    test('rotation composition is ordered, not commutative', () {
      final a = Quaternion.fromYaw(math.pi / 2);
      final b = Quaternion(x: math.sin(math.pi / 4), w: math.cos(math.pi / 4));
      final ab = (a * b).rotate(const Vector3(z: 1));
      final ba = (b * a).rotate(const Vector3(z: 1));
      expect((ab.x - ba.x).abs() + (ab.y - ba.y).abs() + (ab.z - ba.z).abs(),
          greaterThan(0.1));
    });

    test('slerp interpolates and hits both endpoints', () {
      final a = Quaternion.fromYaw(0);
      final b = Quaternion.fromYaw(1.0);
      expect(a.slerp(b, 0).yaw, closeTo(0, 1e-9));
      expect(a.slerp(b, 1).yaw, closeTo(1.0, 1e-9));
      expect(a.slerp(b, 0.5).yaw, closeTo(0.5, 1e-9));
    });

    test('slerp takes the shorter arc', () {
      // 170 deg and -170 deg are 20 deg apart the short way.
      final a = Quaternion.fromYaw(170 * math.pi / 180);
      final b = Quaternion.fromYaw(-170 * math.pi / 180);
      final mid = a.slerp(b, 0.5).yaw.abs();
      expect(mid, closeTo(math.pi, 1e-6));
    });

    test('rpy reports roll, pitch and yaw', () {
      final rpy = Quaternion.fromYaw(0.7).rpy;
      expect(rpy.yaw, closeTo(0.7, 1e-9));
      expect(rpy.roll, closeTo(0, 1e-9));
      expect(rpy.pitch, closeTo(0, 1e-9));
    });
  });

  group('transform maths', () {
    test('compose then inverse-compose returns to the start', () {
      const a = RosTransform(translation: Vector3(x: 1, y: 2));
      final b = RosTransform(
          translation: const Vector3(x: 3), rotation: Quaternion.fromYaw(0.4));
      final composed = a.compose(b);
      final back = composed.compose(b.inverse);
      expectVector(back.translation, 1, 2, 0, tol: 1e-9);
    });

    test('translation then rotation applies in the right order', () {
      // Frame b is at (1,0) in a, rotated 90 deg.
      final aToB = RosTransform(
        translation: const Vector3(x: 1),
        rotation: Quaternion.fromYaw(math.pi / 2),
      );
      // A point 1 m ahead in b is at (1,1) in a.
      final p = aToB.transformPoint(const Point(x: 1));
      expect(p.x, closeTo(1, 1e-9));
      expect(p.y, closeTo(1, 1e-9));
    });

    test('transformVector ignores translation', () {
      final t = RosTransform(
        translation: const Vector3(x: 10, y: 10),
        rotation: Quaternion.fromYaw(math.pi / 2),
      );
      expectVector(t.transformVector(const Vector3(x: 1)), 0, 1, 0, tol: 1e-9);
    });

    test('inverse of a pure rotation negates the angle', () {
      final t = RosTransform(rotation: Quaternion.fromYaw(0.6));
      expect(t.inverse.rotation.yaw, closeTo(-0.6, 1e-9));
    });
  });

  group('TfBuffer lookups', () {
    late TfBuffer buffer;
    setUp(() => buffer = TfBuffer());

    test('identity for a frame to itself', () {
      expect(buffer.lookup('map', 'map')!.translation, Vector3.zero);
    });

    test('resolves a direct parent-child transform', () {
      buffer.setTransform(tf('map', 'odom', x: 5), isStatic: true);
      final t = buffer.lookup('map', 'odom')!;
      expectVector(t.translation, 5, 0, 0);
    });

    test('inverts when asked in the opposite direction', () {
      buffer.setTransform(tf('map', 'odom', x: 5), isStatic: true);
      final t = buffer.lookup('odom', 'map')!;
      expectVector(t.translation, -5, 0, 0);
    });

    test('chains through intermediate frames', () {
      buffer.setTransform(tf('map', 'odom', x: 1), isStatic: true);
      buffer.setTransform(tf('odom', 'base_link', x: 2), isStatic: true);
      buffer.setTransform(tf('base_link', 'laser', x: 3), isStatic: true);
      expectVector(buffer.lookup('map', 'laser')!.translation, 6, 0, 0);
    });

    test('chains correctly through a rotation', () {
      buffer.setTransform(tf('map', 'base', x: 1, yaw: math.pi / 2),
          isStatic: true);
      buffer.setTransform(tf('base', 'laser', x: 2), isStatic: true);
      // base is at (1,0) rotated 90 deg, so laser (2 m ahead in base) is (1,2).
      expectVector(buffer.lookup('map', 'laser')!.translation, 1, 2, 0,
          tol: 1e-9);
    });

    test('walks up and back down through a common ancestor', () {
      buffer.setTransform(tf('map', 'odom', x: 10), isStatic: true);
      buffer.setTransform(tf('odom', 'left', y: 1), isStatic: true);
      buffer.setTransform(tf('odom', 'right', y: -1), isStatic: true);
      // left -> right never passes through map.
      expectVector(buffer.lookup('right', 'left')!.translation, 0, 2, 0);
    });

    test('treats a leading slash as the same frame', () {
      buffer.setTransform(tf('/map', '/odom', x: 4), isStatic: true);
      expectVector(buffer.lookup('map', 'odom')!.translation, 4, 0, 0);
    });

    test('reports an unknown frame by name', () {
      buffer.setTransform(tf('map', 'odom'), isStatic: true);
      expect(
        () => buffer.lookupOrThrow('map', 'nonexistent'),
        throwsA(isA<TfException>()
            .having((e) => e.message, 'message', contains('nonexistent'))),
      );
    });

    test('reports disconnected trees rather than returning nonsense', () {
      buffer.setTransform(tf('map', 'odom'), isStatic: true);
      buffer.setTransform(tf('world', 'other'), isStatic: true);
      expect(
        () => buffer.lookupOrThrow('other', 'odom'),
        throwsA(isA<TfException>()
            .having((e) => e.message, 'message', contains('disconnected'))),
      );
    });

    test('lookup returns null where lookupOrThrow throws', () {
      expect(buffer.lookup('a', 'b'), isNull);
      expect(buffer.canTransform('a', 'b'), isFalse);
    });

    test('survives a cyclic tree instead of hanging', () {
      buffer.setTransform(tf('a', 'b'), isStatic: true);
      buffer.setTransform(tf('b', 'a'), isStatic: true);
      // Must terminate; the result itself is meaningless.
      expect(() => buffer.lookup('a', 'b'), returnsNormally);
    });
  });

  group('TfBuffer time handling', () {
    test('interpolates linearly between two samples', () {
      final buffer = TfBuffer();
      buffer.setTransform(tf('map', 'base', x: 0, sec: 100));
      buffer.setTransform(tf('map', 'base', x: 10, sec: 102));

      final mid = buffer.lookup('map', 'base', time: const RosTime(sec: 101))!;
      expect(mid.translation.x, closeTo(5, 1e-6));

      final quarter = buffer.lookup('map', 'base',
          time: const RosTime(sec: 100, nanosec: 500000000))!;
      expect(quarter.translation.x, closeTo(2.5, 1e-6));
    });

    test('slerps rotation between samples', () {
      final buffer = TfBuffer();
      buffer.setTransform(tf('map', 'base', yaw: 0, sec: 10));
      buffer.setTransform(tf('map', 'base', yaw: 1.0, sec: 12));
      final mid = buffer.lookup('map', 'base', time: const RosTime(sec: 11))!;
      expect(mid.rotation.yaw, closeTo(0.5, 1e-6));
    });

    test('a null time means the latest sample', () {
      final buffer = TfBuffer();
      buffer.setTransform(tf('map', 'base', x: 1, sec: 10));
      buffer.setTransform(tf('map', 'base', x: 2, sec: 11));
      expect(buffer.lookup('map', 'base')!.translation.x, 2);
    });

    test('fails outside the buffer window beyond the tolerance', () {
      final buffer = TfBuffer(tolerance: const Duration(milliseconds: 50));
      buffer.setTransform(tf('map', 'base', x: 1, sec: 100));
      buffer.setTransform(tf('map', 'base', x: 2, sec: 101));

      // Well past the newest sample.
      expect(
          buffer.lookup('map', 'base', time: const RosTime(sec: 200)), isNull);
      // Within tolerance of the newest.
      expect(
          buffer.lookup('map', 'base',
              time: const RosTime(sec: 101, nanosec: 20000000)),
          isNotNull);
    });

    test('static transforms answer at any time', () {
      final buffer = TfBuffer();
      buffer.setTransform(tf('map', 'base', x: 7), isStatic: true);
      expect(
          buffer
              .lookup('map', 'base', time: const RosTime(sec: 999999))!
              .translation
              .x,
          7);
    });

    test('drops samples older than the cache window', () {
      final buffer = TfBuffer(cacheTime: const Duration(seconds: 2));
      for (var t = 100; t <= 110; t++) {
        buffer.setTransform(tf('map', 'base', x: t.toDouble(), sec: t));
      }
      // The oldest samples are gone, so an old lookup must fail.
      expect(
          buffer.lookup('map', 'base', time: const RosTime(sec: 100)), isNull);
      expect(buffer.lookup('map', 'base', time: const RosTime(sec: 109)),
          isNotNull);
    });

    test('orders a late-arriving out-of-order sample', () {
      final buffer = TfBuffer();
      buffer.setTransform(tf('map', 'base', x: 0, sec: 10));
      buffer.setTransform(tf('map', 'base', x: 20, sec: 12));
      // Arrives late, belongs in the middle.
      buffer.setTransform(tf('map', 'base', x: 10, sec: 11));

      final at = buffer.lookup('map', 'base',
          time: const RosTime(sec: 11, nanosec: 500000000))!;
      expect(at.translation.x, closeTo(15, 1e-6));
    });
  });

  group('TfBuffer introspection', () {
    test('reports frames, parents and roots', () {
      final buffer = TfBuffer();
      buffer.setTransform(tf('map', 'odom'), isStatic: true);
      buffer.setTransform(tf('odom', 'base_link'), isStatic: true);

      expect(buffer.frames, containsAll(['map', 'odom', 'base_link']));
      expect(buffer.parentOf('base_link'), 'odom');
      expect(buffer.parentOf('map'), isNull);
      expect(buffer.rootFrames, {'map'});
      expect(buffer.describe(), contains('base_link'));
    });

    test('re-parenting a frame discards the stale history', () {
      final buffer = TfBuffer();
      buffer.setTransform(tf('map', 'base', x: 1, sec: 10));
      buffer.setTransform(tf('odom', 'base', x: 5, sec: 11));

      expect(buffer.parentOf('base'), 'odom');
      expectVector(buffer.lookup('odom', 'base')!.translation, 5, 0, 0);
    });

    test('ignores a self-parented transform', () {
      final buffer = TfBuffer();
      buffer.setTransform(tf('map', 'map'), isStatic: true);
      expect(buffer.parentOf('map'), isNull);
    });
  });

  group('Euler and matrix conversions', () {
    test('fromRpy round-trips through rpy', () {
      // Deliberately off-axis: an all-zero or single-axis case passes even
      // with the multiplication order wrong.
      const roll = 0.3;
      const pitch = -0.7;
      const yaw = 2.1;

      final q = Quaternion.fromRpy(roll, pitch, yaw);
      expect(q.norm, closeTo(1.0, 1e-12));

      final back = q.rpy;
      expect(back.roll, closeTo(roll, 1e-9));
      expect(back.pitch, closeTo(pitch, 1e-9));
      expect(back.yaw, closeTo(yaw, 1e-9));
    });

    test('fromRpy applies fixed-axis XYZ order', () {
      // Composed as yaw * pitch * roll about the fixed axes; the reverse
      // order gives a different rotation for these angles.
      final composed = Quaternion.fromYaw(2.1) *
          Quaternion.fromRpy(0, -0.7, 0) *
          Quaternion.fromRpy(0.3, 0, 0);
      final direct = Quaternion.fromRpy(0.3, -0.7, 2.1);

      expect(direct.x, closeTo(composed.x, 1e-12));
      expect(direct.y, closeTo(composed.y, 1e-12));
      expect(direct.z, closeTo(composed.z, 1e-12));
      expect(direct.w, closeTo(composed.w, 1e-12));
    });

    test('fromYaw rotates in the +Z sense', () {
      final q = Quaternion.fromYaw(math.pi / 2);
      expectVector(q.rotate(const Vector3(x: 1)), 0, 1, 0, tol: 1e-9);
      expect(q.yaw, closeTo(math.pi / 2, 1e-9));
    });

    test('toMatrix4 is column-major and agrees with transformPoint', () {
      final t = RosTransform(
        translation: const Vector3(x: 1, y: 2, z: 3),
        rotation: Quaternion.fromRpy(0.3, -0.7, 2.1),
      );
      final m = t.toMatrix4();

      expect(m, hasLength(16));
      // Translation lives in the last column, which in column-major order is
      // the last four entries — transposing this is the classic bug.
      expect(m[12], closeTo(1, 1e-12));
      expect(m[13], closeTo(2, 1e-12));
      expect(m[14], closeTo(3, 1e-12));
      expect(m[15], closeTo(1, 1e-12));

      const p = Point(x: 0.4, y: -1.3, z: 2.2);
      final expected = t.transformPoint(p);
      // Column-major m: element (row, col) is m[col * 4 + row].
      expect(m[0] * p.x + m[4] * p.y + m[8] * p.z + m[12],
          closeTo(expected.x, 1e-9));
      expect(m[1] * p.x + m[5] * p.y + m[9] * p.z + m[13],
          closeTo(expected.y, 1e-9));
      expect(m[2] * p.x + m[6] * p.y + m[10] * p.z + m[14],
          closeTo(expected.z, 1e-9));
    });
  });

  group('robustness against bad publishers', () {
    test('one future-stamped sample does not poison the buffer', () {
      final buffer = TfBuffer(cacheTime: const Duration(seconds: 10));
      for (var i = 0; i <= 20; i++) {
        buffer.setTransform(tf('map', 'base', x: i.toDouble(), sec: 1000 + i));
      }
      expect(
          buffer.lookup('map', 'base', time: RosTime(sec: 1010))!.translation.x,
          10);

      // A node whose clock is a minute fast. Anchoring the cache window on it
      // would drop every sample held and every good one that follows, and the
      // buffer would never recover.
      buffer.setTransform(tf('map', 'base', x: 99, sec: 1080));

      expect(buffer.lookup('map', 'base', time: RosTime(sec: 1010)), isNotNull,
          reason: 'existing samples must survive one bad stamp');
      for (var i = 21; i <= 50; i++) {
        buffer.setTransform(tf('map', 'base', x: i.toDouble(), sec: 1000 + i));
      }
      expect(
          buffer.lookup('map', 'base', time: RosTime(sec: 1050))!.translation.x,
          50,
          reason: 'and good data afterwards must still land');
    });

    test('a sustained clock jump is eventually accepted', () {
      final buffer = TfBuffer(cacheTime: const Duration(seconds: 10));
      buffer.setTransform(tf('map', 'base', x: 1, sec: 1000));
      // Not an outlier: the clock really did move, and every message now
      // carries the new time. Rejecting them forever would be worse.
      for (var i = 0; i < 15; i++) {
        buffer.setTransform(tf('map', 'base', x: 50, sec: 5000 + i));
      }
      expect(buffer.lookup('map', 'base')!.translation.x, 50);
    });

    test('a cycle is reported rather than answered inconsistently', () {
      final buffer = TfBuffer();
      buffer.setTransform(tf('a', 'b', x: 1), isStatic: true);
      buffer.setTransform(tf('b', 'a', y: 5), isStatic: true);

      // Truncating at the repeat let each direction resolve through a
      // different edge, so a -> b -> a did not return to the origin.
      expect(
          () => buffer.lookupOrThrow('a', 'b'),
          throwsA(isA<TfException>()
              .having((e) => e.message, 'message', contains('cycle'))));
      expect(buffer.lookup('a', 'b'), isNull);
    });

    test('live data is not hidden behind a static transform', () {
      final buffer = TfBuffer();
      buffer.setTransform(tf('map', 'base', x: 1), isStatic: true);
      for (var i = 0; i < 5; i++) {
        buffer.setTransform(
            tf('map', 'base', x: 100 + i.toDouble(), sec: 10 + i));
      }

      // Answering from the latched value while live samples sit unread means
      // the marker stops moving and nothing says why.
      expect(buffer.lookup('map', 'base')!.translation.x, 104);
    });

    test('a static transform still answers when there is no dynamic data', () {
      final buffer = TfBuffer();
      buffer.setTransform(tf('map', 'laser', x: 7), isStatic: true);
      expect(buffer.lookup('map', 'laser')!.translation.x, 7);
      expect(
          buffer
              .lookup('map', 'laser', time: RosTime(sec: 99999))!
              .translation
              .x,
          7);
    });
  });

  group('gimbal lock', () {
    /// Angle between two orientations, in degrees.
    double angleBetween(Quaternion a, Quaternion b) {
      final dot = (a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w).abs();
      return 2 * math.acos(dot.clamp(-1.0, 1.0)) * 180 / math.pi;
    }

    test('rpy round-trips exactly at pitch = +/- 90 degrees', () {
      // Straight up or down is not exotic: it is a mast camera, or a depth
      // sensor pointed at the floor. Clamping pitch alone left roll and yaw as
      // rounding noise, measured at up to 37 degrees of silent error.
      const cases = [
        (0.4, math.pi / 2, 1.9),
        (1.0, -math.pi / 2, 0.5),
        (0.4, math.pi / 2, -1.9),
        (-1.2, -math.pi / 2, 2.7),
        (0.0, math.pi / 2, 0.0),
      ];
      for (final c in cases) {
        final q = Quaternion.fromRpy(c.$1, c.$2, c.$3);
        final back = q.rpy;
        final again = Quaternion.fromRpy(back.roll, back.pitch, back.yaw);
        expect(angleBetween(q, again), lessThan(1e-4),
            reason: 'rpy of (${c.$1}, ${c.$2}, ${c.$3}) does not reconstruct');
        expect(back.roll, 0.0, reason: 'roll is taken as zero at the lock');
        expect(back.pitch.abs(), closeTo(math.pi / 2, 1e-9));
      }
    });

    test('near-lock still uses the ordinary decomposition', () {
      const eps = 1e-6;
      final q = Quaternion.fromRpy(0.4, math.pi / 2 - eps, 1.9);
      final back = q.rpy;
      expect(back.roll, closeTo(0.4, 1e-3));
      expect(back.yaw, closeTo(1.9, 1e-3));
    });
  });

  group('time conversion', () {
    test('negative durations keep their sign', () {
      // sec truncates toward zero while nanosec used Dart's always-positive
      // %, so the halves disagreed: -0.5 s came back as +0.5 s.
      for (final d in [
        const Duration(milliseconds: -500),
        const Duration(seconds: -1, milliseconds: -500),
        const Duration(seconds: -3),
        const Duration(milliseconds: 500),
        const Duration(seconds: 2, milliseconds: 250),
      ]) {
        expect(RosDuration.fromDart(d).toDart(), d, reason: '$d');
      }
    });

    test('pre-epoch times round-trip', () {
      for (final t in [
        DateTime.utc(1969, 12, 31, 23, 59, 59, 500),
        DateTime.utc(1969, 1, 1),
        DateTime.utc(1970, 1, 1),
        DateTime.utc(2026, 9, 10, 12, 34, 56, 789),
      ]) {
        expect(RosTime.fromDateTime(t).toDateTime().toUtc(), t.toUtc(),
            reason: '$t');
      }
    });

    test('the nanosecond remainder is never negative', () {
      final r = RosDuration.fromDart(const Duration(milliseconds: -1500));
      expect(r.nanosec, greaterThanOrEqualTo(0));
      expect(r.sec, -2);
      expect(r.nanosec, 500000000);
    });
  });

  group('Odometry covariance', () {
    test('survives a decode and re-encode', () {
      final covariance = List<double>.generate(36, (i) => i.toDouble());
      final wire = {
        'header': {'frame_id': 'odom'},
        'child_frame_id': 'base_link',
        'pose': {
          'pose': {
            'position': {'x': 1.0},
          },
          'covariance': covariance,
        },
        'twist': {
          'twist': <String, Object?>{},
          'covariance': covariance,
        },
      };

      final odom = Odometry.fromJson(wire);
      expect(odom.poseCovariance.length, 36);
      expect(odom.poseCovariance[5], 5.0);

      // Relaying used to turn "this is my uncertainty" into 36 zeros, which
      // reads downstream as perfect certainty.
      final out = odom.toJson();
      final poseOut = (out['pose']! as Map<String, Object?>)['covariance']!;
      expect((poseOut as List).cast<num>().take(6), [0, 1, 2, 3, 4, 5]);
    });

    test('a message without covariance still encodes the required 36', () {
      final odom = Odometry.fromJson(const {'child_frame_id': 'base_link'});
      final out = odom.toJson();
      // rosbridge asserts the exact length and drops the publish otherwise.
      expect(((out['pose']! as Map)['covariance']! as List).length, 36);
      expect(((out['twist']! as Map)['covariance']! as List).length, 36);
    });
  });
}
