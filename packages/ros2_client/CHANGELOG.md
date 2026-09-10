# Changelog

## 0.1.0

Initial release.

- Code generator (`dart run ros2_client:generate`) for `.msg`, `.srv` and
  `.action` definitions, with automatic transitive dependency resolution;
  generated services and actions register typed codecs, so `callService` and
  `sendGoal` need no type strings
- `sendGoal` takes an optional `timeout`: a goal sent to an action server that
  does not exist gets no reply at all, and would otherwise never complete
- CBOR is now the default wire encoding: rosbridge serialises non-finite floats
  as JSON `null`, so `inf` and `nan` are indistinguishable over plain JSON

- Connection management with exponential backoff, jitter, and a stability
  window so a flapping bridge is backed off rather than hammered
- Typed topic subscribe/advertise via a message codec registry
- Services, ROS 2 actions (goal/feedback/result/cancel), and parameters
- Full ROS 2 QoS profiles, including `sensorData` and `transientLocal` presets
- JSON and CBOR wire codecs; CBOR typed arrays decode without a per-element
  copy. Handles base64 `uint8[]` and message fragmentation
- Non-finite floats are encoded as `null` on the wire. `jsonEncode` throws on
  `inf`/`nan`, so republishing a `LaserScan` whose out-of-range beams are `inf`
  previously crashed
- tf2 transforms: `TfBuffer` with tree walking, time interpolation and slerp,
  `TfListener` feeding it from `/tf` and `/tf_static`, and rigid-body maths on
  the `geometry_msgs` types
- Graph introspection through `rosapi`, with timeouts sized for how slow those
  graph-wide queries actually are
- `std_msgs`, `geometry_msgs`, `sensor_msgs` and `nav_msgs` core types
