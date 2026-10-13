import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ros2_flutter/ros2_flutter.dart';
import 'package:ros2_flutter/src/widgets/camera_view.dart' show toRgba;

import 'support/fake_client.dart';

Widget app(Ros2Client client, Widget child) => MaterialApp(
      home: RosConnection.withClient(
        client: client,
        child: Scaffold(body: Center(child: child)),
      ),
    );

Map<String, Object?> scanFrame(List<double?> ranges,
        {required double rangeMin, required double rangeMax}) =>
    {
      'header': {
        'stamp': {'sec': 0, 'nanosec': 0},
        'frame_id': 'laser',
      },
      'angle_min': 0.0,
      'angle_max': 1.0,
      'angle_increment': 0.1,
      'time_increment': 0.0,
      'scan_time': 0.0,
      'range_min': rangeMin,
      'range_max': rangeMax,
      'ranges': ranges,
      'intensities': <double>[],
    };

RosImage image(int width, int height, String encoding, int step, List<int> data,
        {bool bigEndian = false}) =>
    RosImage(
      width: width,
      height: height,
      encoding: encoding,
      step: step,
      isBigendian: bigEndian ? 1 : 0,
      data: Uint8List.fromList(data),
    );

Map<String, Object?> imageFrame(
        int width, int height, String encoding, int step, List<int> data) =>
    {
      'header': {
        'stamp': {'sec': 0, 'nanosec': 0},
        'frame_id': 'cam',
      },
      'height': height,
      'width': width,
      'encoding': encoding,
      'is_bigendian': 0,
      'step': step,
      'data': base64Encode(data),
    };

/// The red channel of each pixel, which for grey output is the grey level.
List<int> reds(Uint8List rgba) =>
    [for (var i = 0; i < rgba.length; i += 4) rgba[i]];

/// Counts the points a painter plots.
class _PointCounter implements Canvas {
  int points = 0;
  @override
  void drawPoints(ui.PointMode mode, List<Offset> pts, Paint paint) =>
      points += pts.length;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(registerStandardMessages);

  group('RosTopicBuilder', () {
    testWidgets('forgets the old topic\'s message when the topic changes',
        (tester) async {
      final fake = fakeClient();
      addTearDown(fake.client.close);
      var topic = '/a';
      late StateSetter setTopic;
      await tester.pumpWidget(
          app(fake.client, StatefulBuilder(builder: (context, setState) {
        setTopic = setState;
        return RosTopicBuilder<StringMsg>(
          topic: topic,
          builder: (context, m) => Text(m?.data ?? 'none'),
        );
      })));
      await tester.pump();
      fake.transport.publish('/a', {'data': 'from a'});
      await tester.pump();
      await tester.pump();
      expect(find.text('from a'), findsOneWidget);

      setTopic(() => topic = '/b');
      await tester.pump();
      await tester.pump();
      expect(find.text('none'), findsOneWidget);

      fake.transport.publish('/b', {'data': 'from b'});
      await tester.pump();
      await tester.pump();
      expect(find.text('from b'), findsOneWidget);
    });
  });

  group('RosLaserScanView', () {
    Future<int> plotted(WidgetTester tester, Map<String, Object?> scan) async {
      final fake = fakeClient();
      addTearDown(fake.client.close);
      await tester.pumpWidget(app(fake.client,
          const SizedBox(width: 200, height: 200, child: RosLaserScanView())));
      await tester.pump();
      fake.transport.publish('/scan', scan);
      await tester.pump();
      await tester.pump();
      final paint = tester.widget<CustomPaint>(find.descendant(
          of: find.byType(RosLaserScanView),
          matching: find.byType(CustomPaint)));
      final canvas = _PointCounter();
      paint.painter!.paint(canvas, const Size(200, 200));
      return canvas.points;
    }

    testWidgets('skips readings below the sensor\'s range_min', (tester) async {
      expect(
          await plotted(tester,
              scanFrame([0.05, 2.0, null], rangeMin: 0.12, rangeMax: 8)),
          1);
    });

    testWidgets('skips readings above the sensor\'s range_max', (tester) async {
      expect(
          await plotted(
              tester, scanFrame([5.0, 2.0], rangeMin: 0.1, rangeMax: 4)),
          1);
    });

    testWidgets('treats an unset range_max as no limit', (tester) async {
      expect(
          await plotted(
              tester, scanFrame([5.0, 2.0], rangeMin: 0, rangeMax: 0)),
          2);
    });
  });

