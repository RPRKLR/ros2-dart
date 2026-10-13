# Changelog

## 0.3.0

**Fixed**

* A service call or goal made while offline could be reported as failed and
  then sent anyway when the link came back: it was failed by a reconnect
  attempt or its timeout, but left in the outbox. The robot then ran a goal
  the app believed had failed, with no handle left to cancel it, and a retry
  ran a service twice. A request reported as failed is now never sent.
* A half-open link, a Wi-Fi dropout or a robot losing power, stayed
  "connected" forever while every command went nowhere. On native platforms
  the WebSocket now pings every 5 s (`WebSocketTransport.pingInterval`), and
  an unanswered ping starts a reconnect. A browser page cannot send pings, so
  there the client probes an idle link itself (`idleProbeInterval`, on by
  default only on the web): it publishes on a hidden topic of its own,
  `/_ros2_client/probe_*`, which it also subscribes to, and reconnects when
  two probes go unanswered. Nothing is probed while a call or goal is
  outstanding, since a bridge serving one answers nothing else. Verified with
  `example/real_link_check.dart` through a proxy that goes silent: pings
  notice after 5 s, the probe after 7 s, and an idle healthy link survives
  both; before, the link was never noticed.
* Every listener on a topic after the first made rosbridge deliver the next
  message twice, to all of them, and so did every reconnect with several
  listeners: each `subscribe` registers the client with a temporary latched
  subscriber while the existing one keeps delivering. A topic now has one
  bridge subscription, set up by its first listener and shared by the rest.
  Their options are that subscription's, and a listener asking for others
  gets a warning on `status`: previously rosbridge merged them, taking the
  minimum throttle rate and the strongest compression. Verified against
  rosbridge 2.0.8 with two listeners on `/chatter`.
* A service call's `timeout` stayed on the client. rosbridge's default is to
  wait forever and to serve one client's calls in order, so one hung call
  blocked every later call on the connection, long after the caller gave up.
  The timeout is now sent with the call. Verified against rosbridge 2.0.8: a
  call after a timed-out one answers in 11 ms, against over 4 s before.
* `fragmentSize` silently stopped every CBOR topic on the client, even after
  the fragmented subscription was cancelled. rosbridge applies it to the whole
  connection, not the subscription. Combining the two on one client now
  throws, naming the topics; use a separate client for the fragmented topic.
* A second listener on a topic with a different QoS got the first one's, and
  so a best-effort sensor topic could deliver nothing to either. rosbridge
  keeps one QoS per topic, so it cannot be per listener; the client now
  warns on `status`.
* `GoalHandle.cancel()` disarmed the goal's timeout, so a cancel that was
  refused or never delivered left `result` pending forever.
* A service call after `close()` waited out its full timeout, and a goal
  never completed. Both now fail at once.
* A decode error in a message held while the listener was paused was
  swallowed rather than reported on `status`.
* A `uint64` at or above 2^63 decoded as 9223372036854775807, whatever its
  value, over both CBOR and JSON: `UINT64_MAX` sentinels, Gazebo entity ids
  and FFmpeg timestamps all collapsed to one number. Publishing one sent a
  negative number, which rosbridge rejected. Such values are now held as
  their two's-complement bits, as uint64 typed arrays already were (read one
  back with `toUnsigned(64)`), and go out as the unsigned value:
  `WireCodec.encode` writes a `BigInt` as its bare digits, which `jsonEncode`
  cannot. Verified against rosbridge 2.0.8 in both directions.
* `byte[]` and bounded `uint8[<=N]` fields could not be published. Generated
  code base64-encoded them, but rosbridge decodes base64 only for `uint8[]`,
  `uint8[N]` and `char[]`, and rejected the rest with "msg is not a list
  type", on its own console only. Every `std_msgs/ByteMultiArray` publish
  was dropped, and every generated `rcl_interfaces` `SetParameters` call
  failed, since `ParameterValue.byte_array_value` is a `byte[]`. They are now
  sent as a list. Verified against rosbridge 2.0.8.
