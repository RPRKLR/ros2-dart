import 'dart:async';

// Deprecated in Flutter 3.50 for package:material_ui, a separate copy whose
// widgets lose the theme and Material of apps still on this import.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:ros2_client/ros2_client.dart';

import '../ros_connection.dart';

/// How healthy a [RosDiagnosticEntry] is, as `diagnostic_msgs/DiagnosticStatus`
/// grades it.
enum RosDiagnosticLevel {
  ok,
  warn,
  error,

  /// The component has stopped reporting, as the robot judged it, or as
  /// [RosDiagnosticsPanel.staleAfter] did.
  stale;

  /// The level for a `DiagnosticStatus.level` byte. Anything outside the
  /// four values ROS defines is [stale]: a status nobody can read is not one
  /// to call healthy.
  static RosDiagnosticLevel fromByte(int level) => switch (level) {
        0 => ok,
        1 => warn,
        2 => error,
        _ => stale,
      };
}

/// One component's health, as [RosDiagnosticsPanel] shows it.
///
/// A plain model rather than `diagnostic_msgs/DiagnosticStatus` itself, so
/// this package does not depend on generated messages. With
/// `ros2_msgs_common` the conversion is one expression:
///
/// ```dart
/// RosDiagnosticEntry(
///   name: s.name,
///   level: RosDiagnosticLevel.fromByte(s.level),
///   message: s.message,
///   hardwareId: s.hardwareId,
///   values: [for (final kv in s.values) (key: kv.key, value: kv.value)],
/// )
/// ```
@immutable
class RosDiagnosticEntry {
  const RosDiagnosticEntry({
    required this.name,
    required this.level,
    this.message = '',
    this.hardwareId = '',
    this.values = const [],
  });

  final String name;
  final RosDiagnosticLevel level;
  final String message;
  final String hardwareId;

  /// In the order the robot sent them. A list, not a map, because
  /// `DiagnosticStatus` allows a key to repeat.
  final List<({String key, String value})> values;

  @override
  bool operator ==(Object other) =>
      other is RosDiagnosticEntry &&
      other.name == name &&
      other.level == level &&
      other.message == message &&
      other.hardwareId == hardwareId &&
      _sameValues(other.values, values);

  @override
  int get hashCode =>
      Object.hash(name, level, message, hardwareId, Object.hashAll(values));

  static bool _sameValues(List<({String key, String value})> a,
      List<({String key, String value})> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() => 'RosDiagnosticEntry($name, ${level.name}, "$message")';
}

/// The robot's health from `/diagnostics`, worst first.
///
/// Each node publishes only its *own* statuses there, so one message is
/// never the whole picture. The panel keeps every component it has heard
/// from, replaces each when it reports again, and marks one [stale] when it
/// goes quiet for [staleAfter] — the case a dead node otherwise presents as
/// its last, healthy-looking report.
///
/// [T] is the message type on [topic]; [toEntries] turns one into entries.
/// With `ros2_msgs_common`:
///
/// ```dart
/// import 'package:ros2_msgs_common/diagnostic_msgs.dart';
///
/// RosDiagnosticsPanel<DiagnosticArray>(
///   toEntries: (array) => [
///     for (final s in array.status)
///       RosDiagnosticEntry(
///         name: s.name,
///         level: RosDiagnosticLevel.fromByte(s.level),
///         message: s.message,
///         hardwareId: s.hardwareId,
///         values: [for (final kv in s.values) (key: kv.key, value: kv.value)],
///       ),
///   ],
/// )
/// ```
///
/// Point [topic] at `/diagnostics_agg` to show `diagnostic_aggregator`'s
/// grouped view instead; it uses the same message type.
///
/// Needs a [RosConnection] ancestor.
///
/// [stale]: RosDiagnosticLevel.stale
class RosDiagnosticsPanel<T> extends StatefulWidget {
  const RosDiagnosticsPanel({
    required this.toEntries,
    this.topic = '/diagnostics',
    this.staleAfter = const Duration(seconds: 5),
    this.onTap,
    this.emptyBuilder,
    super.key,
  });

  final String topic;

  /// Converts one message on [topic] into the entries it reports.
  final List<RosDiagnosticEntry> Function(T message) toEntries;

  /// How long a component may go unheard before it is shown as stale, or
  /// `null` to trust the last report forever. `diagnostic_updater` reports
  /// once a second by default, so five seconds is five missed reports.
  final Duration? staleAfter;

  /// Called when an entry is tapped, instead of expanding it.
  final ValueChanged<RosDiagnosticEntry>? onTap;

  /// Shown until the first report arrives. Defaults to a short notice.
  final WidgetBuilder? emptyBuilder;

  @override
  State<RosDiagnosticsPanel<T>> createState() => _RosDiagnosticsPanelState<T>();
}

class _Tracked {
  _Tracked(this.entry);

  RosDiagnosticEntry entry;
  bool timedOut = false;
  Timer? timer;

  RosDiagnosticLevel get level =>
      timedOut ? RosDiagnosticLevel.stale : entry.level;
}

class _RosDiagnosticsPanelState<T> extends State<RosDiagnosticsPanel<T>> {
  Ros2Client? _client;
  StreamSubscription<T>? _sub;