  group('toRgba', () {
    test('skips row padding', () {
      // 2x2 mono8 with two bytes of padding per row.
      final out = toRgba(image(2, 2, 'mono8', 4, [10, 20, 0, 0, 30, 40, 0, 0]));
      expect(reds(out), [10, 20, 30, 40]);
    });

    test('skips row padding in colour images', () {
      final out = toRgba(image(1, 2, 'bgr8', 4, [1, 2, 3, 0, 4, 5, 6, 0]));
      expect(out, [3, 2, 1, 255, 6, 5, 4, 255]);
    });

    test('reads rgba8 with padding rather than passing it through', () {
      final out = toRgba(image(
          1, 2, 'rgba8', 8, [1, 2, 3, 4, 0, 0, 0, 0, 5, 6, 7, 8, 0, 0, 0, 0]));
      expect(out, [1, 2, 3, 4, 5, 6, 7, 8]);
    });

    test('takes step 0 as unpadded', () {
      expect(reds(toRgba(image(2, 1, 'mono8', 0, [7, 9]))), [7, 9]);
    });

    test('swizzles bgra8', () {
      expect(toRgba(image(1, 1, 'bgra8', 4, [1, 2, 3, 4])), [3, 2, 1, 4]);
    });

    test('stretches 16UC1 depth between its nearest and farthest', () {
      // 0 is "no reading" and draws black; the rest span the grey range.
      final out =
          toRgba(image(3, 1, '16UC1', 6, [0, 0, 0xe8, 0x03, 0xd0, 0x07]));
      expect(reds(out), [0, 1, 255]);
    });

    test('honours big-endian 16-bit data', () {
      final out = toRgba(
          image(2, 1, 'mono16', 4, [0x03, 0xe8, 0x07, 0xd0], bigEndian: true));
      expect(reds(out), [1, 255]);
    });

    test('stretches 32FC1 and blacks out NaN', () {
      final data = ByteData(12)
        ..setFloat32(0, 0.5, Endian.little)
        ..setFloat32(4, double.nan, Endian.little)
        ..setFloat32(8, 4.5, Endian.little);
      final out = toRgba(image(3, 1, '32FC1', 12, data.buffer.asUint8List()));
      expect(reds(out), [1, 0, 255]);
    });

    test('names an encoding it cannot show', () {
      expect(
          () => toRgba(image(1, 1, 'bayer_rggb8', 1, [0])),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', contains('bayer_rggb8'))));
    });

    test('refuses data that does not cover the frame', () {
      expect(() => toRgba(image(2, 2, 'mono8', 4, [1, 2, 3, 4, 5])),
          throwsFormatException);
    });
  });

  group('RosRawImageView', () {
    testWidgets('says why it cannot show a frame instead of spinning',
        (tester) async {
      final fake = fakeClient();
      addTearDown(fake.client.close);
      await tester.pumpWidget(app(fake.client, const RosRawImageView()));
      await tester.pump();
      fake.transport
          .publish('/camera/image_raw', imageFrame(1, 1, 'yuv422', 2, [0, 0]));
      await tester.pump();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('yuv422'), findsOneWidget);
    });

    testWidgets('drops the old topic\'s picture when the topic changes',
        (tester) async {
      final fake = fakeClient();
      addTearDown(fake.client.close);
      await tester.pumpWidget(app(fake.client, const RosRawImageView()));
      await tester.pump();
      fake.transport
          .publish('/camera/image_raw', imageFrame(1, 1, 'mono8', 1, [10]));
      for (var i = 0; i < 3; i++) {
        await tester.pump();
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)));
      }
      await tester.pump();
      expect(find.byType(RawImage), findsOneWidget);

      await tester
          .pumpWidget(app(fake.client, const RosRawImageView(topic: '/other')));
      await tester.pump();
      expect(find.byType(RawImage), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
