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

  /// Matches `tf2_ros`: reliable, depth 100.
  static const QosProfile tfQos = QosProfile(depth: 100);

  /// Matches `tf2_ros`: latched, depth 100.
  ///
  /// The depth matters. `/tf_static` is normally latched by *several*
  /// independent broadcasters — the URDF publisher, each sensor driver — and a
  /// transient-local reader one deep keeps only one of their backlogs on join.
  /// The rest of the static frames then never appear at all, and
  /// [waitForFrame] times out on a frame the robot really is publishing.
  static const QosProfile tfStaticQos = QosProfile(
    depth: 100,
    durability: Durability.transientLocal,
  );

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

    // tf2 publishes /tf reliably with a deep queue; a best-effort keep-last-5
    // subscription drops transforms under load, and a dropped transform is a
    // frame that stops moving rather than an error.
    _dynamicSub = _client
        .subscribe<TFMessage>(topic, qos: tfQos)
        .listen((message) => _ingest(message, isStatic: false));

    // `/tf_static` is latched: without transient-local durability a late
    // joiner receives nothing at all and every static frame is missing.
    _staticSub = _client
        .subscribe<TFMessage>(staticTopic, qos: tfStaticQos)
        .listen((message) => _ingest(message, isStatic: true));
  }

  void _ingest(TFMessage message, {required bool isStatic}) {
    final touched = <String>{};
    for (final transform in message.transforms) {
      buffer.setTransform(transform, isStatic: isStatic);
      // Normalised, so a subscriber keying off these names sees what the
      // buffer knows rather than whatever the publisher happened to write.
      touched.add(TfBuffer.normaliseFrame(transform.childFrameId));
    }
    if (touched.isNotEmpty && !_updates.isClosed) _updates.add(touched);
  }

  /// Completes once [frame] appears in the buffer.
  ///
  /// Static transforms in particular can arrive well after connecting, so
  /// awaiting this is usually better than looking up immediately.
  Future<void> waitForFrame(String frame,
      {Duration timeout = const Duration(seconds: 10)}) async {
    // tf2 treats "/base_link" and "base_link" as one frame, and the buffer
    // normalises accordingly. Comparing the raw name here made this the only
    // API where the leading slash mattered: it blocked for the full timeout
    // on a frame the robot was publishing, then reported the stripped names
    // as "known frames", which reads like a robot-side fault.
    final wanted = TfBuffer.normaliseFrame(frame);
    if (buffer.frames.contains(wanted)) return;
    await updates
        .firstWhere((_) => buffer.frames.contains(wanted))
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
