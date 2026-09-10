// Renders the frame sequences that become the animated GIFs in the docs.
//
//   flutter test --update-goldens test/goldens/animation_test.dart
//   ./tool/make_gifs.sh
//
// Kept separate from render_test.dart because these are build artefacts for
// the documentation, not visual regression baselines: 24 frames of a moving
// robot would fail on any harmless anti-aliasing difference.
@Tags(['animation'])
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ros2_flutter/ros2_flutter.dart';

import 'render_test.dart' show loadRealFont;

const frames = 24;

final class _Fake implements RosTransport {
  final _incoming = StreamController<Object>.broadcast();
  @override
  Stream<Object> get incoming => _incoming.stream;
  @override
  Future<void> connect() async {}
  @override
  void send(String data) {}
  @override
  Future<void> close() async {
    if (!_incoming.isClosed) await _incoming.close();
  }

  void publish(String topic, Map<String, Object?> msg) => _incoming
      .add(WireCodec.encode({'op': 'publish', 'topic': topic, 'msg': msg}));
}

/// A lidar scan of a room, taken from [x], [y] with the sensor rotated by
/// [heading] — so a sequence of these looks like a robot driving through it.
Map<String, Object?> scanFrom(double x, double y, double heading) {
  const beams = 540;
  const walls = [
    (1.0, 0.0, 3.0),
    (-1.0, 0.0, 3.0),
    (0.0, 1.0, 2.2),
    (0.0, -1.0, 2.2),
  ];
  final ranges = <double>[];
  for (var i = 0; i < beams; i++) {
    final angle = -math.pi + (2 * math.pi * i) / beams + heading;
    final dx = math.cos(angle);
    final dy = math.sin(angle);
    var range = 12.0;
    for (final wall in walls) {
      // Distance from (x, y) to the wall along the beam.
      final denom = wall.$1 * dx + wall.$2 * dy;
      if (denom > 1e-6) {
        final t = (wall.$3 - (wall.$1 * x + wall.$2 * y)) / denom;
        if (t > 0 && t < range) range = t;
      }
    }
    // A doorway in the north wall, and a pillar the robot passes.
    final worldAngle = math.atan2(dy, dx);
    if (worldAngle > 1.35 && worldAngle < 1.55) range = double.infinity;
    final px = 1.2 - x;
    final py = 0.8 - y;
    final toPillar = math.atan2(py, px);
    if ((worldAngle - toPillar).abs() < 0.16) {
      final d = math.sqrt(px * px + py * py);
      if (d < range) range = d;
    }
    ranges.add(range);
  }
  return {
    'header': {'frame_id': 'laser'},
    'angle_min': -math.pi,
    'angle_max': math.pi,
    'angle_increment': 2 * math.pi / beams,
    'range_min': 0.1,
    'range_max': 12.0,
    'ranges': ranges,
    'intensities': const <double>[],
  };
}

void main() {
  setUpAll(() async {
    registerStandardMessages();
    await loadRealFont();
  });

  testWidgets('scan sequence', (tester) async {
    final transport = _Fake();
    final client = Ros2Client(Uri.parse('ws://demo:9090'),
        transportFactory: (_) => transport,
        reconnectPolicy: ReconnectPolicy.none);
    addTearDown(client.close);

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorSchemeSeed: const Color(0xFF2E6F9E),
          fontFamily: 'Roboto',
          useMaterial3: true),
      home: RosConnection.withClient(
        client: client,
        child: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: RosLaserScanView(maxRange: 5.0),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    for (var i = 0; i < frames; i++) {
      final t = i / frames;
      // A slow loop around the room.
      final x = 1.4 * math.sin(2 * math.pi * t);
      final y = 0.9 * math.sin(4 * math.pi * t);
      transport.publish('/scan', scanFrom(x, y, 0.5 * math.sin(2 * math.pi * t)));
      await tester.pump();
      await tester.pump();
      await expectLater(find.byType(RosLaserScanView),
          matchesGoldenFile('frames/scan_${i.toString().padLeft(2, '0')}.png'));
    }
  });

  testWidgets('joystick sequence', (tester) async {
    final transport = _Fake();
    final client = Ros2Client(Uri.parse('ws://demo:9090'),
        transportFactory: (_) => transport,
        reconnectPolicy: ReconnectPolicy.none);
    addTearDown(client.close);

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorSchemeSeed: const Color(0xFF2E6F9E),
          fontFamily: 'Roboto',
          useMaterial3: true),
      home: RosConnection.withClient(
        client: client,
        child: const Scaffold(
          body: Center(
            child: SizedBox(
                width: 300, height: 300, child: TeleopJoystick(size: 260)),
          ),
        ),
      ),
    ));
    await tester.pump();

    final centre = tester.getCenter(find.byType(TeleopJoystick));
    final gesture = await tester.startGesture(centre);
    var previous = Offset.zero;
    for (var i = 0; i < frames; i++) {
      final t = i / frames;
      // Forward, then a turn, then back to centre.
      final target = Offset(
        70 * math.sin(2 * math.pi * t),
        -80 * math.sin(math.pi * t),
      );
      await gesture.moveBy(target - previous);
      previous = target;
      await tester.pump();
      await expectLater(
          find.byType(TeleopJoystick),
          matchesGoldenFile(
              'frames/stick_${i.toString().padLeft(2, '0')}.png'));
    }
    await gesture.up();
  });
}
