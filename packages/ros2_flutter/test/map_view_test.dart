import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ros2_flutter/ros2_flutter.dart';
import 'package:ros2_flutter/src/widgets/map_view.dart';

import 'support/fake_client.dart';

/// A 3x2 grid: row 0 (the bottom of the map) is free, unknown, occupied.
Map<String, Object?> gridFrame({
  List<int> data = const [0, -1, 100, 50, 0, 0],
  int width = 3,
  int height = 2,
  String frameId = 'map',
  double originX = 0,
  double originY = 0,
}) =>
    {
      'header': {
        'stamp': {'sec': 0, 'nanosec': 0},
        'frame_id': frameId,
      },
      'info': {
        'resolution': 0.5,
        'width': width,
        'height': height,
        'origin': {
          'position': {'x': originX, 'y': originY, 'z': 0.0},
          'orientation': {'x': 0.0, 'y': 0.0, 'z': 0.0, 'w': 1.0},
        },
      },
      'data': data,
    };

Map<String, Object?> tfFrame(String parent, String child,
        {double x = 0, double y = 0}) =>
    {
      'transforms': [
        {
          'header': {
            'stamp': {'sec': 0, 'nanosec': 0},
            'frame_id': parent,
          },
          'child_frame_id': child,
          'transform': {
            'translation': {'x': x, 'y': y, 'z': 0.0},
            'rotation': {'x': 0.0, 'y': 0.0, 'z': 0.0, 'w': 1.0},
          },
        },
      ],
    };

OccupancyGrid grid(List<int> data, {int width = 3, int height = 2}) =>
    OccupancyGrid(
      info: MapMetaData(resolution: 0.5, width: width, height: height),
      data: Int8List.fromList(data),
    );

// `paints..image()` casts drawImage's arguments wrongly in this Flutter.
bool _isDrawImage(Symbol method, List<dynamic> args) => method == #drawImage;

