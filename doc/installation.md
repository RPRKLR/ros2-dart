# Installation

Two halves: something on the robot that speaks the rosbridge protocol, and the
Dart packages in your app. The app needs **no ROS installation** — that is the
whole point of going through rosbridge rather than DDS.

---

## 1. On the robot

```bash
sudo apt install ros-${ROS_DISTRO}-rosbridge-suite
ros2 launch rosbridge_server rosbridge_websocket_launch.xml
```

That starts a WebSocket server on port 9090 and a `rosapi` node beside it.
`rosapi` is what answers introspection queries (topic lists, parameters,
message definitions); without it, subscribing still works but
`listTopics()` and friends do not.

### Launch arguments worth setting

Defaults that will bite you, all verified against `rosbridge_suite` 2.0.7:

```bash
ros2 launch rosbridge_server rosbridge_websocket_launch.xml \
  max_message_size:=50000000 \
  call_services_in_new_thread:=true \
  send_action_goals_in_new_thread:=true \
  params_glob:="[*]"
```

| Argument | Why |
|---|---|
| `max_message_size` | **A CBOR message larger than this is silently dropped.** Default is 10 MB under the launch file, 1 MB for a bare node. A 640×480 `rgb8` image is 900 KB of CBOR; 1080p is ~6 MB. See [the size ceiling](#the-cbor-size-ceiling). |
| `call_services_in_new_thread` | Defaults false. A service call that never returns then wedges *the whole connection* — no further subscribes, publishes or unsubscribes — for as long as it hangs, and the default service timeout is "wait forever". |
| `send_action_goals_in_new_thread` | Defaults false. While a goal runs, every other message from that client is queued and unprocessed, and `cancel()` cannot be delivered at all. |
| `params_glob` | Without it, `listParams()` returns an empty list after ~20 s. `getParam`/`setParam` work regardless. |

For TLS, `rosbridge_websocket_launch.xml` takes `ssl:=true`, `certfile:=` and
`keyfile:=`, and you then connect with `wss://`.

### Check it is up

```bash
ros2 topic list          # /client_count and /connected_clients appear
ros2 node list           # /rosbridge_websocket and /rosapi
```

---

## 2. In your app

```yaml
dependencies:
  ros2_client: ^0.1.0        # pure Dart: topics, services, actions, TF
  ros2_flutter: ^0.1.0       # optional: widgets
  ros2_msgs_common: ^0.1.0   # optional: nav2, control, markers, diagnostics
```

`ros2_client` alone is enough for a console tool, a server, or a CLI. Add
`ros2_flutter` for the widgets, and `ros2_msgs_common` only if you need
interface packages beyond the core types the client already bundles.

```dart
import 'package:ros2_client/ros2_client.dart';

void main() {
  registerStandardMessages();   // once, before the first subscribe
  runApp(const MyApp());
}
```

---

## 3. Platform notes

### Web

A page served over **https cannot open a `ws://` socket** — browsers block
mixed content, and the failure is a console error rather than an exception you
can catch. Either serve the app over plain http during development, or put TLS
on the bridge and use `wss://`.

The client compiles cleanly under both `dart compile js` and
`dart compile wasm`; nothing in it imports `dart:io`.

### Android and iOS

Both platforms restrict cleartext networking by default, and `ws://` is
cleartext. Whether that restriction reaches a Dart socket depends on the
platform's networking stack rather than on this package, and we have not
verified it on a device — so treat the following as the first thing to check
if a connection that works on desktop fails on a phone.

Android, in `android/app/src/main/AndroidManifest.xml`:

```xml
<application android:usesCleartextTraffic="true" ...>
```

iOS, in `ios/Runner/Info.plist`, scoped to your robot rather than globally:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>robot.local</key>
    <dict><key>NSExceptionAllowsInsecureHTTPLoads</key><true/></dict>
  </dict>
</dict>
```

Using `wss://` avoids the question on both platforms, and is what you want off
the workbench anyway.

### Finding the robot

`ws://localhost:9090` only works on the robot itself. From a phone, use the
robot's LAN address — and note that the Android emulator reaches the host
machine at `10.0.2.2`, not `localhost`.

---

## The CBOR size ceiling

Worth understanding before you ship, because the failure is silent.

rosbridge always arms fragmentation: `fragment_size` defaults to
`max_message_size`. A CBOR frame above that is handed to the fragmenter, which
re-serialises the already-encoded binary payload with `json.dumps`, fails, and
**sends nothing** — logging only on the robot's own console. The subscription
is accepted and simply never produces a message.

JSON is unaffected, because JSON fragments fine and the client reassembles it.

So: raise `max_message_size` on the bridge to comfortably exceed your largest
message, or use `Compression.none` for that one topic. Lowering `fragment_size`
from the client does not help — the server caps it at `max_message_size`, so it
only moves the cliff closer.

---

## Next

[The tutorial](tutorial.md) builds a working teleop panel from an empty
Flutter project.
