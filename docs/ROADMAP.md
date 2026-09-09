# Roadmap

## Where this sits

The Dart/Flutter ROS ecosystem is effectively abandoned. As of September 2026,
every ROS package on pub.dev is either unmaintained or ROS 1 only:

| Package | Last release | Likes | State |
|---|---|---|---|
| `roslibdart` | ~4 years ago | 11 | ROS 1-era API, `Map<String, dynamic>` everywhere |
| `rosbridge` | ~17 months ago | 0 | Fork of the above |
| `roslibdart_new` | ~13 months ago | 1 | Dependency bump fork |
| `dartros` | ~2 years ago | — | Native TCPROS, **ROS 1 only**, author stepped away |
| `rosbridge_dart_client` | ~3 months ago | 0 | Subscribe-only |
| `nav2_safety_layer` | ~19 days ago | 0 | Narrow, single-purpose |

Nothing published offers typed messages, ROS 2 actions, QoS control, or
resilience. That is the opening this project targets — the gap is real and
nobody currently holds it.

## Design decisions already locked in

**rosbridge over native DDS.** A pure-Dart DDS/RTPS stack is 6–12 months of
work and still fails on the requirement that matters most for apps: DDS
multicast discovery does not survive Wi-Fi roaming, cellular networks, or
browsers. rosbridge is one WebSocket, works everywhere Flutter runs, and needs
no ROS install on the client. Native DDS is a post-1.0 question, not a v1 one.

**A transport interface from day one.** All rosbridge semantics sit above
`RosTransport`, so adding the Foxglove WebSocket protocol later is additive,
not a rewrite. Foxglove is genuinely faster (C++ server, binary schemas) and
is where the ecosystem's momentum is.

**CBOR fast path.** rosbridge's JSON encoding is ~10x less efficient for
binary payloads, and roslibjs profiling shows base64 decode dominating point
cloud rendering. `Compression.cbor` uses RFC 8746 typed arrays, which decode
straight to `Uint8List`/`Float32List` with no per-element copy. This is the
single biggest performance lever and it is already wired in.

**`Ros`-prefixed names for Flutter collisions.** `Image`, `Path`, `Transform`
and `ConnectionState` are all exported by `package:flutter/material.dart`.
Shipping messages under those names would force `hide` clauses on every user.
They are `RosImage`, `RosPath`, `RosTransform`, `RosConnectionState`.

---

## v0.1 — Foundation ✅ *shipped in this repo*

- Connection lifecycle with exponential backoff, jitter, and a stability window
- Typed topics: `subscribe<T>()` / `advertise<T>()` with a codec registry
- Services, ROS 2 actions (goal → feedback → result → cancel), parameters
- Full QoS profiles including the `sensorData` preset
- JSON + CBOR wire codecs, fragment reassembly, base64 `uint8[]` handling
- `rosapi` introspection: topics, nodes, services, action servers, params
- `std_msgs`, `geometry_msgs`, `sensor_msgs`, `nav_msgs` core types
- Flutter widgets: `RosConnection`, `RosTopicBuilder`, camera views,
  laser scan plot, teleop joystick and D-pad
- 30 unit tests + 8 integration tests against a real WebSocket server

## v0.2 — Code generation ✅ *shipped*

`dart run ros2_client:generate -o lib/msgs <packages...>` parses `.msg`
definitions and emits Dart classes. Verified on **136 messages across 12 real
ROS packages**, all compiling clean, with generated types decoding live data
from turtlesim and round-tripping exactly.

Handles bounded/fixed/unbounded arrays, bounded strings, constants, nested and
cross-package types, doc comments, and transitive dependency resolution.

Bugs the 136-message run caught that a small sample would not have:

  * `bool[]` has no typed-data equivalent and was being generated as an array
    of nested messages;
  * a message with no fields emitted `const Empty({})`, which is a syntax error;
  * `visualization_msgs/Marker` has `int32 POINTS=8` *and* `Point[] points`,
    which collapse to one Dart identifier;
  * generated libraries importing the client barrel made their own
    `sensor_msgs/Image` ambiguous with the bundled one — they now import a
    minimal `codegen_support.dart` that exports no message classes.

Still to do here: `.srv` and `.action` emission (the parser already handles
both), and pre-generated `ros2_msgs_common` so most users never run the tool.

## v0.2.1 — Remaining generator work

Hand-writing message classes does not scale past the standard set, and every
robot has custom interfaces. This is what turns the package from a demo into
something teams adopt.

- `dart run ros2_gen` — parse `.msg` / `.srv` / `.action` into Dart classes
- Two input modes:
  - **offline**: point at a `src/` tree or a sourced ROS install
  - **online**: pull definitions from a live robot via
    `rosapi/message_details`, which already returns full typedefs
- Emit `build.yaml`-compatible output so it fits normal Flutter workflows
- Generate constants, bounded/fixed arrays, and nested defaults correctly
- Ship pre-generated `ros2_msgs_common` (action_msgs, tf2_msgs, nav2_msgs,
  control_msgs) so most users never run the generator

**Risk to watch:** ROS 2 `.msg` has subtleties (bounded strings, default
values, `constant` vs `field`) that naive parsers get wrong. Test against the
full `common_interfaces` repo, not a handful of examples.

## v0.3 — Transforms