void main() {
  setUpAll(registerStandardMessages);

  group('occupancyToRgba', () {
    const free = Color(0xFFFFFFFF);
    const occupied = Color(0xFF000000);
    const unknown = Color(0xFF808080);

    List<int> pixel(Uint8List rgba, int width, int x, int y) {
      final o = (y * width + x) * 4;
      return rgba.sublist(o, o + 4);
    }

    test('flips rows so the origin row is drawn at the bottom', () {
      final rgba = occupancyToRgba(grid([0, -1, 100, 50, 0, 0]),
          free: free, occupied: occupied, unknown: unknown)!;
      // Grid row 0 is the image's last row.
      expect(pixel(rgba, 3, 0, 1), [255, 255, 255, 255]);
      expect(pixel(rgba, 3, 1, 1), [128, 128, 128, 255]);
      expect(pixel(rgba, 3, 2, 1), [0, 0, 0, 255]);
      // Grid row 1 is the image's first row; 50 is halfway.
      expect(pixel(rgba, 3, 0, 0), [128, 128, 128, 255]);
      expect(pixel(rgba, 3, 1, 0), [255, 255, 255, 255]);
    });

    test('treats values outside -1..100 as unknown', () {
      final rgba = occupancyToRgba(
          grid([101, 127, -2, -128], width: 4, height: 1),
          free: free,
          occupied: occupied,
          unknown: unknown)!;
      for (var x = 0; x < 4; x++) {
        expect(pixel(rgba, 4, x, 0), [128, 128, 128, 255], reason: 'cell $x');
      }
    });

    test('refuses an empty grid or one with too little data', () {
      expect(
          occupancyToRgba(grid([], width: 0, height: 0),
              free: free, occupied: occupied, unknown: unknown),
          isNull);
      expect(
          occupancyToRgba(grid([0, 0, 0]),
              free: free, occupied: occupied, unknown: unknown),
          isNull);
    });
  });

  group('MapGeometry', () {
    test('places the origin at the bottom-left pixel corner', () {
      final g = MapGeometry(const MapMetaData(
          resolution: 0.5,
          width: 10,
          height: 4,
          origin: Pose(position: Point(x: -1, y: -2))));
      expect(g.toImage(-1, -2), const Offset(0, 4));
      // One metre right and up is two cells right and two rows up.
      expect(g.toImage(0, -1), const Offset(2, 2));
    });

    test('honours a rotated origin', () {
      // Origin turned 90 degrees: the grid's +X runs along the map's +Y.
      final yaw = math.pi / 2;
      final g = MapGeometry(MapMetaData(
          resolution: 1,
          width: 10,
          height: 10,
          origin: Pose(
              orientation:
                  Quaternion(z: math.sin(yaw / 2), w: math.cos(yaw / 2)))));
      final p = g.toImage(0, 3);
      expect(p.dx, closeTo(3, 1e-9));
      expect(p.dy, closeTo(10, 1e-9));
      // A robot facing map +Y faces along the grid's +X: no turn on screen.
      expect(g.toImageAngle(yaw), closeTo(0, 1e-9));
    });

    test('toMap and fromImageAngle invert toImage and toImageAngle', () {
      final yaw = 0.7;
      final g = MapGeometry(MapMetaData(
          resolution: 0.05,
          width: 400,
          height: 300,
          origin: Pose(
              position: const Point(x: -3.2, y: 7.5),
              orientation:
                  Quaternion(z: math.sin(yaw / 2), w: math.cos(yaw / 2)))));
      for (final (x, y) in [
        (0.0, 0.0),
        (-3.2, 7.5),
        (4.1, -2.9),
        (10.0, 3.3)
      ]) {
        final back = g.toMap(g.toImage(x, y));
        expect(back.x, closeTo(x, 1e-9));
        expect(back.y, closeTo(y, 1e-9));
      }
      for (final heading in [0.0, 1.0, -2.5, math.pi]) {
        expect(
            g.fromImageAngle(g.toImageAngle(heading)), closeTo(heading, 1e-9));
      }
    });
  });

  group('RosMapView', () {
    late FakeTransport transport;
    late Ros2Client client;

    setUp(() => (:client, :transport) = fakeClient());
    tearDown(() => client.close());

    Future<void> pumpView(WidgetTester tester, Widget view) async {
      await tester.pumpWidget(MaterialApp(
        home: RosConnection.withClient(client: client, child: view),
      ));
      await tester.pump();
    }

    /// Lets `decodeImageFromPixels` finish; it completes outside fake time.
    Future<void> settleDecode(WidgetTester tester) async {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }

    testWidgets('subscribes transient_local, so a late view gets the map',
        (tester) async {
      await pumpView(tester, const RosMapView(robotFrame: null));

      final sub = transport.sent
          .singleWhere((f) => f['op'] == 'subscribe' && f['topic'] == '/map');
      expect(sub['type'], 'nav_msgs/msg/OccupancyGrid');
      expect((sub['qos']! as Map)['durability'], 'transient_local');
    });

    testWidgets('shows a spinner until the map arrives, then draws it',
        (tester) async {
      await pumpView(tester, const RosMapView(robotFrame: null));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      transport.publish('/map', gridFrame());
      await tester.pump();
      await settleDecode(tester);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(InteractiveViewer),
              matching: find.byType(CustomPaint)),
          paints..something(_isDrawImage));
    });

    testWidgets('draws the robot only once tf places it', (tester) async {
      await pumpView(tester, const RosMapView());
      transport.publish('/map', gridFrame());
      await tester.pump();
      await settleDecode(tester);

      final canvas = find.descendant(
          of: find.byType(InteractiveViewer),
          matching: find.byType(CustomPaint));
      expect(
          canvas,
          isNot(paints
            ..something(_isDrawImage)
            ..circle()));

      transport.publish('/tf', tfFrame('map', 'base_link', x: 0.5, y: 0.5));
      await tester.pump();
      await tester.pump();
      expect(
          canvas,
          paints
            ..something(_isDrawImage)
            ..circle()
            ..path());
    });

    testWidgets('a newer map replaces the old one', (tester) async {
      await pumpView(tester, const RosMapView(robotFrame: null));
      transport.publish('/map', gridFrame());
      await tester.pump();
      await settleDecode(tester);
      transport.publish('/map', gridFrame(width: 6, data: List.filled(12, 0)));
      await tester.pump();
      await settleDecode(tester);

      final canvas = find.descendant(
          of: find.byType(InteractiveViewer),
          matching: find.byType(CustomPaint));
      expect(
          canvas,
          paints
            ..something((method, args) =>
                method == #drawImage && (args[0] as ui.Image).width == 6));
    });

    testWidgets('a decode still running when the topic changes is discarded',
        (tester) async {
      await pumpView(tester, const RosMapView(robotFrame: null));
      transport.publish('/map', gridFrame());
      await tester.pump();
      // The old topic's map is still decoding when the view is retargeted.
      await pumpView(
          tester, const RosMapView(topic: '/other_map', robotFrame: null));
      await settleDecode(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('unsubscribes on dispose', (tester) async {
      await pumpView(tester, const RosMapView(robotFrame: null));
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(
          transport.sent
              .where((f) => f['op'] == 'unsubscribe' && f['topic'] == '/map'),
          hasLength(1));
    });
  });

  group('RosMapView goal picker', () {
    late FakeTransport transport;
    late Ros2Client client;

    setUp(() => (:client, :transport) = fakeClient());
    tearDown(() => client.close());

    // An 8x6 grid at 0.5 m fills the 800x600 test view exactly: 100 logical
    // pixels per cell and no letterboxing, so screen (sx, sy) is map
    // (sx / 200, 3 - sy / 200).
    Future<List<PoseStamped>> pumpPicker(WidgetTester tester,
        {String? robotFrame, bool picking = true}) async {
      final goals = <PoseStamped>[];
      await tester.pumpWidget(MaterialApp(
        home: RosConnection.withClient(
          client: client,
          child: RosMapView(
            robotFrame: robotFrame,
            onGoal: picking ? goals.add : null,
          ),
        ),
      ));
      await tester.pump();
      transport.publish(
          '/map', gridFrame(width: 8, height: 6, data: List.filled(48, 0)));
      await tester.pump();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      return goals;
    }

    Future<void> pressAndDrag(WidgetTester tester, Offset from,
        [Offset by = Offset.zero]) async {
      final gesture = await tester.startGesture(from);
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      if (by != Offset.zero) {
        // In steps, as a finger moves, so the drag is not one jump.
        for (var i = 1; i <= 4; i++) {
          await gesture.moveTo(from + by * (i / 4));
          await tester.pump();
        }
      }
      await gesture.up();
      await tester.pump();
    }

    void expectGoal(PoseStamped goal, double x, double y, double yaw) {
      expect(goal.header.frameId, 'map');
      expect(goal.pose.position.x, closeTo(x, 1e-6));
      expect(goal.pose.position.y, closeTo(y, 1e-6));
      expect(goal.pose.orientation.yaw, closeTo(yaw, 1e-6));
    }

    testWidgets('a long press places a goal where it landed', (tester) async {
      final goals = await pumpPicker(tester);
      await pressAndDrag(tester, const Offset(400, 300));
      expect(goals, hasLength(1));
      expectGoal(goals.single, 2.0, 1.5, 0);
    });

    testWidgets('dragging before release aims the goal', (tester) async {
      final goals = await pumpPicker(tester);
      // Up the screen is map +Y.
      await pressAndDrag(tester, const Offset(200, 400), const Offset(0, -80));
      expectGoal(goals.single, 1.0, 1.0, math.pi / 2);

      // Down and to the left is -135 degrees.
      await pressAndDrag(tester, const Offset(600, 200), const Offset(-60, 60));
      expectGoal(goals.last, 3.0, 2.0, -3 * math.pi / 4);
    });

    testWidgets('a press without a drag faces away from the robot',
        (tester) async {
      final goals = await pumpPicker(tester, robotFrame: 'base_link');
      transport.publish('/tf', tfFrame('map', 'base_link', x: 2.0, y: 0.5));
      await tester.pump();
      await tester.pump();

      // Straight above the robot on the map.
      await pressAndDrag(tester, const Offset(400, 300));
      expectGoal(goals.single, 2.0, 1.5, math.pi / 2);
    });

    testWidgets(
        'a goal placed on a panned map lands on the map, not the screen',
        (tester) async {
      final goals = await pumpPicker(tester);
      // Pan the map 100 px right and 100 px up.
      await tester.dragFrom(const Offset(300, 300), const Offset(100, -100));
      await tester.pumpAndSettle();

      // Touch slop eats part of the drag, so read back where the pan went.
      final pan = tester
          .widget<InteractiveViewer>(find.byType(InteractiveViewer))
          .transformationController!
          .value
          .getTranslation();
      expect(pan.x, greaterThan(50), reason: 'the map did not pan');
      expect(pan.y, lessThan(-50), reason: 'the map did not pan');

      // The point that was under (400, 300) has moved with the map.
      await pressAndDrag(tester, Offset(400 + pan.x, 300 + pan.y));
      expectGoal(goals.single, 2.0, 1.5, 0);
    });

    testWidgets('draws the goal it is given, and the one being placed',
        (tester) async {
      Finder canvas() => find.descendant(
          of: find.byType(InteractiveViewer),
          matching: find.byType(CustomPaint));
      await pumpPicker(tester);
      expect(
          canvas(),
          isNot(paints
            ..something(_isDrawImage)
            ..circle()));

      final gesture = await tester.startGesture(const Offset(400, 300));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      expect(
          canvas(),
          paints
            ..something(_isDrawImage)
            ..circle());
      await gesture.up();
      await tester.pump();
      expect(
          canvas(),
          isNot(paints
            ..something(_isDrawImage)
            ..circle()));

      await tester.pumpWidget(MaterialApp(
        home: RosConnection.withClient(
          client: client,
          child: RosMapView(
            robotFrame: null,
            goal: PoseStamped(
                header: const Header(frameId: 'map'),
                pose: Pose(position: const Point(x: 1, y: 1))),
            onGoal: (_) {},
          ),
        ),
      ));
      await tester.pump();
      expect(
          canvas(),
          paints
            ..something(_isDrawImage)
            ..circle()
            ..path());

      // A goal in another frame cannot be placed without tf, so is not drawn.
      await tester.pumpWidget(MaterialApp(
        home: RosConnection.withClient(
          client: client,
          child: RosMapView(
            robotFrame: null,
            goal: const PoseStamped(header: Header(frameId: 'odom')),
            onGoal: (_) {},
          ),
        ),
      ));
      await tester.pump();
      expect(
          canvas(),
          isNot(paints
            ..something(_isDrawImage)
            ..circle()));
    });

    testWidgets('a map republished mid-press does not move the goal',
        (tester) async {
      final goals = await pumpPicker(tester);
      final gesture = await tester.startGesture(const Offset(400, 300));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));

      // SLAM grows the map on its -X side while the finger is down: a new
      // origin and a new size, so every pixel now means somewhere else.
      transport.publish(
          '/map',
          gridFrame(
              width: 12, height: 6, originX: -2, data: List.filled(72, 0)));
      await tester.pump();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();

      await gesture.up();
      await tester.pump();
      // Still where the press landed on the map it was made on.
      expectGoal(goals.single, 2.0, 1.5, 0);
    });

    testWidgets('a press off the map, in the letterbox, picks nothing',
        (tester) async {
      final goals = await pumpPicker(tester);
      // A 2:1 map in the 4:3 view: 100 px bands above and below it.
      transport.publish(
          '/map', gridFrame(width: 8, height: 4, data: List.filled(32, 0)));
      await tester.pump();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();

      await pressAndDrag(tester, const Offset(400, 50));
      expect(goals, isEmpty);
      await pressAndDrag(tester, const Offset(400, 300));
      expect(goals, hasLength(1));
    });

    testWidgets('without onGoal a long press picks nothing', (tester) async {
      await pumpPicker(tester, picking: false);
      expect(
          find.byWidgetPredicate(
              (w) => w is GestureDetector && w.onLongPressStart != null),
          findsNothing);
      // And a long press is harmless.
      await pressAndDrag(tester, const Offset(400, 300));
    });
  });
}
