// The robot's /diagnostics, through RosDiagnosticsPanel.
// Deprecated in Flutter 3.50 for package:material_ui, a separate copy whose
// widgets lose the theme and Material of apps still on this import.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:ros2_flutter/ros2_flutter.dart';
// The same distro as navigation.dart; diagnostic_msgs is identical in all.
import 'package:ros2_msgs_common/lyrical/diagnostic_msgs.dart';

/// `RosDiagnosticsPanel` takes its own plain model, so `ros2_flutter` does
/// not depend on generated messages. This is the whole adapter.
List<RosDiagnosticEntry> diagnosticEntries(DiagnosticArray array) => [
      for (final s in array.status)
        RosDiagnosticEntry(
          name: s.name,
          level: RosDiagnosticLevel.fromByte(s.level),
          message: s.message,
          hardwareId: s.hardwareId,
          values: [for (final kv in s.values) (key: kv.key, value: kv.value)],
        ),
    ];

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RosDiagnosticsPanel<DiagnosticArray>(
      toEntries: diagnosticEntries,
    );
  }
}
