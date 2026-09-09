# Changelog

## 0.1.0

Initial release.

- Code generator (`dart run ros2_client:generate`) for `.msg` definitions, with
  automatic transitive dependency resolution
- CBOR is now the default wire encoding: rosbridge serialises non-finite floats
  as JSON `null`, so `inf` and `nan` are indistinguishable over plain JSON

- Connection management with exponential backoff, jitter, and a stability
  window so a flapping bridge is backed off rather than hammered
- Typed topic subscribe/advertise via a message codec registry
- Services, ROS 2 actions (goal/feedback/result/cancel), and parameters
- Full ROS 2 QoS profiles, including `sensorData` and `transientLocal` presets
- JSON and CBOR wire codecs; CBOR typed arrays decode without a per-element
  copy. Handles base64 `uint8[]` and message fragmentation
- Graph introspection through `rosapi`, with timeouts sized for how slow those
  graph-wide queries actually are
- `std_msgs`, `geometry_msgs`, `sensor_msgs` and `nav_msgs` core types
