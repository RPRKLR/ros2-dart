import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ros2_client/ros2_client.dart';

import '../ros_stream_builder.dart';

/// Displays a `sensor_msgs/msg/CompressedImage` topic.
///
/// Prefer a `/compressed` topic over a raw one: the payload is already JPEG or
/// PNG, so it stays small on the wire and Flutter can decode it directly.
class RosCameraView extends StatelessWidget {
  const RosCameraView({
    this.topic = '/camera/image_raw/compressed',
    this.fit = BoxFit.contain,
    this.throttleRate = 100,
    this.placeholder,
    super.key,
  });

  final String topic;
  final BoxFit fit;

  /// Milliseconds between frames requested from the bridge. 100ms ≈ 10 fps,
  /// which is plenty for a monitoring UI and a large bandwidth saving.
  final int throttleRate;

  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    return RosTopicBuilder<CompressedImage>(
      topic: topic,
      // Camera topics are conventionally published best-effort (image_transport
      // does), and a reliable subscriber matches none of them: the widget would
      // sit on its placeholder forever with no error.
      qos: QosProfile.sensorData,
      throttleRate: throttleRate,
      builder: (context, image) {
        if (image == null || image.data.isEmpty) {
          return placeholder ??
              const Center(child: CircularProgressIndicator());
        }
        // Every frame is a distinct MemoryImage key, and the global
        // ImageCache keys on byte-list identity — so a video stream evicts
        // every other image the app had cached and then thrashes. A camera
        // frame is never worth re-fetching, so it does not belong in a cache
        // at all.
        return _UncachedMemoryImage(
          bytes: image.data,
          fit: fit,
          onError: (context) => Center(
            child: Text('Cannot decode ${image.format}'),
          ),
        );
      },
    );
  }
}

/// Displays a raw `sensor_msgs/msg/Image` topic.
///
/// Raw frames must be expanded to RGBA on the client, which costs real work per
/// frame, so this subscribes with [Compression.cbor] to at least receive the
/// bytes as a typed array instead of base64 JSON. Where the robot publishes a
/// `/compressed` topic, [RosCameraView] is considerably cheaper.
class RosRawImageView extends StatefulWidget {
  const RosRawImageView({
    this.topic = '/camera/image_raw',
    this.fit = BoxFit.contain,
    this.throttleRate = 200,
    super.key,
  });

  final String topic;
  final BoxFit fit;
  final int throttleRate;

  @override
  State<RosRawImageView> createState() => _RosRawImageViewState();
}

class _RosRawImageViewState extends State<RosRawImageView> {
  ui.Image? _decoded;
  bool _decoding = false;

  /// Why the latest frame could not be shown, until one can be.
  String? _error;

  /// The message object last handed to [_ingest], compared by identity so a
  /// retained snapshot is not decoded twice.
  RosImage? _lastIngested;

  /// Bumped on a topic change, so a decode of the old topic's frame that
  /// finishes afterwards is thrown away rather than shown under the new one.
  int _generation = 0;

  @override
  void didUpdateWidget(RosRawImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic != widget.topic) {
      _generation++;
      _decoded?.dispose();
      _decoded = null;
      _error = null;
      _lastIngested = null;
    }
  }

  @override
  void dispose() {
    _decoded?.dispose();
    super.dispose();
  }

  /// Decodes at most one frame at a time; frames arriving mid-decode are
  /// dropped rather than queued, which keeps latency bounded when the robot
  /// publishes faster than the device can decode.
  Future<void> _ingest(RosImage frame) async {
    if (_decoding) return;
    // `_ingest` runs from inside `build`, and its own setState triggers the
    // next build, in which StreamBuilder hands back the *same* retained
    // message. Without this the widget re-decodes one frame forever at the
    // display rate — a full-frame RGBA conversion plus a texture upload per
    // vsync, even with the robot disconnected.
    if (identical(frame, _lastIngested)) return;
    _lastIngested = frame;
    final Uint8List rgba;
    try {
      rgba = toRgba(frame);
    } on FormatException catch (e) {
      // Deferred: _ingest runs from inside build.
      scheduleMicrotask(() {
        if (mounted && e.message != _error) setState(() => _error = e.message);
      });
      return;
    }
    final generation = _generation;
    _decoding = true;
    try {
      final image = await _decodeRgba(rgba, frame.width, frame.height);
      if (!mounted || generation != _generation) {
        image.dispose();
        return;
      }
      setState(() {
        _decoded?.dispose();
        _decoded = image;
        _error = null;
      });
    } finally {
      _decoding = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RosTopicBuilder<RosImage>(
      topic: widget.topic,
      qos: QosProfile.sensorData,
      compression: Compression.cbor,
      throttleRate: widget.throttleRate,
      builder: (context, frame) {
        if (frame != null && frame.data.isNotEmpty) {
          unawaited(_ingest(frame));
        }
        final error = _error;
        if (error != null) return Center(child: Text(error));
        final image = _decoded;
        if (image == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return RawImage(image: image, fit: widget.fit);
      },
    );
  }

  static Future<ui.Image> _decodeRgba(Uint8List rgba, int width, int height) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }
}

