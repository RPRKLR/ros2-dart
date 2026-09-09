import 'package:flutter/widgets.dart';
import 'package:ros2_client/ros2_client.dart';

import 'ros_connection.dart';

/// Subscribes to a topic and rebuilds on each message.
///
/// The subscription is created in [State.initState] and cancelled on dispose,
/// so it is tied to the widget's lifetime rather than leaking for the life of
/// the app — the most common bug in hand-rolled ROS/Flutter glue.
///
/// ```dart
/// RosTopicBuilder<BatteryState>(
///   topic: '/battery_state',
///   builder: (context, battery) => Text(
///     battery == null ? '—' : '${(battery.percentage * 100).round()}%',
///   ),
/// )
/// ```
class RosTopicBuilder<T> extends StatefulWidget {
  const RosTopicBuilder({
    required this.topic,
    required this.builder,
    this.qos = QosProfile.default_,
    this.compression,
    this.throttleRate,
    this.initialValue,
    this.onError,
    super.key,
  });

  final String topic;

  /// Called with the latest message, or `null` before the first arrives.
  final Widget Function(BuildContext context, T? message) builder;

  final QosProfile qos;
  final Compression? compression;

  /// Server-side rate limit in milliseconds between messages.
  ///
  /// Set this for anything faster than the display refresh rate: throttling at
  /// the bridge saves bandwidth and decode time, unlike filtering on the client.
  final int? throttleRate;

  final T? initialValue;
  final void Function(Object error)? onError;

  @override
  State<RosTopicBuilder<T>> createState() => _RosTopicBuilderState<T>();
}

class _RosTopicBuilderState<T> extends State<RosTopicBuilder<T>> {
  Stream<T>? _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resubscribe();
  }

  @override
  void didUpdateWidget(RosTopicBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic != widget.topic ||
        oldWidget.qos != widget.qos ||
        oldWidget.throttleRate != widget.throttleRate) {
      _resubscribe();
    }
  }

  void _resubscribe() {
    final client = RosConnection.of(context);
    setState(() {
      _stream = client.subscribe<T>(
        widget.topic,
        qos: widget.qos,
        compression: widget.compression,
        throttleRate: widget.throttleRate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: _stream,
      initialData: widget.initialValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) widget.onError?.call(snapshot.error!);
        return widget.builder(context, snapshot.data);
      },
    );
  }
}
