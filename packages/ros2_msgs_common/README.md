# ros2_msgs_common

Pre-generated Dart classes for the ROS 2 interface packages a robot UI usually
needs, so most apps never have to run the generator.

Built on [`ros2_client`](../ros2_client), and designed to *complement* it: the
core types it already bundles — `Twist`, `Pose`, `PoseStamped`, `LaserScan`,
`RosImage`, `Header`, `OccupancyGrid` — are **not** duplicated here.

## Install

```yaml
dependencies:
  ros2_client: ^0.3.0
  ros2_msgs_common: ^0.3.0
```

```dart
import 'package:ros2_client/ros2_client.dart';
import 'package:ros2_msgs_common/ros2_msgs_common.dart';
import 'package:ros2_msgs_common/jazzy/nav2_msgs.dart';

void main() {
  registerStandardMessages();
  registerJazzyMessages();
  runApp(const MyApp());
}
```

Import the package you need, from the directory for your robot's distro.
`ros2_msgs_common.dart` exposes only the registration functions and
deliberately re-exports nothing: ROS reuses type names across packages, and one
barrel cannot export two `SpeedLimit` classes.

## Distros

| Distro | Import from | Register with |
|---|---|---|
| Humble | `package:ros2_msgs_common/humble/...` | `registerHumbleMessages()` |
| Jazzy | `package:ros2_msgs_common/jazzy/...` | `registerJazzyMessages()` |

**Pick the one your robot runs, and use only that one.** The two disagree on
the wire, and rosbridge is strict about it: a published message carrying a
field the robot's distro does not define is refused. Among the differences
that matter to an app:

- Jazzy's navigation action results carry `error_code` and `error_msg`.
  Humble's have neither, so a Humble class reading a Jazzy result loses the
  reason a goal failed.
- `FollowWaypoints` reports missed waypoints as `MissedWaypoint` objects on
  Jazzy and as indices on Humble.
- `control_msgs/JointTrajectoryControllerState` dropped `desired` and `actual`
  in Jazzy, so the Humble class cannot be published to a Jazzy robot.
- Jazzy adds 61 types, among them docking, GPS waypoints and costmap updates,
  and pulls in `geographic_msgs`.

Both sets register under the same ROS type names, so registering both leaves
whichever ran last. The imports without a distro, such as
`package:ros2_msgs_common/nav2_msgs.dart`, and `registerCommonMessages()` are
Humble, as they were before Jazzy was added.

## What is in it

| Library | Humble | Jazzy | What it covers |
|---|---|---|---|
| `nav2_msgs` | 81 | 104 | Nav2: costmaps, behaviour trees, navigation actions; Jazzy adds docking and GPS waypoints |
| `control_msgs` | 39 | 53 | ros2_control: joint trajectories, gripper commands, PID state |
| `geometry_msgs` | 25 | 25 | Everything the client does not bundle — `Polygon`, `Accel`, `Wrench`, the covariance-stamped variants |
| `geographic_msgs` | — | 24 | `GeoPoint`, `GeoPose`, for Jazzy's GPS waypoint following |
| `std_msgs` | 23 | 23 | The remaining scalar wrappers and `MultiArray` types |
| `visualization_msgs` | 14 | 14 | `Marker`, `MarkerArray`, `InteractiveMarker` |
| `lifecycle_msgs` | 12 | 12 | Managed-node states and transitions |
| `diagnostic_msgs` | 7 | 7 | `DiagnosticArray`, `DiagnosticStatus` |
| `tf2_msgs` | 6 | 6 | `FrameGraph`, `LookupTransform`, `TF2Error` |
| `action_msgs` | 5 | 5 | `GoalInfo`, `GoalStatus`, `CancelGoal` |
| `shape_msgs` | 4 | 4 | `Mesh`, `Plane`, `SolidPrimitive` |
| `trajectory_msgs` | 4 | 4 | `JointTrajectory` and its points |
| `unique_identifier_msgs` | 1 | 1 | `UUID` |

221 messages for Humble and 282 for Jazzy, plus their services and actions, in
about 900 KB of source. An app compiles only the distro it imports.

Note that `geometry_msgs` and `std_msgs` here hold only the types
`ros2_client` does not already provide. `Twist` comes from `ros2_client`;
`Wrench` comes from here. Both are in scope at once, and neither shadows the
other — a generated class that referenced `Twist` refers to the client's.

## Checking a distro against a real robot

`example/real_distro_check.dart` confirms, on a live bridge, that the robot's
distro accepts its own classes and refuses the other distro's, and that an
aborted navigation goal still carries its result:

```bash
ros2 launch rosbridge_server rosbridge_websocket_launch.xml
python3 tool/robot_fixtures/nav_result_server.py
dart run example/real_distro_check.dart ws://127.0.0.1:9090
```

It passes against rosbridge 2.0.8 on Humble and 2.7.1 on Jazzy.

## Regenerating

The output is committed, so nothing here needs a ROS install at build time.
To pick up a distro's updated definitions or add a package, from an installed
distro:

```bash
source /opt/ros/humble/setup.bash
./tool/regenerate.sh
```

or from the official ROS image, for a distro not installed here:

```bash
./tool/regenerate_in_docker.sh jazzy
```

Both routes produce the same output: Humble regenerated through Docker is
byte-identical to Humble regenerated from `/opt/ros/humble`. Review the diff
afterwards — a distro update can change field types.

## Provenance

Every type here comes from a stock `ros-humble-*` or `ros-jazzy-*` apt
package. Nothing from a
local workspace is included, and `tool/regenerate.sh` pins
`AMENT_PREFIX_PATH` to `/opt/ros/$ROS_DISTRO` so it cannot be;
`regenerate_in_docker.sh` hands it an untouched copy of the official image's.

That pin matters. The generator searches `AMENT_PREFIX_PATH` in order and a
sourced workspace overlay comes *first*, so on a developer machine with a robot
workspace sourced, asking for a package the overlay also provides would quietly
bake that private fork into a package meant for pub.dev. The generator now
prints which root each package resolved from, so the provenance is visible in
the run rather than assumed.

To audit the committed output yourself:

```bash
# Every ROS type name in the package, mapped to the apt package that owns it.
grep -rhoE "'[a-z0-9_]+/(msg|srv|action)/[A-Za-z0-9_]+'" lib/src/humble/*.dart \
  | tr -d "'" | cut -d/ -f1 | sort -u \
  | xargs -I{} sh -c 'dpkg -S /opt/ros/humble/share/{} 2>/dev/null || echo "{} NOT APT"'
```

Generated from ROS 2 Humble's and Jazzy's `.msg`, `.srv` and `.action`
definitions with `dart run ros2_client:generate`. Those definitions are published by the ROS 2
project under Apache-2.0 (and BSD-3-Clause for some packages); the generated
Dart, and this package's own code, are BSD-3-Clause. Message semantics, field
names and constants belong to their upstream authors.

## Not here

Types for your own robot's custom interfaces. Generate those:

```bash
# From source:
dart run ros2_client:generate -o lib/msgs -s ~/ws/install my_robot_msgs

# Or straight from the running robot, with no ROS install at all:
dart run ros2_client:generate -o lib/msgs -r ws://robot.local:9090 my_robot_msgs
```

They compose with this package the same way it composes with the client.