/// Expands a raw ROS image to RGBA8888 rows, honouring `step`.
///
/// 8-bit grey and colour are shown as they are. 16-bit images and `32FC1`
/// (in practice depth) are stretched to grey between the frame's smallest and
/// largest valid value, since their units mean nothing as brightness; zero and
/// non-finite depths are drawn black. `8UC3` and `8UC4` are taken as BGR and
/// BGRA, which is how OpenCV, and so `cv_bridge`, lays them out.
///
/// Throws a [FormatException] naming the problem for an encoding it cannot
/// show, or for data that does not cover the frame.
@visibleForTesting
Uint8List toRgba(RosImage frame) {
  final width = frame.width, height = frame.height;
  final encoding = frame.encoding;
  final bpp = switch (encoding) {
    'mono8' || '8UC1' => 1,
    'mono16' || '16UC1' => 2,
    'rgb8' || 'bgr8' || '8UC3' => 3,
    'rgba8' || 'bgra8' || '8UC4' || '32FC1' => 4,
    _ => throw FormatException('Cannot display $encoding images'),
  };
  if (width <= 0 || height <= 0) {
    throw FormatException('Empty $encoding image (${width}x$height)');
  }
  // A step of 0 is common from hand-written publishers; take it as unpadded.
  final step = frame.step > 0 ? frame.step : width * bpp;
  final src = frame.data;
  if (step < width * bpp ||
      src.lengthInBytes < step * (height - 1) + width * bpp) {
    throw FormatException('Malformed $encoding image: ${src.lengthInBytes} '
        'bytes for ${width}x$height with step $step');
  }

  final out = Uint8List(width * height * 4);
  void grey(int o, int v) {
    out[o] = v;
    out[o + 1] = v;
    out[o + 2] = v;
    out[o + 3] = 255;
  }

  switch (encoding) {
    case 'mono8' || '8UC1':
      for (var y = 0, o = 0; y < height; y++) {
        for (var x = 0, s = y * step; x < width; x++, s++, o += 4) {
          grey(o, src[s]);
        }
      }
    case 'rgb8' || 'rgba8':
      for (var y = 0, o = 0; y < height; y++) {
        for (var x = 0, s = y * step; x < width; x++, s += bpp, o += 4) {
          out[o] = src[s];
          out[o + 1] = src[s + 1];
          out[o + 2] = src[s + 2];
          out[o + 3] = bpp == 4 ? src[s + 3] : 255;
        }
      }
    case 'bgr8' || '8UC3' || 'bgra8' || '8UC4':
      for (var y = 0, o = 0; y < height; y++) {
        for (var x = 0, s = y * step; x < width; x++, s += bpp, o += 4) {
          out[o] = src[s + 2];
          out[o + 1] = src[s + 1];
          out[o + 2] = src[s];
          out[o + 3] = bpp == 4 ? src[s + 3] : 255;
        }
      }
    case 'mono16' || '16UC1' || '32FC1':
      final bytes = ByteData.sublistView(src);
      final endian = frame.isBigendian != 0 ? Endian.big : Endian.little;
      final isFloat = encoding == '32FC1';
      double at(int y, int x) => isFloat
          ? bytes.getFloat32(y * step + x * 4, endian)
          : bytes.getUint16(y * step + x * 2, endian).toDouble();
      bool valid(double v) => v.isFinite && v > 0;
      var lo = double.infinity, hi = double.negativeInfinity;
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          final v = at(y, x);
          if (!valid(v)) continue;
          if (v < lo) lo = v;
          if (v > hi) hi = v;
        }
      }
      final span = hi > lo ? hi - lo : 1.0;
      for (var y = 0, o = 0; y < height; y++) {
        for (var x = 0; x < width; x++, o += 4) {
          final v = at(y, x);
          grey(o, valid(v) ? (((v - lo) / span) * 254).round() + 1 : 0);
        }
      }
  }
  return out;
}

/// Decodes and shows encoded image bytes without touching the global
/// [ImageCache].
///
/// `Image.memory` resolves through `PaintingBinding.imageCache`, whose keys
/// compare byte lists by identity — so every camera frame is a new entry,
/// retained until the 1000-entry / 100 MB LRU forces eviction. At 10 fps of
/// 640x480 that budget is gone in seconds, taking every other cached image in
/// the app with it, and the cache then thrashes continuously. A video frame is
/// never re-fetched, so caching it buys nothing.
class _UncachedMemoryImage extends StatefulWidget {
  const _UncachedMemoryImage({
    required this.bytes,
    required this.fit,
    required this.onError,
  });

  final Uint8List bytes;
  final BoxFit fit;
  final Widget Function(BuildContext context) onError;

  @override
  State<_UncachedMemoryImage> createState() => _UncachedMemoryImageState();
}

class _UncachedMemoryImageState extends State<_UncachedMemoryImage> {
  ui.Image? _image;
  bool _failed = false;
  Uint8List? _decodingBytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(_UncachedMemoryImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.bytes, widget.bytes)) _decode();
  }

  Future<void> _decode() async {
    final bytes = widget.bytes;
    // One decode in flight at a time; a frame arriving mid-decode is dropped
    // rather than queued, which keeps latency bounded when the robot
    // publishes faster than the device can decode.
    if (_decodingBytes != null) return;
    _decodingBytes = bytes;
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame;
      try {
        frame = await codec.getNextFrame();
      } finally {
        codec.dispose();
      }
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() {
        _image?.dispose();
        _image = frame.image;
        _failed = false;
      });
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      _decodingBytes = null;
      // A frame that arrived while this one was decoding left the widget
      // showing a stale image; pick up the newest bytes.
      if (mounted && !identical(widget.bytes, bytes)) unawaited(_decode());
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.onError(context);
    final image = _image;
    if (image == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return RawImage(image: image, fit: widget.fit);
  }
}
