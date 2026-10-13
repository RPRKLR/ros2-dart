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
///
/// It also stops, and ignores the rest of the drag until the stick is pressed
/// again, when the app leaves the foreground or the connection is swapped for
/// another robot's.
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

class _TeleopJoystickState extends State<TeleopJoystick>
    with WidgetsBindingObserver {
  Offset _knob = Offset.zero;
  Timer? _timer;
  RosPublisher<Twist>? _publisher;
  Ros2Client? _client;
  String? _boundTopic;

  /// Set when the stick was stopped from outside the gesture. The finger may
  /// still be down, and the rest of its drag must not start the robot again:
  /// only a fresh press does.
  bool _suspended = false;

  double get _radius => widget.size / 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Backgrounding mid-drag does not reliably cancel the pointer, and without
  /// this the timer keeps driving a robot nobody is watching.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _isMoving) {
      setState(_halt);
      _publish(Twist.stop);
    }
  }

  bool get _isMoving => _timer != null || _knob != Offset.zero;

  /// Stops the repeat and centres the knob, without publishing. Callers
  /// outside a build wrap it in setState.
  void _halt() {
    _timer?.cancel();
    _timer = null;
    _suspended = true;
    _knob = Offset.zero;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bind();
  }

  @override
  void didUpdateWidget(TeleopJoystick oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic != widget.topic) _bind();
    // A held stick keeps its timer, so a new rate would wait for a release.
    if (oldWidget.publishRate != widget.publishRate && _timer != null) {
      _timer!.cancel();
      _timer = Timer.periodic(widget.publishRate, (_) => _publish(_command));
    }
  }

  /// Rebinds when the topic or the connection changes.
  ///
  /// Without this a robot-selector that swaps `topic` keeps driving the old
  /// robot while the UI names the new one, and a `RosConnection` that swaps
  /// clients leaves the stick publishing into a closed client, which drops
  /// commands silently.
  void _bind() {
    final client = RosConnection.of(context);
    if (identical(client, _client) && widget.topic == _boundTopic) return;

    // Stop the robot we are about to stop talking to, and do not carry a
    // held command over to the next one: the user aimed it at this robot.
    if (_publisher != null) {
      if (_isMoving) _halt();
      _publishTo(_publisher, Twist.stop);
      _publisher!.close();
    }
    _client = client;
    _boundTopic = widget.topic;
    // Perishable: a motion command that could not be sent must never be
    // replayed later. See Ros2Client.advertise.
    _publisher = client.advertise<Twist>(widget.topic, perishable: true);
  }

  static void _publishTo(RosPublisher<Twist>? publisher, Twist twist) {
    try {
      publisher?.publish(twist);
    } on StateError {
      // Already closed during teardown.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    // Best effort: if the socket is already gone the command is dropped, but
    // leaving a moving robot without a stop command is the worse failure.
    _publish(Twist.stop);
    _publisher?.close();
    super.dispose();
  }

  void _publish(Twist twist) => _publishTo(_publisher, twist);

  Twist get _command {
    final normalized = _knob / _radius;
    final forward =
        (widget.invertY ? normalized.dy : -normalized.dy).clamp(-1.0, 1.0);
    final turn = (-normalized.dx).clamp(-1.0, 1.0);
    return Twist.drive(
      forward: forward * widget.maxLinearSpeed,
      turn: turn * widget.maxAngularSpeed,
    );
  }

  void _onDrag(Offset local) {
    if (_suspended) return;
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
    _suspended = false;
    setState(() => _knob = Offset.zero);
    _publish(Twist.stop);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onPanStart: (d) {
        _suspended = false;
        _onDrag(d.localPosition);
      },
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
      old.knob != knob ||
      old.knobColor != knobColor ||
      old.baseColor != baseColor ||
      old.outlineColor != outlineColor;
}

/// A directional pad for precise, discrete teleoperation.
///
/// Publishes while a button is held and stops on release, like
/// [TeleopJoystick], but with exact speeds rather than proportional control.
///
/// With several buttons held, the most recently pressed one drives; lifting it
/// hands back to the one still held, and the robot stops only when none is.
/// Leaving the foreground or swapping robots stops it until the next press.
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

class _TeleopPadState extends State<TeleopPad> with WidgetsBindingObserver {
  Timer? _timer;
  RosPublisher<Twist>? _publisher;
  Ros2Client? _client;
  String? _boundTopic;

  /// The command under each finger, in press order; the last one drives.
  final _held = <int, Twist>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _held.isNotEmpty) _stopAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bind();
  }

  @override
  void didUpdateWidget(TeleopPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic != widget.topic) _bind();
    // A held button keeps its timer, so a new rate would wait for a release.
    if (oldWidget.publishRate != widget.publishRate && _timer != null) {
      _timer!.cancel();
      _timer = Timer.periodic(
          widget.publishRate, (_) => _publishTo(_publisher, _current));
    }
  }

  /// Rebinds when the topic or the connection changes.
  ///
  /// Without this a robot-selector that swaps `topic` keeps driving the old
  /// robot while the UI names the new one, and a `RosConnection` that swaps
  /// clients leaves the stick publishing into a closed client, which drops
  /// commands silently.
  void _bind() {
    final client = RosConnection.of(context);
    if (identical(client, _client) && widget.topic == _boundTopic) return;

    // Stop the robot we are about to stop talking to, and forget what was
    // held: the fingers still down were pressing for that robot.
    if (_publisher != null) _stopAll();
    _publisher?.close();
    _client = client;
    _boundTopic = widget.topic;
    // Perishable: a motion command that could not be sent must never be
    // replayed later. See Ros2Client.advertise.
    _publisher = client.advertise<Twist>(widget.topic, perishable: true);
  }

  static void _publishTo(RosPublisher<Twist>? publisher, Twist twist) {
    try {
      publisher?.publish(twist);
    } on StateError {
      // Already closed during teardown.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _publishTo(_publisher, Twist.stop);
    _publisher?.close();
    super.dispose();
  }

  Twist get _current => _held.isEmpty ? Twist.stop : _held.values.last;

  void _press(int pointer, Twist twist) {
    _held
      ..remove(pointer)
      ..[pointer] = twist;
    _publishTo(_publisher, twist);
    _timer?.cancel();
    _timer = Timer.periodic(
        widget.publishRate, (_) => _publishTo(_publisher, _current));
  }

  void _lift(int pointer) {
    // A finger the pad already let go of, after a stop or a backgrounding.
    if (_held.remove(pointer) == null) return;
    if (_held.isEmpty) {
      _stopAll();
    } else {
      _publishTo(_publisher, _current);
    }
  }

  void _stopAll() {
    _held.clear();
    _timer?.cancel();
    _timer = null;
    _publishTo(_publisher, Twist.stop);
  }

  Widget _button(IconData icon, Twist twist) => Listener(
        onPointerDown: (e) => _press(e.pointer, twist),
        onPointerUp: (e) => _lift(e.pointer),
        onPointerCancel: (e) => _lift(e.pointer),
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
                onPressed: _stopAll,
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
