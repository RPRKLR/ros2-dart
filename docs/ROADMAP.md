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

## v0.2.1 — Online generation ✅ *shipped*

`--from-robot ws://host:9090` generates from the robot's own `rosapi` node, so
neither a ROS install nor a source tree is needed on the development machine.
With no packages named it generates exactly the interfaces the robot is
actually using; naming packages generates those in full. Messages, services and
actions all come through, with nested types resolved recursively across package
boundaries.

Verified against rosbridge 2.0.7 and turtlesim on Humble: the generated
`turtlesim.Pose` decoded a live `/turtle1/pose`, and the generated
`SpawnRequest`/`SpawnResponse` drove `/spawn`, both from classes the robot had
described minutes earlier over a WebSocket.

The network half lives in the CLI; the conversion half is `TypedefParser` and
`TypedefHarvest`, which are pure and unit tested against captured real rosapi
output.

### What `rosapi/message_details` actually returns

The service is documented as returning typedefs and nothing more, so all of
this was read out of `rosapi/objectutils.py` and confirmed by calling it:

**It cannot describe bounded arrays or bounded strings at all.** Its regex
turns `sequence<double, 3>` into the type name `"double, 3"`, and then either
raises an `AssertionError` internally (`shape_msgs/SolidPrimitive`) or hands
back the mangled name as if it were a type
(`rcl_interfaces/ParameterDescriptor`). The generator refuses to name a class
after a bound, and reports every type that was referenced but not generated —
because the first attempt produced output that only failed at `dart analyze`,
which is the same silent-failure class as the QoS bug in v0.1.

**Primitives come back in IDL spelling**, `double`/`float`/`boolean`/`octet`
rather than `float64`/`float32`/`bool`/`byte`. Emitted literally, every
`float64` field references a nested class named `double`.

**The constant list is not a constant list.** It is built from
`inspect.getmembers`, so it contains every field name paired with its default
value, plus `SLOT_TYPES`, whose value is a Python repr with a memory address in
it. `visualization_msgs/Marker` returns real constants and field names
interleaved in one flat list, which is why filtering has to be per-message.

## v0.2.2 — `ros2_msgs_common` ✅ *shipped*

221 pre-generated messages, plus their services and actions, across nav2_msgs,
control_msgs, visualization_msgs, lifecycle_msgs, diagnostic_msgs, tf2_msgs,
action_msgs, shape_msgs, trajectory_msgs, unique_identifier_msgs and the parts
of geometry_msgs and std_msgs the client does not bundle. About 400 KB of
committed source, so nothing needs a ROS install at build time.
`tool/regenerate.sh` rebuilds it byte-identically.

Shipping this first required teaching the generator not to re-emit what the
client already provides. Generating any package that references
`std_msgs/Header` — nearly all of them — used to emit a second `Header`, and a
second copy of every bundled type in the closure. Both then register a codec
for the same ROS type name, `MessageRegistry` keeps whichever registered last,
and `byRosType` silently starts resolving to the generated class. Worse, the
`ros2_flutter` widgets are typed against the bundled classes and could not
accept the generated ones at all.

Generated libraries now reference bundled types through a prefixed
`import 'package:ros2_client/ros2_client.dart' as ros2`, omit them from their
own output and registration, and skip a package whose referenced types are
entirely bundled. `--no-bundled` restores the self-contained behaviour.

The prefix matters: the barrel exports plenty of non-message names
(`Ros2Client`, `TfBuffer`, `Compression`) that a custom ROS package is free to
collide with. That collision is exactly why generated code imported only
`codegen_support.dart` in the first place; a prefix keeps the safety and the
types.

`BundledTypes` cannot be derived from the emitter — `std_msgs/Bool` is
hand-written as `BoolMsg`, not `Bool` — so a test pins the table against the
registry in both directions. Adding or renaming a bundled type now fails the
build instead of quietly reintroducing a duplicate codec.

Two problems only compiling the output revealed:

