import 'package:meta/meta.dart';

/// What to do with messages that arrive while the consumer is busy.
///
/// A robot publishes on its own schedule. When a subscription's listener
/// cannot keep up — an `await for` doing real work per message, a widget
/// rebuilding at the display rate — Dart buffers the backlog and delivers all
/// of it later. For sensor data that is usually wrong twice over: the app
/// spends time decoding messages whose moment has passed, and then renders
/// them late.
///
/// The strategy applies to *undelivered* messages only. A consumer that keeps
/// up never sees any of this, and nothing is ever dropped on its behalf while
/// it is idle.
@immutable
final class Backpressure {
  const Backpressure._(this._kind, this.maxBuffered);

  /// Deliver everything, in order. The default, and right for commands,
  /// service-like topics, and anything where a missed message is a bug.
  static const Backpressure buffer = Backpressure._(_Kind.buffer, 0);

  /// Keep only the newest undelivered message.
  ///
  /// The right default for anything you render: a pose, a scan, a camera
  /// frame. The stale ones are never decoded at all, which is where the saving
  /// is — conflating after decode would have paid the cost already.
  static const Backpressure latest = Backpressure._(_Kind.latest, 1);

  /// Keep at most [maxBuffered] undelivered messages, discarding the oldest.
  ///
  /// For when recent history matters but unbounded history does not — a plot
  /// of the last N samples, say.
  factory Backpressure.dropOldest(int maxBuffered) {
    if (maxBuffered < 1) {
      throw ArgumentError.value(maxBuffered, 'maxBuffered', 'must be positive');
    }
    return Backpressure._(_Kind.dropOldest, maxBuffered);
  }

  final _Kind _kind;

  /// How many undelivered messages to keep; 0 means unbounded.
  final int maxBuffered;

  bool get isBuffered => _kind == _Kind.buffer;

  @override
  String toString() => switch (_kind) {
        _Kind.buffer => 'Backpressure.buffer',
        _Kind.latest => 'Backpressure.latest',
        _Kind.dropOldest => 'Backpressure.dropOldest($maxBuffered)',
      };
}

enum _Kind { buffer, latest, dropOldest }
