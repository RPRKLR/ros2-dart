// A robot control panel: telemetry, camera, lidar and teleop; Nav2 goals
// picked on the map; and the robot's diagnostics.
//
// On the robot:
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml
// Deprecated in Flutter 3.50 for package:material_ui, a separate copy whose
// widgets lose the theme and Material of apps still on this import.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:ros2_flutter/ros2_flutter.dart';
import 'package:ros2_msgs_common/ros2_msgs_common.dart';

import 'health.dart';
import 'navigation.dart';

void main() {
  registerStandardMessages();
  // The distro the imports in navigation.dart and health.dart name.
  registerLyricalMessages();
  runApp(const RobotApp());
}

class RobotApp extends StatelessWidget {
  const RobotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROS 2 Control Panel',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      home: RosConnection(
        // Point this at your robot.
        uri: Uri.parse('ws://127.0.0.1:9090'),
        defaultCompression: Compression.cbor,
        child: const ControlPanel(),
      ),
    );
  }
}

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  int _tab = 0;
  NavigationSession? _navigation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // One session per robot. A new robot gets a new session, and disposing
    // the old one cancels any goal the old robot was still driving to.
    final client = RosConnection.of(context);
    if (!identical(client, _navigation?.client)) {
      _navigation?.dispose();
      _navigation = NavigationSession(client);
    }
  }

  @override
  void dispose() {
    _navigation?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Robot'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: RosConnectionStatus()),
          ),
        ],
      ),
      body: RosConnectionBuilder(
        builder: (context, state) {
          if (state != RosConnectionState.connected) {
            return const _Offline();
          }
          return switch (_tab) {
            1 => NavigatePage(session: _navigation!),
            2 => const HealthPage(),
            _ => const DrivePage(),
          };
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.gamepad), label: 'Drive'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Navigate'),
          NavigationDestination(
              icon: Icon(Icons.monitor_heart), label: 'Health'),
        ],
      ),
    );
  }
}

/// Telemetry, camera, lidar, map and teleop.
class DrivePage extends StatelessWidget {
  const DrivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 720;
        final panels = [
          const Expanded(child: _Card(title: 'Camera', child: RosCameraView())),
          const Expanded(
              child: _Card(title: 'Lidar', child: RosLaserScanView())),
          const Expanded(child: _Card(title: 'Map', child: RosMapView())),
        ];
        return Column(
          children: [
            const _Telemetry(),
            Expanded(
              child: wide ? Row(children: panels) : Column(children: panels),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: TeleopJoystick(),
            ),
          ],
        );
      },
    );
  }
}

class _Offline extends StatelessWidget {
  const _Offline();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Waiting for the robot…'),
          SizedBox(height: 8),
          Text('ros2 launch rosbridge_server rosbridge_websocket_launch.xml',
              style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ],
      ),
    );
  }
}

/// Battery and odometry readouts.
class _Telemetry extends StatelessWidget {
  const _Telemetry();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: RosTopicBuilder<BatteryState>(
              topic: '/battery_state',
              builder: (context, battery) => _Stat(
                icon: Icons.battery_full,
                label: 'Battery',
                // NaN means the robot cannot measure its charge, which
                // many report; round() would throw on it mid-build.
                value: battery == null || battery.percentage.isNaN
                    ? '—'
                    : '${(battery.percentage * 100).round()}%',
              ),
            ),
          ),
          Expanded(
            child: RosTopicBuilder<Odometry>(
              topic: '/odom',
              throttleRate: 200,
              builder: (context, odom) => _Stat(
                icon: Icons.my_location,
                label: 'Position',
                value: odom == null
                    ? '—'
                    : '${odom.pose.position.x.toStringAsFixed(2)}, '
                        '${odom.pose.position.y.toStringAsFixed(2)}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
