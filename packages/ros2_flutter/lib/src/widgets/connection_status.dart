import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ros2_client/ros2_client.dart';

import '../ros_connection.dart';

/// A compact indicator of the link to the robot: a status dot, a label, and
/// the countdown to the next retry while the client is backing off.
///
/// ```dart
/// AppBar(actions: const [RosConnectionStatus()])
/// ```
///
/// Every robot UI grows one of these, and the part that is easy to get wrong
/// is the countdown: [ReconnectPolicy] backs off exponentially, so a bare
/// "Reconnecting…" leaves an operator unable to tell a retry half a second
/// away from one half a minute away, staring at a frozen screen wondering
/// whether to restart the app. The client reports the scheduled time, and the
/// per-second ticker here runs *only* while a retry is pending.
///
/// Needs a [RosConnection] ancestor.
class RosConnectionStatus extends StatefulWidget {
  const RosConnectionStatus({
    this.showLabel = true,
    this.showCountdown = true,
    this.dotSize = 10,
    this.textStyle,
    this.labelFor,
    super.key,
  });

  /// Whether to draw the text label beside the dot. With this off the widget
  /// is just the dot, for a crowded app bar.
  final bool showLabel;

  /// Whether the label carries the seconds until the next retry.
  final bool showCountdown;

  final double dotSize;
  final TextStyle? textStyle;

  /// Overrides the label text, for wording or translation.
  ///
  /// Called with the current state and, while a retry is scheduled, how long
  /// is left before it fires.
  final String Function(RosConnectionState state, Duration? untilRetry)?
      labelFor;

  @override
  State<RosConnectionStatus> createState() => _RosConnectionStatusState();
}

class _RosConnectionStatusState extends State<RosConnectionStatus> {
  Timer? _ticker;

  /// The retry this is counting toward, so a *new* retry restarts the count
  /// and a rebuild for any other reason does not.
  DateTime? _countingTo;
  Duration? _remaining;

  /// Latches onto the pending retry, and ticks it down.
  ///
  /// The remaining time is taken from the clock once, when the retry is
  /// scheduled, and decremented per tick rather than recomputed. That keeps
  /// the count monotonic across a wall-clock change — a tablet picking up NTP
  /// or crossing a timezone should not make the robot look further away.
  void _sync(DateTime? retryAt) {
    if (retryAt == _countingTo) return;
    _countingTo = retryAt;
    if (retryAt == null) {
      _remaining = null;
      _ticker?.cancel();
      _ticker = null;
      return;
    }
    final left = retryAt.difference(DateTime.now());
    _remaining = left.isNegative ? Duration.zero : left;
    // Runs only while a retry is pending: a timer ticking for the life of the
    // app would rebuild this widget once a second forever, on a healthy
    // connection, for nothing.
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        final left = (_remaining ?? Duration.zero) - const Duration(seconds: 1);
        _remaining = left.isNegative ? Duration.zero : left;
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = RosConnection.of(context);
    return RosConnectionBuilder(
      builder: (context, state) {
        // In build, but only ever starting or stopping a timer — the rebuild
        // it schedules is a frame away, never during this one.
        _sync(widget.showCountdown ? client.nextRetryAt : null);
        final untilRetry = _remaining;

        final scheme = Theme.of(context).colorScheme;
        final dot = Container(
          width: widget.dotSize,
          height: widget.dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _colorFor(state, scheme),
          ),
        );
        if (!widget.showLabel) {
          return Semantics(label: _label(state, untilRetry), child: dot);
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dot,
            const SizedBox(width: 6),
            Text(
              _label(state, untilRetry),
              style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }

  String _label(RosConnectionState state, Duration? untilRetry) {
    final custom = widget.labelFor;
    if (custom != null) return custom(state, untilRetry);
    return switch (state) {
      RosConnectionState.connected => 'Connected',
      RosConnectionState.connecting => 'Connecting…',
      RosConnectionState.reconnecting when untilRetry != null =>
        'Reconnecting in ${untilRetry.inSeconds + 1}s',
      RosConnectionState.reconnecting => 'Reconnecting…',
      RosConnectionState.disconnected => 'Offline',
      RosConnectionState.closed => 'Closed',
    };
  }

  Color _colorFor(RosConnectionState state, ColorScheme scheme) =>
      switch (state) {
        RosConnectionState.connected => const Color(0xFF2E7D32),
        RosConnectionState.connecting ||
        RosConnectionState.reconnecting =>
          const Color(0xFFF9A825),
        RosConnectionState.disconnected ||
        RosConnectionState.closed =>
          scheme.error,
      };
}
