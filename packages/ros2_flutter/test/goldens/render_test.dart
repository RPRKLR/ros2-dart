// Renders the widgets to PNGs used in the documentation, and doubles as a
// visual regression test: a change that alters what a widget looks like fails
// here until the images are regenerated deliberately.
//
//   flutter test --update-goldens test/goldens   # rewrite the images
//   flutter test test/goldens                    # check nothing drifted
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ros2_flutter/ros2_flutter.dart';

/// An in-memory transport so the screenshots need no robot and no network.
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

  void publish(String topic, Map<String, Object?> msg) =>
      // WireCodec, not jsonEncode: a scan contains `inf` for an out-of-range
      // beam and jsonEncode throws on it outright. WireCodec writes null,
      // which is exactly what a real bridge puts on the wire.
      _incoming.add(
          WireCodec.encode({'op': 'publish', 'topic': topic, 'msg': msg}));
}

/// Real glyphs instead of the test framework's placeholder boxes.
Future<void> loadRealFont() async {
  const path = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf';
  if (!File(path).existsSync()) return;
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

/// A plausible indoor lidar scan: walls, a doorway, and a few dropouts.
Map<String, Object?> roomScan() {
  const beams = 720;
  final ranges = <double>[];
  for (var i = 0; i < beams; i++) {
    final angle = -math.pi + (2 * math.pi * i) / beams;
    // A rectangular room, 6 m by 4 m, with the sensor off-centre.
    final dx = math.cos(angle);
    final dy = math.sin(angle);
    var range = 8.0;
    for (final wall in const [
      (1.0, 0.0, 3.4),
      (-1.0, 0.0, 2.6),
      (0.0, 1.0, 2.1),
      (0.0, -1.0, 1.9),
    ]) {
      final denom = wall.$1 * dx + wall.$2 * dy;
      if (denom > 1e-6) {
        final t = wall.$3 / denom;
        if (t < range) range = t;
      }
    }
    // A doorway: no return through the gap.
    if (i > 250 && i < 275) range = double.infinity;
    // A pillar.
    if (i > 480 && i < 500) range = 1.4;
    ranges.add(range);
  }
  return {
    'header': {'frame_id': 'laser'},
    'angle_min': -math.pi,
    'angle_max': math.pi,
    'angle_increment': 2 * math.pi / beams,
    'range_min': 0.1,
    'range_max': 10.0,
    'ranges': ranges,
    'intensities': const <double>[],
  };
}

void main() {
  setUpAll(() async {
    registerStandardMessages();
    await loadRealFont();
  });

  ({Ros2Client client, _Fake transport}) fake() {
    final transport = _Fake();
    return (
      client: Ros2Client(Uri.parse('ws://demo:9090'),
          transportFactory: (_) => transport,
          reconnectPolicy: ReconnectPolicy.none),
      transport: transport,
    );
  }

  Widget frame(Ros2Client client, Widget child,
          {double width = 420, double height = 420}) =>
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF2E6F9E),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: RosConnection.withClient(
          client: client,
          child: Scaffold(
            body: Center(
              child: SizedBox(width: width, height: height, child: child),
            ),
          ),
        ),
      );

  testWidgets('laser scan view', (tester) async {
    final f = fake();
    addTearDown(f.client.close);
    // 4.5 m fills the plot with a 6x4 m room rather than a dot in a
    // 10 m grid.
    await tester.pumpWidget(
        frame(f.client, const RosLaserScanView(maxRange: 4.5)));
    await tester.pump();
    f.transport.publish('/scan', roomScan());
    await tester.pump();
    await tester.pump();

    await expectLater(find.byType(RosLaserScanView),
        matchesGoldenFile('images/laser_scan_view.png'));
  });

  testWidgets('teleop joystick', (tester) async {
    final f = fake();
    addTearDown(f.client.close);
    await tester.pumpWidget(
        frame(f.client, const TeleopJoystick(size: 300), width: 340, height: 340));
    await tester.pump();
    // Held, not dragged: a completed drag releases, and release recentres the
    // knob, which would show the widget in its resting state instead.
    final centre = tester.getCenter(find.byType(TeleopJoystick));
    final gesture = await tester.startGesture(centre);
    await gesture.moveBy(const Offset(-52, -74));
    await tester.pump();
    addTearDown(() => gesture.up());

    await expectLater(find.byType(TeleopJoystick),
        matchesGoldenFile('images/teleop_joystick.png'));
  });

  testWidgets('teleop pad', (tester) async {
    final f = fake();
    addTearDown(f.client.close);
    await tester.pumpWidget(
        frame(f.client, const TeleopPad(), width: 260, height: 260));
    await tester.pump();

    await expectLater(
        find.byType(TeleopPad), matchesGoldenFile('images/teleop_pad.png'));
  });
}