**The bundled classes were not all default-constructible.** `StringMsg` and
the other scalar wrappers took a required positional argument, now optional
with the ROS default so `const StringMsg('hi')` still works. `RosImage`,
`CompressedImage`, `LaserScan`, `JointState` and `OccupancyGrid` require their
typed-data fields, for the same reason generated code uses a `??` initialiser
for them; those five fall back to `fromJson(const {})`, which is exactly the
ROS default because none declares a non-zero one. `Quaternion` must *not* take
that path: its `.msg` says `float64 w 1`, so `Quaternion()` is the identity
while `Quaternion.fromJson(const {})` would be an all-zero invalid rotation. A
string table cannot be type-checked, so a test file compiles every one of those
expressions.

**The CLI reported parsed counts, not emitted ones,** so a library with eight
bundled types excluded still claimed to have written them.

### Still owed here

- `build.yaml`-compatible output, to fit normal Flutter build workflows
- An online run against a robot with genuinely custom interfaces; everything
  so far was verified against stock Humble packages
- `ros2_msgs_common` targets Humble only. Whether a Jazzy build differs enough
  to need a second published version is unknown and untested.

## v0.3 — Transforms ✅ *shipped*

TF is the piece every real robot UI needs and no Dart package has.

- `TfBuffer`: the frame tree, time-interpolated lookups (slerp on rotation),
  a per-frame cache window, and out-of-order sample insertion
- `TfListener` feeding it from `/tf` and `/tf_static`, the latter over
  `transient_local` so a late joiner still receives the latched frames
- `lookupOrThrow(target, source, time)` with failure messages that name the
  known frames and the buffered window, plus `lookup` for the `null` form
- Quaternion/Euler/matrix conversions (`fromRpy`, `fromYaw`, `rpy`, `yaw`,
  `toMatrix4`) and point/vector/pose transformation helpers
- Widget: `TfFrameBuilder`, resolving a transform for the widget's lifetime

Two decisions worth recording:

**Timestamps are stored in microseconds, not nanoseconds.** `sec * 1e9` for a
real epoch time exceeds 2^53, and Dart ints are doubles on the web — so the
obvious nanosecond representation silently loses precision in exactly the
place this package is meant to run.

**One `TfListener` per `RosConnection`, not per widget.** `/tf` runs at
50-200 Hz on a real robot. A listener per widget would multiply bridge traffic
and decode cost by the number of widgets on screen, so `RosConnection.tfOf`
hands every descendant the same listener, built lazily on first use.

Rebuilds are left to `setState`, which already coalesces a burst between two
frames into one rebuild; an update that leaves the transform unchanged does
not rebuild at all. An earlier post-frame-callback throttle was removed — it
added a second frame of latency and bought nothing.

Still owed here: `TfBuffer` is only exercised against synthetic transforms.
A real robot's tf tree — dozens of frames, static and dynamic mixed, clocks
that jump on `/clock` — is unverified.

## v0.4 — Performance and scale

- ✅ A published benchmark suite (`benchmark/wire_benchmark.dart`), because
  performance claims without numbers are worthless — and this one turned out
  to be backwards. See "Large messages, verified against a real bridge".
- Move decode of large messages to an isolate; benchmark the crossover point
  where the isolate hop costs more than it saves. Now worth re-scoping: a
  1080p CBOR frame decodes in 13 ms without touching a pixel, so the isolate
  hop may cost more than it saves for everything but JSON base64.
- `PointCloud2` field-accessor API that reads directly from the byte buffer
  instead of materialising Dart objects
- Backpressure: drop-oldest and conflate strategies per subscription
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

- Web/WASM verification in CI.

## Large messages, verified against a real bridge ✅

Done 2026-09-10. `example/real_sensor_check.dart` subscribes to a 640x480
`sensor_msgs/Image`, a 1080-beam `LaserScan` and a 20k-point `PointCloud2`
published from a real ROS node through rosbridge 2.0.7, and checks every byte
against the pattern the publisher wrote. 20/20 checks pass. Images and point
clouds arrive as `_Uint8ArrayView` — a view over the frame, never copied.

