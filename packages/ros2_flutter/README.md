# ros2_flutter

Flutter widgets for ROS 2, built on [`ros2_client`](../ros2_client).

Wrap your app in a `RosConnection` and the rest of the widgets find the client
themselves — no plumbing, no manual subscription lifecycle.

```dart
RosConnection(
  uri: Uri.parse('ws://192.168.1.10:9090'),
  child: Scaffold(
    body: Column(children: [
      const Expanded(child: RosCameraView()),
      const Expanded(child: RosLaserScanView()),
      RosTopicBuilder<BatteryState>(
        topic: '/battery_state',
        builder: (context, b) =>
            Text(b == null ? '—' : '${(b.percentage * 100).round()}%'),
      ),
      const TeleopJoystick(),
    ]),
  ),
)
```

## Widgets

| Widget | Purpose |
|---|---|
| `RosConnection` | Owns the client; connects on mount, closes on dispose, reconnects on app resume |
| `RosConnectionBuilder` | Rebuilds on connection state changes |
| `RosTopicBuilder<T>` | Subscribes to a topic for the widget's lifetime |
| `RosCameraView` | Renders a `CompressedImage` topic |
| `RosRawImageView` | Renders a raw `Image` topic (rgb8/bgr8/mono8/rgba8) |
| `RosLaserScanView` | Top-down lidar plot |
| `TeleopJoystick` | Analogue thumb-stick publishing `Twist` |
| `TeleopPad` | Discrete D-pad publishing `Twist` |

## Lifecycle, done properly

`RosTopicBuilder` creates its subscription in `initState` and cancels it on
dispose, so navigating away actually unsubscribes from the bridge instead of
leaking for the life of the app.

Both teleop widgets publish a zero `Twist` on release **and** on dispose, and
repeat the current command at a fixed rate while held so a watchdog-equipped
robot does not stall mid-motion.

## Testing your own app

Inject a client with a fake transport so widget tests do no network I/O:

```dart
final client = Ros2Client(
  Uri.parse('ws://fake:9090'),
  transportFactory: (_) => MyFakeTransport(),
  reconnectPolicy: ReconnectPolicy.none,
);

await tester.pumpWidget(
  RosConnection.withClient(client: client, child: const MyPanel()),
);
```

See `test/widgets_test.dart` for a complete fake transport in ~25 lines.

## Example

`example/` is a full control panel — telemetry, camera, lidar and teleop.

```bash
cd example && flutter run
```

## Status

Pre-1.0; the API may change. See [the roadmap](../../docs/ROADMAP.md).