* `TfBuffer` mixed samples from before and after a sim-time reset when the
  clock went back by less than `cacheTime`: a Gazebo reset in the first
  seconds, or `ros2 bag play --loop` on a short bag. "Latest" kept answering
  the old pose, and timed lookups interpolated across the reset. Three
  samples in a row stamped earlier than the newest one now re-baseline the
  frame.
* `TfBuffer` refused a frame that reappeared after more than `cacheTime`,
  taking the gap for a clock jump. A detected marker or docking station froze
  for its next nine samples, and a frame published slower than the window
  kept only one sample in ten. A jump is now accepted at once when the rest
  of the tree is already at that time.
* `Imu`, `NavSatFix`, `BatteryState` and `MapMetaData` dropped fields on
  decode, as `Odometry` did before it was fixed: IMU and GPS covariances,
  `position_covariance_type`, battery temperature, health, technology and
  per-cell values, and the map's `map_load_time`. Relaying one lost them, and
  an IMU that reports no orientation (`orientation_covariance[0] == -1`,
  REP-145) looked like a real one. All fields are now carried, and
  `Imu.hasOrientation` says which case applies.
* Generated `fromJson` decoded a missing fixed-size array as empty, and
  rosbridge then refused to publish the message because the array was too
  short; a missing nested `UUID` or `PoseWithCovariance` covariance was
  enough. A missing array now gets the constructor's default, at the
  declared length or with the declared array default.
* `generate --from-robot` emitted `byte` constants as strings:
  `DiagnosticStatus.ok` was `"b'\x00'"`, so comparing a level with it
  compiled and was always false. They are now ints.
* `generate --from-robot` on a type with a bounded array, a bounded string or
  a `wstring` crashes the robot's `rosapi` node on rosbridge 2.0.8, rather
  than just failing the one call as the documentation said, and the generator
  then waited 45 s for each remaining type. It now stops at the first sign
  that `rosapi` has gone, keeps what it already fetched, and says so. The
  `messageTypedefs` documentation now describes the crash.
* `MessageRegistry.byRosType(type).toJson(message)` always threw a
  `TypeError`. The codec registered by name can now encode.
* A generated integer constant beyond 2^53 broke every web build that
  imported its library, and one beyond int64 did not compile at all. Such
  constants are now parsed at runtime.

* `TfBuffer` froze when sim time went back, as it does on every Gazebo
  restart. Each new sample was older than the cache window measured from the
  stale newest one, so it was trimmed on arrival, and lookups kept answering
  the pose from before the restart with no error. A clock jump back is now
  handled like a jump forward already was: one outlier is ignored, and ten in
  a row re-baseline the frame onto the new clock. Verified against rosbridge
  2.0.8 with `example/real_clock_jump_check.dart`, which fails without it.
* An aborted goal kept nothing of its result. `ActionFailedException.result`
  now holds it, decoded like a successful one. It is often the only place that
  says why: Nav2 on Jazzy aborts a failed navigation with `error_code` and
  `error_msg` in the result, and until now they were discarded. Verified
  against rosbridge 2.7.1, which forwards them.
* A goal the bridge failed itself reported only "Goal ended as unknown".
  rosbridge sends the exception text, which the message now includes.
  A result that arrives but cannot be decoded says so in the message too,
  rather than leaving `result` null without explanation.
* A message or list where a scalar belongs decoded as `0`, `false` or `''`,
  and a scalar where a message belongs as an all-default message. Both now
  throw `FormatException`. Neither is a quirk of the wire encoding; they mean
  the robot's definitions differ from the generated class's. Jazzy's
  `FollowWaypoints` reports missed waypoints as messages where Humble's has
  integers, and a Humble class read them as a list of plausible, wrong
  indices. `null`, numeric strings and ints for doubles still decode as
  before.