  /// Keyed by hardware id and name: two boards may both report "Motor".
  final Map<(String, String), _Tracked> _entries = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final client = RosConnection.of(context);
    if (!identical(client, _client)) {
      _client = client;
      _resubscribe();
    }
  }

  @override
  void didUpdateWidget(RosDiagnosticsPanel<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic != widget.topic) {
      _resubscribe();
    } else if (oldWidget.staleAfter != widget.staleAfter) {
      for (final tracked in _entries.values) {
        _arm(tracked);
      }
    }
  }

  void _resubscribe() {
    unawaited(_sub?.cancel());
    _clear();
    // Buffered, never conflated: every message carries different components,
    // so dropping one would lose them until they next report.
    //
    // JSON whatever the client's default: rosbridge 4.2.1 (Lyrical) fails to
    // convert DiagnosticStatus's `byte` level to CBOR and drops every message,
    // logging only on the robot. Diagnostics are a few hundred bytes, so
    // CBOR would save nothing anyway.
    _sub = _client!
        .subscribe<T>(widget.topic, compression: Compression.none)
        .listen(_ingest);
  }

  void _ingest(T message) {
    final entries = widget.toEntries(message);
    if (entries.isEmpty || !mounted) return;
    setState(() {
      for (final entry in entries) {
        final tracked = _entries
            .putIfAbsent((entry.hardwareId, entry.name), () => _Tracked(entry));
        tracked
          ..entry = entry
          ..timedOut = false;
        _arm(tracked);
      }
    });
  }

  /// One timer per component, reset on each report. Only components that are
  /// reporting hold one, and each fires at most once per silence.
  void _arm(_Tracked tracked) {
    tracked.timer?.cancel();
    tracked.timer = null;
    final after = widget.staleAfter;
    if (after == null) {
      tracked.timedOut = false;
      return;
    }
    tracked.timer = Timer(after, () {
      if (!mounted) return;
      setState(() => tracked.timedOut = true);
    });
  }

  void _clear() {
    for (final tracked in _entries.values) {
      tracked.timer?.cancel();
    }
    _entries.clear();
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    _clear();
    super.dispose();
  }

  /// Errors first, then the silent, then warnings: a component that stopped
  /// reporting may be the one that crashed.
  static int _rank(RosDiagnosticLevel level) => switch (level) {
        RosDiagnosticLevel.error => 0,
        RosDiagnosticLevel.stale => 1,
        RosDiagnosticLevel.warn => 2,
        RosDiagnosticLevel.ok => 3,
      };

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty) {
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text('No diagnostics received yet'));
    }
    final sorted = _entries.values.toList()
      ..sort((a, b) {
        final byLevel = _rank(a.level).compareTo(_rank(b.level));
        return byLevel != 0 ? byLevel : a.entry.name.compareTo(b.entry.name);
      });
    ValueKey<(String, String)> keyOf(_Tracked t) =>
        ValueKey((t.entry.hardwareId, t.entry.name));
    return ListView.builder(
      itemCount: sorted.length,
      // Keyed by component, and found again by key: ListView.builder matches
      // children by index unless told otherwise, so without this an expanded
      // tile collapsed, and its neighbour expanded, whenever one moved.
      findChildIndexCallback: (key) {
        final i = sorted.indexWhere((t) => keyOf(t) == key);
        return i < 0 ? null : i;
      },
      itemBuilder: (context, i) => _EntryTile(
        key: keyOf(sorted[i]),
        entry: sorted[i].entry,
        level: sorted[i].level,
        onTap: widget.onTap,
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.level,
    required this.onTap,
    super.key,
  });

  final RosDiagnosticEntry entry;

  /// The level shown, which is [RosDiagnosticLevel.stale] once the entry timed
  /// out whatever it last reported.
  final RosDiagnosticLevel level;
  final ValueChanged<RosDiagnosticEntry>? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (level) {
      RosDiagnosticLevel.ok => (Icons.check_circle, Colors.green),
      RosDiagnosticLevel.warn => (Icons.warning_amber_rounded, Colors.orange),
      RosDiagnosticLevel.error => (Icons.error, scheme.error),
      RosDiagnosticLevel.stale => (Icons.help, scheme.outline),
    };
    final message = level == RosDiagnosticLevel.stale && entry.level != level
        ? 'No report for a while. Last: ${entry.message}'
        : entry.message;
    final leading = Icon(icon, color: color, semanticLabel: level.name);
    final title = Text(entry.name);
    final subtitle = message.isEmpty ? null : Text(message);

    final tap = onTap;
    if (tap != null || (entry.values.isEmpty && entry.hardwareId.isEmpty)) {
      return ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        onTap: tap == null ? null : () => tap(entry),
      );
    }
    final keyStyle = Theme.of(context).textTheme.bodySmall;
    return ExpansionTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
      children: [
        if (entry.hardwareId.isNotEmpty)
          Text('Hardware: ${entry.hardwareId}', style: keyStyle),
        for (final kv in entry.values)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(kv.key, style: keyStyle)),
                Expanded(child: SelectableText(kv.value)),
              ],
            ),
          ),
      ],
    );
  }
}
