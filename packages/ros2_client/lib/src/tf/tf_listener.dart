import 'dart:async';

import '../client.dart';
import '../messages/geometry_msgs.dart';
import '../protocol/qos.dart';
import 'tf_buffer.dart';

/// Keeps a [TfBuffer] fed from a robot's `/tf` and `/tf_static` topics.
///
/// ```dart
/// final tf = TfListener(ros)..start();
/// await tf.waitForFrame('base_link');
///
/// final t = tf.buffer.lookup('map', 'base_link');
/// print('robot at ${t?.translation}');
/// ```
final class TfListener {
  TfListener(
    this._client, {
    TfBuffer? buffer,
    this.topic = '/tf',
    this.staticTopic = '/tf_static',
  }) : buffer = buffer ?? TfBuffer();

  final Ros2Client _client;
  final TfBuffer buffer;
  final String topic;
  final String staticTopic;

  StreamSubscription<TFMessage>? _dynamicSub;
  StreamSubscription<TFMessage>? _staticSub;
  final _updates = StreamController<Set<String>>.broadcast();

  bool get isRunning => _dynamicSub != null;

  /// Frame names touched by each incoming update, for change-driven redraws.
  Stream<Set<String>> get updates => _updates.stream;

  /// Subscribes to both topics. Idempotent.
  void start() {
    if (isRunning) return;

    _dynamicSub = _client
        .subscribe<TFMessage>(topic, qos: QosProfile.sensorData)
        .listen((message) => _ingest(message, isStatic: false));

    // `/tf_static` is latched: without transient-local durability a late
    // joiner receives nothing at all and every static frame is missing.
    _staticSub = _client
        .subscribe<TFMessage>(staticTopic, qos: QosProfile.transientLocal)
        .listen((message) => _ingest(message, isStatic: true));
  }

  void _ingest(TFMessage message, {required bool isStatic}) {
    final touched = <String>{};
    for (final transform in message.transforms) {
      buffer.setTransform(transform, isStatic: isStatic);
      touched.add(transform.childFrameId);
    }
    if (touched.isNotEmpty && !_updates.isClosed) _updates.add(touched);
  }

  /// Completes once [frame] appears in the buffer.
  ///
  /// Static transforms in particular can arrive well after connecting, so
  /// awaiting this is usually better than looking up immediately.
  Future<void> waitForFrame(String frame,
      {Duration timeout = const Duration(seconds: 10)}) async {
    if (buffer.frames.contains(frame)) return;
    await updates
        .firstWhere((_) => buffer.frames.contains(frame))
        .timeout(timeout,
            onTimeout: () => throw TimeoutException(
                'Frame "$frame" did not appear within $timeout. '
                'Known frames: ${buffer.frames.join(', ')}',
                timeout));
  }

  /// Completes once a transform between the two frames can be resolved.
  Future<void> waitForTransform(String target, String source,
      {Duration timeout = const Duration(seconds: 10)}) async {
    if (buffer.canTransform(target, source)) return;
    await updates
        .firstWhere((_) => buffer.canTransform(target, source))
        .timeout(timeout,
            onTimeout: () => throw TimeoutException(
                'No transform from "$source" to "$target" within $timeout.\n'
                '${buffer.describe()}',
                timeout));
  }

  /// Unsubscribes and releases resources.
  Future<void> stop() async {
    await _dynamicSub?.cancel();
    await _staticSub?.cancel();
    _dynamicSub = null;
    _staticSub = null;
    if (!_updates.isClosed) await _updates.close();
  }
}
