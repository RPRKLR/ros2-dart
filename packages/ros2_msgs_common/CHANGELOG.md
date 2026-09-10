# Changelog

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
