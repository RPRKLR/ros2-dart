// A minimal robot control panel: live telemetry, camera, lidar and teleop.
//
// On the robot:
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml
import 'package:flutter/material.dart';
import 'package:ros2_flutter/ros2_flutter.dart';

void main() {
  registerStandardMessages();
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

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Robot'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: _ConnectionChip()),
          ),
        ],
      ),
      body: RosConnectionBuilder(
        builder: (context, state) {
          if (state != RosConnectionState.connected) {
            return const _Offline();
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 720;
              final panels = [
                const Expanded(child: _Card(title: 'Camera', child: RosCameraView())),
                const Expanded(child: _Card(title: 'Lidar', child: RosLaserScanView())),
              ];
              return Column(
                children: [
                  const _Telemetry(),
                  Expanded(
                    child: wide
                        ? Row(children: panels)
                        : Column(children: panels),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: TeleopJoystick(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ConnectionChip extends StatelessWidget {
  const _ConnectionChip();

  @override
  Widget build(BuildContext context) {
    return RosConnectionBuilder(
      builder: (context, state) {
        final (color, label) = switch (state) {
          RosConnectionState.connected => (Colors.green, 'Connected'),
          RosConnectionState.connecting => (Colors.amber, 'Connecting'),
          RosConnectionState.reconnecting => (Colors.orange, 'Reconnecting'),
          RosConnectionState.disconnected => (Colors.red, 'Offline'),
          RosConnectionState.closed => (Colors.grey, 'Closed'),
        };
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 6),
            Text(label),
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
                value: battery == null
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
