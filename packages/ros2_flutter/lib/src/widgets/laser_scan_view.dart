import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ros2_client/ros2_client.dart';

import '../ros_stream_builder.dart';

/// A top-down plot of a `sensor_msgs/msg/LaserScan`.
///
/// The robot sits at the centre facing +X (drawn upwards), matching REP-103.
class RosLaserScanView extends StatelessWidget {
  const RosLaserScanView({
    this.topic = '/scan',
    this.maxRange = 10.0,
    this.pointColor,
    this.gridColor,
    this.showRobot = true,
    super.key,
  });

  final String topic;

  /// Range in metres mapped to the edge of the widget.
  final double maxRange;

  final Color? pointColor;
  final Color? gridColor;
  final bool showRobot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // LaserScan is almost always published best-effort; the default reliable
    // profile would match nothing and render an empty widget forever.
    return RosTopicBuilder<LaserScan>(
      topic: topic,
      qos: QosProfile.sensorData,
      compression: Compression.cbor,
      builder: (context, scan) => CustomPaint(
        painter: _LaserScanPainter(
          scan: scan,
          maxRange: maxRange,
          pointColor: pointColor ?? scheme.primary,
          gridColor: gridColor ?? scheme.outlineVariant,
          showRobot: showRobot,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LaserScanPainter extends CustomPainter {
  _LaserScanPainter({
    required this.scan,
    required this.maxRange,
    required this.pointColor,
    required this.gridColor,
    required this.showRobot,
  });

  final LaserScan? scan;
  final double maxRange;
  final Color pointColor;
  final Color gridColor;
  final bool showRobot;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final scale = radius / maxRange;

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gridColor;
    for (var r = 1; r <= maxRange.ceil(); r++) {
      canvas.drawCircle(center, r * scale, grid);
    }
    canvas.drawLine(Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius), grid);
    canvas.drawLine(Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy), grid);

    final current = scan;
    if (current != null && current.ranges.isNotEmpty) {
      final points = <Offset>[];
      for (var i = 0; i < current.ranges.length; i++) {
        final range = current.ranges[i];
        // Out-of-range readings come through as inf or NaN and must be skipped
        // rather than plotted at the origin.
        if (!range.isFinite || range <= 0 || range > maxRange) continue;
        final angle = current.angleAt(i);
        points.add(Offset(
          center.dx - range * math.sin(angle) * scale,
          center.dy - range * math.cos(angle) * scale,
        ));
      }
      canvas.drawPoints(
        ui.PointMode.points,
        points,
        Paint()
          ..color = pointColor
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    if (showRobot) {
      final body = Paint()..color = pointColor.withValues(alpha: 0.85);
      final nose = ui.Path()
        ..moveTo(center.dx, center.dy - 10)
        ..lineTo(center.dx - 7, center.dy + 7)
        ..lineTo(center.dx + 7, center.dy + 7)
        ..close();
      canvas.drawPath(nose, body);
    }
  }

  @override
  bool shouldRepaint(_LaserScanPainter old) =>
      !identical(old.scan, scan) ||
      old.maxRange != maxRange ||
      old.pointColor != pointColor;
}