TF is the piece every real robot UI needs and no Dart package has.

- `tf2` buffer with time-interpolated lookups
- Subscribe `/tf` + `/tf_static` (the latter needs `transient_local` QoS —
  already supported)
- `lookupTransform(target, source, time)` with proper extrapolation errors
- Quaternion/Euler/matrix conversions, and pose transformation helpers
- Widget: `TfFrameBuilder` to position markers in a chosen frame

## v0.4 — Performance and scale

- Move decode of large messages to an isolate; benchmark the crossover point
  where the isolate hop costs more than it saves
- `PointCloud2` field-accessor API that reads directly from the byte buffer
  instead of materialising Dart objects
- Backpressure: drop-oldest and conflate strategies per subscription
- A published benchmark suite (messages/sec and MB/sec by encoding), because
  performance claims without numbers are worthless
- Optional per-message-deflate negotiation

## v0.5 — Foxglove transport

- Implement the Foxglove WebSocket protocol behind the existing
  `RosTransport` interface
- Schema negotiation (`ros2msg` and `ros2idl`), plus a CDR decoder
- Let users pick per connection; keep the public API identical

## v0.6 — Flutter polish

- Occupancy grid / map widget with pan, zoom and pose overlay
- 2D nav goal picker that sends a `NavigateToPose` action
- Diagnostics panel driven by `diagnostic_msgs`
- Robot model view from `/robot_description` (URDF parse + 2D footprint first;
  3D is a much larger commitment)
- Riverpod and Bloc integration examples — not dependencies

## v1.0 — Production readiness

- Security: TLS (`wss://`), token auth via the rosbridge `auth` opcode,
  documented reverse-proxy setup
- Web support verified in CI, including the CBOR path under WASM
- Reconnect/offline semantics documented with a state diagram
- API frozen; semver discipline from here
- A real reference app published to the stores driving an actual robot

---

## Before the first publish

1. **Pick and verify a package name.** `ros2_client` and `ros2_flutter` were
   both free on pub.dev when this was written. Re-check before publishing.
2. **Replace the `dependency_overrides` block** in `ros2_flutter/pubspec.yaml`
   with the published `ros2_client` version.
3. **Set the real repository URL** in both pubspecs (currently `USER`).
4. **Add `LICENSE`** — BSD-3-Clause matches ROS ecosystem convention.
5. **Run `dart pub publish --dry-run`** and fix every pub points warning;
   score is the main discovery signal on pub.dev.
6. **Publish `ros2_client` first**, then `ros2_flutter`.

## Validation against a real bridge ✅

Verified 2026-09-09 against `rosbridge_suite` 2.0.7 on ROS 2 Humble, with
turtlesim and `demo_nodes_cpp` running. **16/16 checks pass** —
`example/real_bridge_check.dart` is the reproducible harness:

```bash
ros2 launch rosbridge_server rosbridge_websocket_launch.xml
ros2 run turtlesim turtlesim_node
ros2 run demo_nodes_cpp talker
ros2 run demo_nodes_cpp add_two_ints_server
dart run example/real_bridge_check.dart
```

Covered: topic/node/action-server introspection, typed and custom-message
subscription, publishing (the turtle actually moves), services, an action goal
with live feedback, parameter read/write, best-effort QoS, and server-side
throttling.

### What real hardware caught that the fake bridge did not

**QoS was sent in the wrong format, and failed silently.** The protocol
document does not specify the encoding, so the first implementation sent enum
integers and `sec`/`nsec` durations. rosbridge accepted the subscribe,
delivered **nothing**, and reported no error — the worst possible failure mode.
Reading `rosbridge_library/internal/qos_extraction.py` gave the real contract:

  * policies are lowercase strings — `"best_effort"`, not `2`;
  * there is no `system_default` policy name, so those must be **omitted**;
  * durations use `secs`/`nsecs`, not `sec`/`nsec`, and zero means "unset",
    so zero durations must be omitted too;
  * unknown keys are ignored, so `liveliness` is safe to send but is not read
    by 2.0.x.

A fake server can never catch this class of bug, because the fake agrees with
whatever the client sends. Unit tests now pin the exact wire strings.

**`rosapi/get_param_names` takes 20+ seconds** and returns an empty list unless
the bridge is launched with `params_glob:="[*]"`. Confirmed to be `rosapi`, not
the client — `ros2 service call` is equally slow. Introspection calls now
default to a 45 s timeout; `getParam`/`setParam` respond in ~10 ms and need no
glob.

## Still owed

- Test on a robot with real sensor topics: `sensor_msgs/Image` CBOR framing,
  point clouds, and fragmentation on genuinely large messages are all still
  unexercised against real data.
- Confirm whether a real bridge emits bare `Infinity` in JSON (the defence is
  in place either way).
- Web/WASM verification in CI.

## Version compatibility to document

- **ROS 2 actions require `rosbridge_suite` >= 2.0.0** (October 2024). Earlier
  versions reject `send_action_goal` as an unknown operation. Humble's current
  apt package is 2.0.7, so it is fine — but users on older pinned versions
  will hit this. Consider probing `rosapi/get_ros_version` on connect and
  surfacing a clear warning.
- The bundled messages target ROS 2 (`pkg/msg/Type` naming). ROS 1 short names
  are accepted as registry aliases but ROS 1 is not a support target.
