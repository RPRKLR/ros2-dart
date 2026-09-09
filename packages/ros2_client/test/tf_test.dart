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
}