## 0.2.0

A minor bump rather than a patch, because pub reads `^0.1.0` as
`>=0.1.0 <0.2.0`: shipping these as 0.1.1 would hand them to every existing
user automatically, and several of these change behaviour that correct-looking
code depends on. Most are bug fixes — the old behaviour was wrong — but wrong
in ways a caller may have built around.

**New**

* `waitUntilConnected({timeout})`. `connect()` reports the *first* attempt and
  throws when it fails, but on a robot link it is usually the retry loop that
  gets you connected, and its success was observable only on `states` — so
  every caller wrote the same `states.firstWhere(...)`. Throws a
  `TimeoutException` on the timeout, and a `StateError` if the client closes
  or `ReconnectPolicy.maxAttempts` runs out first, rather than waiting on a
  client that has stopped trying.
* `nextRetryAt` and `reconnectAttempt`, because the backoff doubles: a UI
  showing "reconnecting" could not tell an operator whether the next attempt
  was a second or half a minute away.
* `probeBridge()` returns a `BridgeInfo` — ROS version, distro, and whether
  the bridge is new enough for ROS 2 actions. A pre-2.0.0 bridge answers a
  goal with nothing at all and logs the unknown operation on the robot's own
  console, so without this `sendGoal` just never completes. Support is read
  from `/rosapi/services` rather than by calling `/rosapi/action_servers`:
  with the default `call_services_in_new_thread:=false` and
  `default_call_service_timeout:=0.0`, calling a service that does not exist
  parks the bridge's only queue thread for the life of the connection, so a
  probe that called it could wedge the link it was checking.
* `Ros2Client(protocols: [...])` offers WebSocket subprotocols on the
  handshake. **rosbridge itself has no authentication**: the `auth` opcode is
  a ROS 1 feature backed by `rosauth`, which was never ported — 2.0.7
  registers no `auth` capability, and a bridge sent one answers `Unknown
  operation: auth` on the robot's console and nothing whatsoever to the
  client. Anything that authenticates a ROS 2 bridge therefore sits in front
  of it, and a subprotocol is the only handshake header a browser can set.
  Verified against 2.0.7: the bridge selects no subprotocol and accepts the
  connection, and traffic flows normally.

**Behaviour that changes**

* A scalar float sent as `null` now decodes to NaN instead of `0.0`. Code like
  `if (battery.percentage < 0.2)` flips, because every NaN comparison is false.
  That is the correct reading — `null` on the wire means "no measurement" — but
  it is a change.
* `Field.asList` throws on a corrupt element instead of dropping it. A message
  that used to decode short now fails, and the client reports it on `status`.
* `RosTopicBuilder` defaults to `Backpressure.latest`, so a widget that was
  accumulating every message now sees only the newest. Pass
  `Backpressure.buffer` to keep the old behaviour.
* The teleop widgets advertise `perishable: true`, so motion commands issued
  while offline are dropped rather than replayed on reconnect.
* An absent nested message decodes to its declared defaults rather than all
  zeros, so an absent `Quaternion` is now the identity.
* A cycle in the tf tree throws from `lookupOrThrow` instead of returning an
  answer derived through an arbitrary edge.
* `set_level` is no longer sent on connect; rosbridge has never implemented it.

**Fixes**

Audits of the tf2 and message layers, neither of which had been reviewed
before. The core maths came out clean — Hamilton products,
`lookupTransform` composition order and `toMatrix4` all verified to ~1e-16
against an independent derivation — but the edges around it did not.

**Gimbal lock returned garbage roll and yaw.** At a pitch of exactly ±90° the
`rpy` decomposition is degenerate, and clamping the pitch alone left roll and
yaw as `atan2` of two rounding errors: up to 37° of silent error. Straight down
is a mast camera or a depth sensor looking at the floor, not an exotic pose.
Now returns `roll = 0` with the rotation folded into yaw, which reconstructs
exactly. Near-lock is untouched — the ordinary formulae stay accurate to a
pitch of `pi/2 - 1e-6`.

