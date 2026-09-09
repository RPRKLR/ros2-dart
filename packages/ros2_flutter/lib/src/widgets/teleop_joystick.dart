import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ros2_client/ros2_client.dart';

import '../ros_connection.dart';

/// A thumb-stick that publishes `geometry_msgs/msg/Twist` to a topic.
///
/// Two safety behaviours are built in, because both are easy to omit and
/// dangerous to get wrong:
///
///  * a zero Twist is published on release, and again on dispose, so letting go
///    or navigating away stops the robot;
///  * commands repeat at [publishRate] while held, so a robot running a
///    watchdog (most do) does not stop mid-motion.
class TeleopJoystick extends StatefulWidget {
  const TeleopJoystick({
    this.topic = '/cmd_vel',
    this.maxLinearSpeed = 0.5,
    this.maxAngularSpeed = 1.0,
    this.publishRate = const Duration(milliseconds: 100),
    this.size = 200,
    this.invertY = false,
    super.key,
  });

  final String topic;

  /// Metres per second at full forward deflection.
  final double maxLinearSpeed;

  /// Radians per second at full sideways deflection.
  final double maxAngularSpeed;

  /// How often the current command is repeated while the stick is held.
  final Duration publishRate;

  final double size;

  /// Push-up-to-reverse instead of push-up-to-go-forward.
  final bool invertY;

  @override
  State<TeleopJoystick> createState() => _TeleopJoystickState();
}

class _TeleopJoystickState extends State<TeleopJoystick> {
  Offset _knob = Offset.zero;
  Timer? _timer;
  RosPublisher<Twist>? _publisher;

  double get _radius => widget.size / 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _publisher ??= RosConnection.of(context).advertise<Twist>(widget.topic);
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Best effort: if the socket is already gone the command is dropped, but
    // leaving a moving robot without a stop command is the worse failure.
    _publish(Twist.stop);
    _publisher?.close();
    super.dispose();
  }

  void _publish(Twist twist) {
    try {
      _publisher?.publish(twist);
    } on StateError {
      // Publisher closed during teardown.
    }
  }

  Twist get _command {
    final normalized = _knob / _radius;
    final forward = (widget.invertY ? normalized.dy : -normalized.dy)
        .clamp(-1.0, 1.0);
    final turn = (-normalized.dx).clamp(-1.0, 1.0);
    return Twist.drive(
      forward: forward * widget.maxLinearSpeed,
      turn: turn * widget.maxAngularSpeed,
    );
  }

  void _onDrag(Offset local) {
    final center = Offset(_radius, _radius);
    var delta = local - center;
    if (delta.distance > _radius) {
      delta = delta / delta.distance * _radius;
    }
    setState(() => _knob = delta);
    _timer ??= Timer.periodic(widget.publishRate, (_) => _publish(_command));
    _publish(_command);
  }

  void _onRelease() {
    _timer?.cancel();
    _timer = null;
    setState(() => _knob = Offset.zero);
    _publish(Twist.stop);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onPanStart: (d) => _onDrag(d.localPosition),
      onPanUpdate: (d) => _onDrag(d.localPosition),
      onPanEnd: (_) => _onRelease(),
      onPanCancel: _onRelease,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _JoystickPainter(
            knob: _knob,
            radius: _radius,
            baseColor: scheme.surfaceContainerHighest,
            knobColor: scheme.primary,
            outlineColor: scheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  _JoystickPainter({
    required this.knob,
    required this.radius,
    required this.baseColor,
    required this.knobColor,
    required this.outlineColor,
  });

  final Offset knob;
  final double radius;
  final Color baseColor;
  final Color knobColor;
  final Color outlineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(radius, radius);
    canvas
      ..drawCircle(center, radius, Paint()..color = baseColor)
      ..drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = outlineColor)
      ..drawCircle(center + knob, radius * 0.32, Paint()..color = knobColor);
  }

  @override
  bool shouldRepaint(_JoystickPainter old) =>
      old.knob != knob || old.knobColor != knobColor;
}

/// A directional pad for precise, discrete teleoperation.
///
/// Publishes while a button is held and stops on release, like
/// [TeleopJoystick], but with exact speeds rather than proportional control.
class TeleopPad extends StatefulWidget {
  const TeleopPad({
    this.topic = '/cmd_vel',
    this.linearSpeed = 0.25,
    this.angularSpeed = 0.6,
    this.publishRate = const Duration(milliseconds: 100),
    super.key,
  });

  final String topic;
  final double linearSpeed;
  final double angularSpeed;
  final Duration publishRate;

  @override
  State<TeleopPad> createState() => _TeleopPadState();
}

class _TeleopPadState extends State<TeleopPad> {
  Timer? _timer;
  RosPublisher<Twist>? _publisher;
  Twist _current = Twist.stop;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _publisher ??= RosConnection.of(context).advertise<Twist>(widget.topic);
  }

  @override
  void dispose() {
    _timer?.cancel();
    try {
      _publisher?.publish(Twist.stop);
    } on StateError {
      // Already torn down.
    }
    _publisher?.close();
    super.dispose();
  }

  void _hold(Twist twist) {
    _current = twist;
    _publisher?.publish(twist);
    _timer?.cancel();
    _timer = Timer.periodic(widget.publishRate, (_) => _publisher?.publish(_current));
  }

  void _release() {
    _timer?.cancel();
    _timer = null;
    _current = Twist.stop;
    _publisher?.publish(Twist.stop);
  }

  Widget _button(IconData icon, Twist twist) => Listener(
        onPointerDown: (_) => _hold(twist),
        onPointerUp: (_) => _release(),
        onPointerCancel: (_) => _release(),
        child: IconButton.filledTonal(
          onPressed: () {},
          icon: Icon(icon),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final v = widget.linearSpeed;
    final w = widget.angularSpeed;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(Icons.arrow_upward, Twist.drive(forward: v)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _button(Icons.rotate_left, Twist.drive(turn: w)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton.filled(
                onPressed: _release,
                icon: const Icon(Icons.stop),
              ),
            ),
            _button(Icons.rotate_right, Twist.drive(turn: -w)),
          ],
        ),
        _button(Icons.arrow_downward, Twist.drive(forward: -v)),
      ],
    );
  }
}
