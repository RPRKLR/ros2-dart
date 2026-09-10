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

  /// The message object last handed to [_ingest], compared by identity so a
  /// retained snapshot is not decoded twice.
  RosImage? _lastIngested;

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
    final rgba = _toRgba(frame);
    if (rgba == null) return;
    _decoding = true;
    try {
      final image = await _decodeRgba(rgba, frame.width, frame.height);
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _decoded?.dispose();
        _decoded = image;
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
        final image = _decoded;
        if (image == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return RawImage(image: image, fit: widget.fit);
      },
    );
  }

  static Future<ui.Image> _decodeRgba(
      Uint8List rgba, int width, int height) {
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

  /// Expands the common ROS encodings to RGBA8888.
  static Uint8List? _toRgba(RosImage frame) {
    final pixels = frame.width * frame.height;
    if (pixels == 0) return null;
    if (frame.encoding == 'rgba8') {
      return frame.data.lengthInBytes >= pixels * 4 ? frame.data : null;
    }

    final bpp = frame.bytesPerPixel;
    if (bpp == null || frame.data.lengthInBytes < pixels * bpp) return null;

    final out = Uint8List(pixels * 4);
    final src = frame.data;
    switch (frame.encoding) {
      case 'rgb8':
        for (var i = 0, o = 0, s = 0; i < pixels; i++, o += 4, s += 3) {
          out[o] = src[s];
          out[o + 1] = src[s + 1];
          out[o + 2] = src[s + 2];
          out[o + 3] = 255;
        }
      case 'bgr8':
        for (var i = 0, o = 0, s = 0; i < pixels; i++, o += 4, s += 3) {
          out[o] = src[s + 2];
          out[o + 1] = src[s + 1];
          out[o + 2] = src[s];
          out[o + 3] = 255;
        }
      case 'mono8':
        for (var i = 0, o = 0; i < pixels; i++, o += 4) {
          final v = src[i];
          out[o] = v;
          out[o + 1] = v;
          out[o + 2] = v;
          out[o + 3] = 255;
        }
      default:
        return null;
    }
    return out;
  }
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
      final frame = await codec.getNextFrame();
      codec.dispose();
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
