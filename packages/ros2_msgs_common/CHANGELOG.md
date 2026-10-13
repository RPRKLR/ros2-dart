# Changelog

## 0.3.0

Requires `ros2_client` 0.3.0: the regenerated code uses its new `uint64`
encoders.

**Jazzy.** Every library now exists once per distro, under
`package:ros2_msgs_common/humble/...` and `package:ros2_msgs_common/jazzy/...`,
registered with `registerHumbleMessages()` or `registerJazzyMessages()`. Use
the one your robot runs: the distros disagree on the wire, and rosbridge
refuses a published field its distro does not define. The Jazzy set is 282
messages against Humble's 221, adds `geographic_msgs`, and gives navigation
results the `error_code` and `error_msg` Humble's lack.

The imports without a distro and `registerCommonMessages()` are Humble, as
before.

**Fixed**, by regenerating with `ros2_client` 0.3.0's emitter:

* `std_msgs/ByteMultiArray` could not be published: its `byte[]` went out as
  base64, which rosbridge accepts only for `uint8[]` and `char[]`.
* `uint64` fields at or above 2^63 keep their full range in both directions.
* A missing fixed-size array, such as a nested `UUID` or a covariance,
  decodes at its declared length instead of empty, which rosbridge refused
  to publish.

`tool/regenerate_in_docker.sh <distro>` regenerates from the official ROS
image, for a distro that is not installed locally.

## 0.2.0

Requires `ros2_client` 0.2.0: the regenerated code uses the key-aware field
decoders added there, so absent fields take the defaults their definitions
declare.

Regenerated with the fixed emitter. Fixed-size arrays now default to their
declared length — `float64[36] covariance` was `Float64List(0)`, and rosbridge
asserts the exact length and drops the publish, so every partly-filled message
containing one failed. `UUID.uuid` was zero-length rather than 16 bytes, which
every action goal uses.


## 0.1.0

Initial release.

- 221 pre-generated messages, plus their services and actions, for the ROS 2
  interface packages a robot UI usually needs: `nav2_msgs`, `control_msgs`,
  `visualization_msgs`, `lifecycle_msgs`, `diagnostic_msgs`, `tf2_msgs`,
  `action_msgs`, `shape_msgs`, `trajectory_msgs` and
  `unique_identifier_msgs`
- Complements `ros2_client` rather than duplicating it: the core types it
  already bundles — `Twist`, `Pose`, `LaserScan`, `RosImage`, `Header`,
  `OccupancyGrid` — are not re-emitted here, so neither shadows the other in
  the codec registry
- The bundled `geometry_msgs` and `std_msgs` libraries carry only the types the
  client does not provide: `Wrench`, `Polygon`, `Accel`, the
  covariance-stamped variants, the `MultiArray` family
- One library per ROS package, because ROS reuses type names across packages
  and a single barrel cannot export two `SpeedLimit` classes
- `tool/regenerate.sh` rebuilds the whole set from a sourced ROS install,
  byte-identically, with `AMENT_PREFIX_PATH` pinned to the distro so a
  workspace overlay cannot leak a private fork into a published package

Generated from ROS 2 Humble.