**One future-stamped sample poisoned the whole tf buffer.** The cache window
was anchored on the newest stamp, so a single message from a node whose clock
was a minute fast dropped every sample held *and* every good sample that
arrived afterwards. The buffer never recovered; the UI silently stopped
updating. Clock skew between a robot and a bridge is routine. Implausible
future stamps are now refused, with a re-baseline if they persist so a genuine
clock change is still followed.

**A static transform hid live data.** A frame published on both `/tf` and
`/tf_static` answered from the latched value while dynamic samples sat unread,
so the frame stopped moving with no diagnostic. Dynamic samples now win, with
the static one as fallback.

**A cycle in the tree gave two contradictory answers** instead of an error:
`lookup(a, b)` and `lookup(b, a)` resolved through different edges and a round
trip did not return to its origin. Now throws.

**`/tf` and `/tf_static` used the wrong QoS depth — and it lost real frames.**
Confirmed against a robot with three independent static broadcasters: with the
0.1.0 profiles only the *last* one's frame arrives, and looking up either of
the others throws "does not exist in the tf tree". Every robot has more than
one static broadcaster. `tf2_ros` uses reliable
depth 100 for both; a best-effort keep-last-5 reader drops transforms under
load, and a one-deep transient-local reader keeps only one publisher's latched
backlog — so some static frames never arrived at all.

**`waitForFrame` was the only API that did not strip a leading `/`**, so it
blocked for its full timeout on a frame the robot was publishing.

**Negative durations and pre-epoch times were a second wrong**, and flipped
sign: seconds truncated toward zero while nanoseconds used Dart's
always-positive `%`. `-0.5 s` came back as `+0.5 s`.

**`Odometry` discarded the covariance it was given** and re-encoded 36 zeros,
so relaying a message turned "this is my uncertainty" into "I am certain".
Both matrices are now carried through.

**`PointCloud2` ignored `row_step`**, reading coordinates out of the row
padding an organised cloud from a depth camera contains, and shifting every
point after the first row.

**`PointCloud2` and `TFMessage` had no `==`**, contradicting the value-type
contract every other message honours. `PointCloud2.fromJson` also defaulted
`height` to 0 and `is_dense` to false, disagreeing with its own constructor.

**A `null` float decoded as `0.0` instead of NaN.** rosbridge writes `null` for
every non-finite float, so `null` means "no measurement" — and NaN is how ROS
spells that. An unknown battery charge read as a confident 0 %, and a NaN pose
component rendered at the origin. The array converters had always mapped `null`
to NaN; scalars now agree with them.

**An absent nested message decoded to all zeros**, which for `Quaternion` is
the *invalid* rotation rather than the identity its definition declares. A zero
quaternion behaves like identity when rotating a point but annihilates a
Hamilton product, so a single absent link silently erased the rotation of an
entire tf chain — a 90° turn became no turn, with no exception and no NaN.

Both are fixed by decoding against the key rather than the value:
`Field.doubleAt(json, 'w', 1)` can tell an absent field from one sent as
`null`, and carries the default the `.msg` declares. The generator emits these,
and the old value-based helpers remain for code generated against 0.1.0.

**`asList` silently dropped elements it could not type-match**, renumbering
everything after them — a path's waypoints shifted by one with nothing to
indicate they had. A loosely typed `Map<Object?, Object?>` element emptied the
array entirely. Loose maps are now accepted; a genuinely corrupt element throws,
which the client reports on `status` and costs one message rather than the
subscription.

Also: `wss://` verified against a TLS bridge, including certificate pinning
for the self-signed case; CI added; the tree is now `dart format` clean.
`example/real_connection_check.dart` covers the connection-level additions
against a real bridge — 6/6 against rosbridge 2.0.7 on Humble.

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
