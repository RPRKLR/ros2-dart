import 'dart:async';

/// Lifecycle of a [Ros2Client] connection.
enum RosConnectionState {
  /// No connection, and none being attempted.
  disconnected,

  /// A connection attempt is in flight.
  connecting,

  /// Connected and ready to carry traffic.
  connected,

  /// Disconnected unexpectedly; a retry is scheduled.
  reconnecting,

  /// Permanently closed by the caller. Terminal.
  closed,
}

/// A bidirectional frame transport (WebSocket today, others later).
///
/// Implementations deal only in frames; all rosbridge semantics live above
/// this interface, which is what makes a second transport (a Foxglove bridge,
/// a TCP tunnel, an in-process test double) a drop-in.
abstract interface class RosTransport {
  /// Frames arriving from the server: `String` (JSON) or `List<int>` (CBOR).
  Stream<Object> get incoming;

  /// Completes when the transport is ready to carry traffic.
  Future<void> connect();

  /// Sends a text frame.
  void send(String data);

  /// Closes the transport. Idempotent.
  Future<void> close();
}

/// Controls retry timing after an unexpected disconnect.
final class ReconnectPolicy {
  const ReconnectPolicy({
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffFactor = 2.0,
    this.maxAttempts,
    this.jitter = 0.2,
    this.stabilityWindow = const Duration(seconds: 10),
  });

  /// Never retry; surface the disconnect immediately.
  static const ReconnectPolicy none = ReconnectPolicy(maxAttempts: 0);

  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffFactor;

  /// `null` means retry forever — the right default for a robot UI that should
  /// recover on its own when the robot comes back up.
  final int? maxAttempts;

  /// Fractional randomisation (0..1) applied to each delay, so a fleet of
  /// tablets reconnecting after a robot reboot does not thunder.
  final double jitter;

  /// How long a connection must survive before the backoff counter resets.
  ///
  /// Without this, a bridge that accepts a connection and immediately drops it
  /// — a crash-looping node, or a subscription the server refuses — would be
  /// retried at [initialDelay] forever, because every successful connect
  /// resets the backoff. Holding the counter until the link has proved stable
  /// means a flapping robot still gets backed off.
  final Duration stabilityWindow;

  bool shouldRetry(int attempt) =>
      maxAttempts == null || attempt < maxAttempts!;

  /// Delay before attempt number [attempt] (0-based).
  Duration delayFor(int attempt, {double Function()? random}) {
    final base = initialDelay.inMilliseconds * _pow(backoffFactor, attempt);
    final capped = base.clamp(0, maxDelay.inMilliseconds.toDouble()).toDouble();
    final rand = (random ?? _defaultRandom)();
    final factor = 1 + (rand * 2 - 1) * jitter;
    return Duration(milliseconds: (capped * factor).round().clamp(0, 1 << 30));
  }

  static double _pow(double base, int exp) {
    var result = 1.0;
    for (var i = 0; i < exp; i++) {
      result *= base;
      if (result > 1e9) break;
    }
    return result;
  }

  static double _defaultRandom() =>
      (DateTime.now().microsecondsSinceEpoch % 1000) / 1000;
}
