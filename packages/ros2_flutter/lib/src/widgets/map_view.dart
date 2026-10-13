import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ros2_client/ros2_client.dart';

import '../ros_connection.dart';
import 'tf_frame_builder.dart';

/// A `nav_msgs/msg/OccupancyGrid`, with the robot's pose drawn on top.
///
/// The grid is turned into an image once per map message and cached, so a
/// pan, a zoom or a moving robot repaints a single textured quad rather than
/// re-walking millions of cells every frame. Pinch, drag and the mouse wheel
/// pan and zoom.
///
/// The map is subscribed `transient_local`, as `map_server` and
/// `slam_toolbox` publish it, so a view opened long after the map was
/// published still receives it.
///
/// The robot is placed from tf (`mapFrame -> robotFrame`), and is simply not
/// drawn while that transform cannot be resolved.
///
/// ```dart
/// const RosMapView(robotFrame: 'base_footprint')
/// ```
class RosMapView extends StatefulWidget {
  const RosMapView({
    this.topic = '/map',
    this.robotFrame = 'base_link',
    this.mapFrame,
    this.freeColor = const Color(0xFFFFFFFF),
    this.occupiedColor = const Color(0xFF000000),
    this.unknownColor = const Color(0xFF9E9E9E),
    this.robotColor,
    this.backgroundColor,
    this.maxScale = 40,
    super.key,
  });

  final String topic;

  /// The frame drawn as the robot, or `null` to draw no robot.
  final String? robotFrame;

  /// The frame the map is expressed in. Defaults to the grid's
  /// `header.frame_id`, or `map` if that is empty.
  final String? mapFrame;

  /// Colour of a cell with occupancy 0. Cells between 0 and 100 blend towards
  /// [occupiedColor], which suits costmaps as well as trinary maps.
  final Color freeColor;

  /// Colour of a cell with occupancy 100.
  final Color occupiedColor;

  /// Colour of an unknown cell (-1) and of any value outside `-1..100`.
  final Color unknownColor;

  /// Defaults to the theme's primary colour.
  final Color? robotColor;

  /// Drawn behind the map. Defaults to [unknownColor], so the map's edge
  /// disappears into the background.
  final Color? backgroundColor;

  /// How far in the user can zoom, relative to the whole map fitting the view.
  final double maxScale;

  @override
  State<RosMapView> createState() => _RosMapViewState();
}

class _RosMapViewState extends State<RosMapView> {
  final _viewer = TransformationController();
  Ros2Client? _client;
  StreamSubscription<OccupancyGrid>? _sub;

  /// The image on screen, and the metadata of the grid it was drawn from. They
  /// change together: a robot placed with one map's origin over another map's
  /// image would sit in the wrong place.
  ui.Image? _image;
  MapGeometry? _geometry;
  String _gridFrame = '';

  /// Kept to redraw with new colours without waiting for the next map.
  OccupancyGrid? _lastGrid;

