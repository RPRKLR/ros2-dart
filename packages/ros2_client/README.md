# ros2_client

A type-safe, streaming **ROS 2 client for Dart and Flutter**.

Talks to a robot through [`rosbridge_suite`](https://github.com/RobotWebTools/rosbridge_suite)
over a single WebSocket, so it runs everywhere Dart runs — Android, iOS, Linux,
macOS, Windows and the browser — with **no ROS installation on the client**.

```dart
final ros = Ros2Client(Uri.parse('ws://192.168.1.10:9090'));
await ros.connect();

// Typed streams, not Map<String, dynamic>.
ros.subscribe<LaserScan>('/scan', qos: QosProfile.sensorData)
   .listen((scan) => print('${scan.ranges.length} beams'));

final cmdVel = ros.advertise<Twist>('/cmd_vel');
cmdVel.publish(Twist.drive(forward: 0.2, turn: 0.1));
```

## Why another ROS package

Every ROS package on pub.dev is unmaintained, ROS 1 only, or passes untyped
maps around. This one aims at the gaps that actually bite in production:

| | Existing packages | `ros2_client` |
|---|---|---|
| Messages | `Map<String, dynamic>` | Generated value types with `==` and `toString` |
| ROS 2 actions | ✗ | Goal → feedback → result → cancel |
| QoS | ✗ | Full profiles, incl. `sensorData` preset |
| Reconnection | ✗ | Backoff + jitter, auto re-subscribe |
| Binary payloads | base64 JSON | CBOR typed arrays, zero per-element copy |
| Introspection | partial | Topics, nodes, services, actions, params |
| API style | callbacks | `Stream`s and `Future`s |

## Setup

On the robot:

```bash
sudo apt install ros-humble-rosbridge-suite
ros2 launch rosbridge_server rosbridge_websocket_launch.xml
```

In your app:

```dart
import 'package:ros2_client/ros2_client.dart';

void main() {
  registerStandardMessages(); // once, before the first subscribe
  ...
}
```

## The two things that trip everyone up

**1. QoS mismatch.** A reliable subscriber never matches a best-effort
publisher, and you receive *nothing* — no error, no warning. Sensor topics
(camera, lidar, IMU) are almost always best-effort:

```dart
ros.subscribe<LaserScan>('/scan', qos: QosProfile.sensorData);
```

Latched topics like `/map` and `/robot_description` need
`QosProfile.transientLocal`.

**2. JSON silently destroys `inf` and `nan`.** rosbridge serialises every
non-finite float as `null`, so over JSON an out-of-range lidar beam and an
invalid one become indistinguishable. Measured on the same publisher:

| Encoding | inf | nan | finite |
|---|---|---|---|
| `none` (JSON) | **0** | 26 | 289 |
| `cbor` | **16** | 10 | 289 |

JSON also base64-encodes `uint8[]`, costing 26% more bytes on the wire
(measured). So for sensor data, ask for CBOR — it is a correctness choice, not
just a performance one:

```dart
ros.subscribe<LaserScan>('/scan',
    qos: QosProfile.sensorData, compression: Compression.cbor);
```

Typed arrays then decode straight into `Uint8List` / `Float32List`.

## Features

### Topics

```dart
// Typed.
final sub = ros.subscribe<Odometry>('/odom', throttleRate: 200).listen(print);
await sub.cancel(); // unsubscribes from the bridge

// Untyped, for topics discovered at runtime.
ros.subscribeJson('/some/topic', type: 'pkg/msg/Type').listen(print);

// Publishing.
final pub = ros.advertise<Twist>('/cmd_vel');
pub.publish(Twist.stop);
pub.close();

ros.publishOnce<StringMsg>('/chatter', const StringMsg('hi'));
```

### Services

```dart
final result = await ros.callServiceJson('/add_two_ints', {'a': 2, 'b': 3});
print(result['sum']);
```

### Actions

Requires `rosbridge_suite` >= 2.0.0.

```dart
final goal = ros.sendGoal<NavigateToPoseGoal, NavFeedback, NavResult>(
  '/navigate_to_pose', myGoal, codec: navCodec);

goal.feedback.listen((f) => print('${f.distanceRemaining} m to go'));
try {
  await goal.result;
} on ActionFailedException catch (e) {
  print('goal ${e.status.name}');
}
goal.cancel();
```

### Introspection

```dart
for (final topic in await ros.listTopics()) print(topic);
print(await ros.listNodes());
print(await ros.listActionServers());

// ROS 2 parameters are node-scoped: "<node>:<param>".
await ros.setParam('/turtlesim:background_r', 255);
```

### Connection state

```dart
ros.states.listen((s) => print(s.name));  // connecting/connected/reconnecting
ros.status.listen((s) => print(s));       // diagnostics from the bridge
```

Reconnection is automatic and re-issues every subscription and advertisement.
Commands published while offline are buffered and replayed.

## Code generation

Generate Dart classes for any ROS package's `.msg`, `.srv` and `.action`
definitions, including your own:

```bash
source /opt/ros/humble/setup.bash
dart run ros2_client:generate -o lib/msgs sensor_msgs nav2_msgs my_robot_msgs
```

Then register them once at startup:

```dart
import 'msgs/generated.dart';

void main() {
  registerStandardMessages();
  registerGeneratedMessages();
  ...
}
```

Transitive dependencies are pulled in automatically — asking for `action_msgs`
also generates `unique_identifier_msgs`, because otherwise the output would not
compile. Packages are found in your sourced ROS install, or pass `--search` for
a workspace:

```bash
dart run ros2_client:generate -s ~/ws/install -o lib/msgs my_robot_msgs
```

Services and actions become fully typed, with no hand-written codecs:

```dart
final sum = await ros.callService<AddTwoIntsRequest, AddTwoIntsResponse>(
  '/add_two_ints', const AddTwoIntsRequest(a: 20, b: 22));

final goal = ros.sendGoal<NavigateToPoseGoal, NavigateToPoseFeedback,
    NavigateToPoseResult>('/navigate_to_pose', myGoal);
goal.feedback.listen((f) => print('${f.distanceRemaining} m to go'));
await goal.result;
```

The codec is resolved from the request or goal type alone, so there are no
type strings at the call site.

Generated code handles bounded/fixed arrays, constants, nested messages,
and the naming hazards: `sensor_msgs/Image` becomes `RosImage` to avoid
`material.dart`, and a constant clashing with a field (`int32 POINTS=8`
alongside `Point[] points` in `Marker`) becomes `pointsConst`.

The barrel registers everything but deliberately re-exports nothing: ROS
reuses type names across packages (`geometry_msgs/Pose` and
`turtlesim/Pose`), so import the specific library you need.

Verified on 136 messages across 12 real ROS packages, plus nav2_msgs'
11 services and 15 actions.

### Bundled types are not regenerated

`ros2_client` already ships `std_msgs`, `geometry_msgs`, `sensor_msgs` and
`nav_msgs` core types. Generating a package that references them — and almost
every package references `std_msgs/Header` — emits a reference to the bundled
class rather than a second copy:

```dart
import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;

final class Costmap implements RosMessage {
  final ros2.Header header;   // the class you already had
  ...
}
```

This is not just tidiness. Two classes registering a codec for one ROS type
name shadow each other — `MessageRegistry.byRosType` resolves to whichever
registered last — and the widgets in `ros2_flutter` are typed against the
bundled classes, so they cannot accept a generated `LaserScan`. A package whose
referenced types are *entirely* bundled is not generated at all.

The barrel is imported under a prefix, because it exports plenty of
non-message names (`Ros2Client`, `TfBuffer`, `Compression`) that a custom ROS
package is free to collide with.

Pass `--no-bundled` for a fully self-contained set that depends on nothing but
`codegen_support.dart`.

### Generating from a live robot

With `--from-robot` the definitions come from the robot's own `rosapi` node
over rosbridge, so no ROS install and no source tree are needed on the machine
you develop on:

```bash
# Exactly the types this robot is using, on its live topics and services.
dart run ros2_client:generate -o lib/msgs -r ws://robot.local:9090

# Or whole packages, including ones you have no source for.
dart run ros2_client:generate -o lib/msgs -r ws://robot.local:9090 my_robot_msgs
```

This is the mode for custom interfaces you did not write and cannot easily
check out. Messages, services and actions all come through, and nested types
are resolved recursively across package boundaries.

**`rosapi` cannot describe a type with a bounded array (`T[<=N]`) or a bounded
string (`string<=N`).** Its own parser mangles `sequence<T, N>` into the type
name `"T, N"` and then either raises internally or reports that as the type —
`shape_msgs/SolidPrimitive` and `rcl_interfaces/ParameterDescriptor` both hit
this. The generator refuses to emit a class named after a bound, names the
offending field, and lists any type that was referenced but not generated, so
a broken build is reported rather than shipped. Generate those packages from
source with `--search`.

Two other things the online path has to correct for, both verified against
rosapi 2.0.7 on Humble:

  * `rosapi` reports the IDL spelling of primitives — `double`, `float`,
    `boolean`, `octet` — where `.msg` files say `float64`, `float32`, `bool`,
    `byte`. Taken literally, every `float64` field would generate a reference
    to a nested class named `double`.
  * its constant list is not a constant list. It walks `inspect.getmembers`,
    so it returns every field name with its default value, plus `SLOT_TYPES`,
    whose value is a Python repr containing a memory address. Only names that
    are not fields survive.

## Hand-written messages

You can also register a codec by hand, which is all the generator does:

```dart
final class Waypoint implements RosMessage {
  const Waypoint(this.name, this.x, this.y);
  factory Waypoint.fromJson(Map<String, Object?> j) =>
      Waypoint(Field.asString(j['name']), Field.asDouble(j['x']),
               Field.asDouble(j['y']));
  final String name;
  final double x, y;

  @override
  String get rosType => 'my_msgs/msg/Waypoint';
  @override
  Map<String, Object?> toJson() => {'name': name, 'x': x, 'y': y};
}

MessageRegistry.register(const MessageCodec<Waypoint>(
  rosType: 'my_msgs/msg/Waypoint',
  fromJson: Waypoint.fromJson,
  toJson: _waypointToJson,
));
```

## Naming

`Image`, `Path`, `Transform` and `ConnectionState` collide with
`package:flutter/material.dart`, so they ship as `RosImage`, `RosPath`,
`RosTransform` and `RosConnectionState`. Everything else keeps its ROS name.

## Testing

```bash
dart test                    # unit tests, no ROS needed
dart test -t integration     # end-to-end against a local WebSocket server
```

## Transforms (tf2)

Frame lookups, with time interpolation and the same tree walk tf2 does:

```dart
final tf = TfListener(ros)..start();
await tf.waitForTransform('map', 'base_link');

// Where is the robot on the map?
final pose = tf.buffer.lookupOrThrow('map', 'base_link');
print('${pose.translation.x}, ${pose.translation.y}, yaw ${pose.rotation.yaw}');

// Move a lidar hit into the map frame.
final inMap = tf.buffer.transformPoint(hit, 'map', 'laser');
```

`/tf_static` is latched, so `TfListener` subscribes to it with
`transientLocal` durability — with the default profile a late-joining app
receives no static transforms at all and every fixed frame appears missing.

`lookup` returns `null` on failure; `lookupOrThrow` explains why (unknown
frame, disconnected trees, or a timestamp outside the buffered window), and
`buffer.describe()` prints the tree:

```
map
  odom  (37 samples)
    base_link  (37 samples)
      laser  (static)
```

Transform maths is available on the message types directly —
`Quaternion.fromYaw`, `.fromRpy`, `.yaw`, `.rpy`, `.slerp`, `.rotate(v)`, and
`RosTransform.compose`, `.inverse`, `.transformPoint`, `.transformPose`.

For rendering, `RosTransform.toMatrix4()` gives the 4x4 homogeneous matrix as
a **column-major** `Float64List` — the layout `Matrix4.fromFloat64List` and
OpenGL expect, so nothing needs transposing. It returns a `Float64List` rather
than a `Matrix4` to keep this package free of a `vector_math` dependency.

Flutter apps should reach for `TfFrameBuilder` in `package:ros2_flutter`
instead of driving a `TfListener` by hand: it shares one listener across the
whole widget tree and rebuilds only when the transform actually changes.

## Parameters

ROS 2 parameters belong to a node, so names are `<node>:<param>`:

```dart
await ros.setParam('/turtlesim:background_r', 255);
final value = await ros.getParam('/turtlesim:background_r'); // 255
```

`listParams()` is a different story: `rosapi` queries every node and takes 20+
seconds, and returns an empty list unless the bridge was launched with a glob:

```bash
ros2 launch rosbridge_server rosbridge_websocket_launch.xml params_glob:="[*]"
```

Prefer `getParam`/`setParam` when you know the name — they respond in
milliseconds and need no glob.

## Verified against a real robot

Tested against `rosbridge_suite` 2.0.7 on ROS 2 Humble with turtlesim:
16/16 checks pass, covering introspection, typed and custom messages,
publishing, services, actions with feedback, parameters, QoS and throttling.

```bash
dart run example/real_bridge_check.dart
```

## Status

Pre-1.0; the API may change. See [the roadmap](../../docs/ROADMAP.md).
