# ros2_msgs_common

Pre-generated Dart classes for the ROS 2 interface packages a robot UI usually
needs, so most apps never have to run the generator.

Built on [`ros2_client`](../ros2_client), and designed to *complement* it: the
core types it already bundles — `Twist`, `Pose`, `PoseStamped`, `LaserScan`,
`RosImage`, `Header`, `OccupancyGrid` — are **not** duplicated here.

## Install

```yaml
dependencies:
  ros2_client: ^0.1.0
  ros2_msgs_common: ^0.1.0
```

```dart
import 'package:ros2_client/ros2_client.dart';
import 'package:ros2_msgs_common/ros2_msgs_common.dart';
import 'package:ros2_msgs_common/nav2_msgs.dart';

void main() {
  registerStandardMessages();
  registerCommonMessages();
  runApp(const MyApp());
}
```

Import the package you need. `ros2_msgs_common.dart` exposes only
`registerCommonMessages()` and deliberately re-exports nothing: ROS reuses type
names across packages, and one barrel cannot export two `SpeedLimit` classes.

## What is in it

| Library | Classes | What it covers |
|---|---|---|
| `nav2_msgs` | 81 | Nav2: costmaps, behaviour trees, 15 navigation actions |
| `control_msgs` | 39 | ros2_control: joint trajectories, gripper commands, PID state |
| `geometry_msgs` | 25 | Everything the client does not bundle — `Polygon`, `Accel`, `Wrench`, the covariance-stamped variants |
| `std_msgs` | 23 | The remaining scalar wrappers and `MultiArray` types |
| `visualization_msgs` | 14 | `Marker`, `MarkerArray`, `InteractiveMarker` |
| `lifecycle_msgs` | 12 | Managed-node states and transitions |
| `diagnostic_msgs` | 7 | `DiagnosticArray`, `DiagnosticStatus` |
| `tf2_msgs` | 6 | `FrameGraph`, `LookupTransform`, `TF2Error` |
| `action_msgs` | 5 | `GoalInfo`, `GoalStatus`, `CancelGoal` |
| `shape_msgs` | 4 | `Mesh`, `Plane`, `SolidPrimitive` |
| `trajectory_msgs` | 4 | `JointTrajectory` and its points |
| `unique_identifier_msgs` | 1 | `UUID` |

221 messages, plus their services and actions, in about 400 KB of source.

Note that `geometry_msgs` and `std_msgs` here hold only the types
`ros2_client` does not already provide. `Twist` comes from `ros2_client`;
`Wrench` comes from here. Both are in scope at once, and neither shadows the
other — a generated class that referenced `Twist` refers to the client's.

## Regenerating

The output is committed, so nothing here needs a ROS install at build time.
To retarget a different distro or add a package:

```bash
source /opt/ros/humble/setup.bash
./tool/regenerate.sh
```

Review the diff afterwards — a distro bump can change field types.

## Provenance

Every type here comes from a stock `ros-humble-*` apt package. Nothing from a
local workspace is included, and `tool/regenerate.sh` pins
`AMENT_PREFIX_PATH` to `/opt/ros/$ROS_DISTRO` so it cannot be.

That pin matters. The generator searches `AMENT_PREFIX_PATH` in order and a
sourced workspace overlay comes *first*, so on a developer machine with a robot
workspace sourced, asking for a package the overlay also provides would quietly
bake that private fork into a package meant for pub.dev. The generator now
prints which root each package resolved from, so the provenance is visible in
the run rather than assumed.

To audit the committed output yourself:

```bash
# Every ROS type name in the package, mapped to the apt package that owns it.
grep -rhoE "'[a-z0-9_]+/(msg|srv|action)/[A-Za-z0-9_]+'" lib/src/msgs/*.dart \
  | tr -d "'" | cut -d/ -f1 | sort -u \
  | xargs -I{} sh -c 'dpkg -S /opt/ros/humble/share/{} 2>/dev/null || echo "{} NOT APT"'
```

Generated from ROS 2 Humble's `.msg`, `.srv` and `.action` definitions with
`dart run ros2_client:generate`. Those definitions are published by the ROS 2
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
