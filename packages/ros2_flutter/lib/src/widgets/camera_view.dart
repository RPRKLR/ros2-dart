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
      throttleRate: throttleRate,
      builder: (context, image) {
        if (image == null || image.data.isEmpty) {
          return placeholder ??
              const Center(child: CircularProgressIndicator());
        }
        return Image.memory(
          image.data,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) => Center(
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