  /// Bumped per message, so a slow decode that finishes after a newer map has
  /// arrived is discarded instead of replacing it.
  int _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final client = RosConnection.of(context);
    if (!identical(client, _client)) {
      _client = client;
      _resubscribe();
    }
  }

  @override
  void didUpdateWidget(RosMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic != widget.topic) {
      _clear();
      _resubscribe();
    } else if (oldWidget.freeColor != widget.freeColor ||
        oldWidget.occupiedColor != widget.occupiedColor ||
        oldWidget.unknownColor != widget.unknownColor) {
      // The colours are baked into the cached image; drawing the next map
      // with them would leave the current one stale until the map changes.
      final grid = _lastGrid;
      if (grid != null) _ingest(grid);
    }
  }

  void _resubscribe() {
    unawaited(_sub?.cancel());
    _sub = _client!
        .subscribe<OccupancyGrid>(
          widget.topic,
          qos: QosProfile.transientLocal,
          compression: Compression.cbor,
          backpressure: Backpressure.latest,
        )
        .listen(_ingest);
  }

  void _ingest(OccupancyGrid grid) {
    _lastGrid = grid;
    final generation = ++_generation;
    final info = grid.info;
    final rgba = occupancyToRgba(
      grid,
      free: widget.freeColor,
      occupied: widget.occupiedColor,
      unknown: widget.unknownColor,
    );
    if (rgba == null) return;
    ui.decodeImageFromPixels(
      rgba,
      info.width,
      info.height,
      ui.PixelFormat.rgba8888,
      (image) {
        if (!mounted || generation != _generation) {
          image.dispose();
          return;
        }
        setState(() {
          _image?.dispose();
          _image = image;
          _geometry = MapGeometry(info);
          _gridFrame = grid.header.frameId;
        });
      },
    );
  }

  void _clear() {
    _generation++;
    _image?.dispose();
    _image = null;
    _geometry = null;
    _lastGrid = null;
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    _clear();
    _viewer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    final geometry = _geometry;
    final background = widget.backgroundColor ?? widget.unknownColor;
    if (image == null || geometry == null) {
      return ColoredBox(
        color: background,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    Widget paint(RosTransform? robot) => CustomPaint(
          painter: _MapPainter(
            image: image,
            geometry: geometry,
            robot: robot,
            robotColor:
                widget.robotColor ?? Theme.of(context).colorScheme.primary,
            viewer: _viewer,
          ),
          child: const SizedBox.expand(),
        );

    final robotFrame = widget.robotFrame;
    final mapFrame =
        widget.mapFrame ?? (_gridFrame.isNotEmpty ? _gridFrame : 'map');
    return ColoredBox(
      color: background,
      child: ClipRect(
        child: InteractiveViewer(
          transformationController: _viewer,
          minScale: 0.5,
          maxScale: widget.maxScale,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: robotFrame == null
              ? paint(null)
              : TfFrameBuilder(
                  targetFrame: mapFrame,
                  sourceFrame: robotFrame,
                  builder: (context, transform) => paint(transform),
                ),
        ),
      ),
    );
  }
}

/// Converts a grid to RGBA8888 rows, top row first, as `decodeImageFromPixels`
/// expects. Returns `null` for an empty grid or one whose data does not cover
/// `width * height` cells.
///
/// The grid's row 0 sits at its origin, which is the *bottom* of a map drawn
/// with +Y up, so rows are flipped on the way out.
@visibleForTesting
Uint8List? occupancyToRgba(
  OccupancyGrid grid, {
  required Color free,
  required Color occupied,
  required Color unknown,
}) {
  final width = grid.info.width;
  final height = grid.info.height;
  final cells = width * height;
  if (cells <= 0 || grid.data.length < cells) return null;

  // One RGBA entry per possible byte value, so the per-cell work is a single
  // table read. Built as bytes and viewed as words, which keeps the byte
  // order right on any host.
  final table = Uint8List(256 * 4);
  void put(int index, Color c) {
    final o = index * 4;
    table[o] = (c.r * 255).round();
    table[o + 1] = (c.g * 255).round();
    table[o + 2] = (c.b * 255).round();
    table[o + 3] = (c.a * 255).round();
  }

  for (var v = 0; v < 256; v++) {
    final value = v < 128 ? v : v - 256;
    if (value >= 0 && value <= 100) {
      put(v, Color.lerp(free, occupied, value / 100)!);
    } else {
      put(v, unknown);
    }
  }
  final lut = table.buffer.asUint32List();

  final out = Uint8List(cells * 4);
  final pixels = out.buffer.asUint32List();
  final data = grid.data;
  for (var row = 0; row < height; row++) {
    final src = row * width;
    final dst = (height - 1 - row) * width;
    for (var col = 0; col < width; col++) {
      pixels[dst + col] = lut[data[src + col] & 0xff];
    }
  }
  return out;
}

/// Converts between the map frame (metres) and image pixels (+Y down).
///
/// Not exported: it describes [RosMapView]'s drawing, not a public contract.
@visibleForTesting
class MapGeometry {
  MapGeometry(MapMetaData info)
      : resolution = info.resolution,
        width = info.width,
        height = info.height,
        originX = info.origin.position.x,
        originY = info.origin.position.y,
        originYaw = info.origin.orientation.yaw;

  final double resolution;
  final int width, height;
  final double originX, originY, originYaw;

  /// The pixel a map-frame point falls on.
  Offset toImage(double x, double y) {
    final dx = x - originX, dy = y - originY;
    final c = math.cos(originYaw), s = math.sin(originYaw);
    final gx = (c * dx + s * dy) / resolution;
    final gy = (-s * dx + c * dy) / resolution;
    return Offset(gx, height - gy);
  }

  /// A map-frame heading as an angle on the image, clockwise from +X, which is
  /// what [Canvas.rotate] takes.
  double toImageAngle(double yaw) => -(yaw - originYaw);
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.image,
    required this.geometry,
    required this.robot,
    required this.robotColor,
    required this.viewer,
  }) : super(repaint: viewer);

  final ui.Image image;
  final MapGeometry geometry;
  final RosTransform? robot;
  final Color robotColor;
  final TransformationController viewer;

  @override
  void paint(Canvas canvas, Size size) {
    final w = image.width.toDouble(), h = image.height.toDouble();
    final fit = math.min(size.width / w, size.height / h);
    canvas
      ..save()
      ..translate((size.width - w * fit) / 2, (size.height - h * fit) / 2)
      ..scale(fit);
    // Nearest-neighbour: a cell is a cell, and smoothing blurs walls into
    // grey that reads as "unknown".
    canvas.drawImage(
        image, Offset.zero, Paint()..filterQuality = FilterQuality.none);

    final pose = robot;
    if (pose != null) {
      final at = geometry.toImage(pose.translation.x, pose.translation.y);
      // Constant on screen whatever the zoom, so the robot stays visible on a
      // large map and does not swallow the map when zoomed in.
      final zoom = viewer.value.getMaxScaleOnAxis();
      final r = 9 / (fit * zoom);
      canvas
        ..translate(at.dx, at.dy)
        ..rotate(geometry.toImageAngle(pose.rotation.yaw));
      canvas.drawCircle(
          Offset.zero, r, Paint()..color = robotColor.withValues(alpha: 0.35));
      final arrow = ui.Path()
        ..moveTo(r * 1.4, 0)
        ..lineTo(-r * 0.7, -r * 0.8)
        ..lineTo(-r * 0.3, 0)
        ..lineTo(-r * 0.7, r * 0.8)
        ..close();
      canvas.drawPath(arrow, Paint()..color = robotColor);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      !identical(old.image, image) ||
      old.robot != robot ||
      old.robotColor != robotColor;
}