**Two questions this closed.**

*Does a real bridge emit bare `Infinity` in JSON?* No.
`message_conversion.py` says it outright: "JSON does not support Inf and NaN.
They are mapped to None and encoded as null." So over JSON an out-of-range
beam and an invalid one both arrive as `NaN` and cannot be told apart. The
`Infinity`/`NaN` literal repair stays — other bridges and forks are not bound
by this — but it is not what handles stock rosbridge. CBOR preserves both
exactly, which makes it a correctness choice for scans, not only a fast one.

*Was the CBOR fast path actually fast?* No — it was **five times slower than
JSON**, the exact opposite of the claim this package was built on. rosbridge
sends `uint8[]` as a plain CBOR byte string, not a tagged array
(`cbor_conversion.py` writes `bytes(val)` for `sequence<uint8>`), and
`cborDecode(...).toObject()` turns a byte string into a `List<int>` of boxed
integers, which normalisation then boxed again. A 1080p frame cost six million
allocations before `Field.asBytes` had started.

The frame is now walked as a `CborValue` tree, so byte strings stay
`Uint8List` and typed arrays stay `TypedData`, in one pass instead of two. The
last copy went when it turned out the cbor package returns a `Uint8Buffer` —
a `List<int>` that is *not* a `TypedData`, so `Uint8List.fromList` on it copied
element by element. It does expose its backing store, so a view costs nothing.

| Message | JSON | CBOR before | CBOR after |
|---|---|---|---|
| 640x480 rgb8 | 62 msg/s | 13 msg/s | **160 msg/s** |
| 1920x1080 rgb8 | 20 msg/s | 6 msg/s | **77 msg/s** |
| 64k-point cloud | 88 msg/s | 19 msg/s | **240 msg/s** |
| 1080-beam scan | 8464 msg/s | — | **28395 msg/s** |

**Why no test caught it.** The one CBOR test built its payload as
`CborBytes(pixels, tags: [CborTag.uint8Array])` — a *tagged* array, which is
a wire form rosbridge never sends. The tagged path always worked; the untagged
one, which is the only one that occurs in practice, was never exercised.
`test/wire_codec_test.dart` now pins the shapes `cbor_conversion.py` actually
produces, and asserts the decoded type rather than only the values.

A related trap: `CborFloat32LittleEndianArray(bytes)` does not attach its own
tag, so building test data that way silently produces an untagged byte string.
Tags have to be passed explicitly.

### Fragmentation ✅

Also closed 2026-09-10, and it found a third silent failure. Over JSON,
`fragment_size` works: a 1.2 MB base64 image at 64 KB a fragment is about
twenty parts and reassembles byte-exact in ~240 ms.

Over CBOR it delivers **nothing**. `Fragmentation.fragment` re-serialises the
already-encoded payload with `json.dumps`, which refuses it — `reject_bytes is
on and '...' is bytes` — and the bridge then sends no fragments at all,
logging the failure only on its own console. The subscription is accepted, so
from the client there is no error, no warning, and no data: the same shape as
the v0.1 QoS bug.

Nothing here can fix rosbridge, but the combination is detectable before the
subscribe goes out, so `subscribe` now throws an `ArgumentError` naming the
cause. The check resolves `defaultCompression` too — setting CBOR globally and
adding `fragmentSize` for one topic is the easiest way to hit this by
accident.

## Version compatibility to document

- **ROS 2 actions require `rosbridge_suite` >= 2.0.0** (October 2024). Earlier
  versions reject `send_action_goal` as an unknown operation. Humble's current
  apt package is 2.0.7, so it is fine — but users on older pinned versions
  will hit this. Consider probing `rosapi/get_ros_version` on connect and
  surfacing a clear warning.
- The bundled messages target ROS 2 (`pkg/msg/Type` naming). ROS 1 short names
  are accepted as registry aliases but ROS 1 is not a support target.
