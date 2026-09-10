import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:ros2_client/ros2_client.dart';

import '../ros_connection.dart';

/// Resolves a tf2 transform and rebuilds as the frame moves.
///
/// The transform maps points *from* [sourceFrame] *into* [targetFrame], the
/// same direction as `tf2::lookupTransform(target, source)`, so it positions
/// something known in the robot's frame onto a map:
///
/// ```dart
/// TfFrameBuilder(
///   targetFrame: 'map',
///   sourceFrame: 'base_link',
///   builder: (context, transform) {
///     if (transform == null) return const Text('waiting for tf…');
///     final p = transform.translation;
///     return Text('robot at ${p.x.toStringAsFixed(2)}, '
///         '${p.y.toStringAsFixed(2)}');
///   },
/// )
/// ```
///
/// `/tf` commonly arrives at 50-200 Hz, well above the display refresh rate.
/// Every update is resolved — a walk up the frame tree, which is cheap next to
/// the decode that already happened — but the rebuild is left to `setState`,
/// which coalesces a burst between two frames into a single rebuild. Updates
/// that leave the transform unchanged do not rebuild at all.
class TfFrameBuilder extends StatefulWidget {
  const TfFrameBuilder({
    required this.targetFrame,
    required this.sourceFrame,
    required this.builder,
    this.time,
    this.onError,
    super.key,
  });

  /// The frame to express the result in.
  final String targetFrame;

  /// The frame the result maps out of.
  final String sourceFrame;

  /// Called with the resolved transform, or `null` while it cannot be
  /// resolved — before `/tf_static` has arrived, or when the frames are not
  /// connected.
  final Widget Function(BuildContext context, RosTransform? transform) builder;

  /// The time to look up at, interpolated between samples. Defaults to the
  /// latest available.
  ///
  /// Pin this to a message's `header.stamp` to place data where the robot
  /// actually was when it was captured, rather than where it is now.
  final RosTime? time;

  /// Reports *why* a lookup fails, which is otherwise invisible: a missing
  /// frame and a disconnected tree both just render as `null`.
  ///
  /// Called only when the reason changes, not on every failed update, so it is
  /// safe to log from.
  final void Function(TfException error)? onError;

  @override
  State<TfFrameBuilder> createState() => _TfFrameBuilderState();
}

class _TfFrameBuilderState extends State<TfFrameBuilder> {
  TfListener? _listener;
  StreamSubscription<Set<String>>? _updates;
  RosTransform? _transform;
  String? _lastError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final listener = RosConnection.tfOf(context);
    if (listener != _listener) {
      _updates?.cancel();
      _listener = listener;
      _updates = listener.updates.listen((_) => _refresh());
    }
    _transform = _lookup();
  }

  @override
  void didUpdateWidget(TfFrameBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetFrame != widget.targetFrame ||
        oldWidget.sourceFrame != widget.sourceFrame ||
        oldWidget.time != widget.time) {
      _lastError = null;
      _transform = _lookup();
    }
  }

  void _refresh() {
    if (!mounted) return;
    final next = _lookup();
    if (next != _transform) setState(() => _transform = next);
  }

  RosTransform? _lookup() {
    final listener = _listener;
    if (listener == null) return null;
    try {
      final transform = listener.buffer.lookupOrThrow(
        widget.targetFrame,
        widget.sourceFrame,
        time: widget.time,
      );
      _lastError = null;
      return transform;
    } on TfException catch (error) {
      _report(error);
      return null;
    }
  }

  void _report(TfException error) {
    if (error.message == _lastError) return;
    _lastError = error.message;
    final onError = widget.onError;
    if (onError == null) return;
    // Deferred: _lookup runs during didChangeDependencies, and a callback that
    // calls setState must not fire mid-build.
    scheduleMicrotask(() {
      if (mounted) onError(error);
    });
  }

  @override
  void dispose() {
    // The listener itself belongs to the RosConnection and is shared.
    _updates?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _transform);
}
