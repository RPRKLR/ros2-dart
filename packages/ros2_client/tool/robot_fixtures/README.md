# Robot-side fixtures

ROS nodes that publish the data `example/real_*_check.dart` verifies against.
They exist because the interesting failures in this client only appear against
a *real* bridge: a fake server agrees with whatever the client sends, which is
how the QoS wire format, the CBOR decode path, CBOR fragmentation and the
`/tf_static` queue depth all shipped broken.

Each needs a sourced ROS 2 install and a running bridge:

```bash
source /opt/ros/humble/setup.bash
ros2 launch rosbridge_server rosbridge_websocket_launch.xml \
  max_message_size:=50000000 \
  call_services_in_new_thread:=true \
  send_action_goals_in_new_thread:=true
```

## `sensor_pub.py` — large messages

Publishes a 640×480 `sensor_msgs/Image`, a 1080-beam `LaserScan` containing
`inf` and `nan`, and a 20 000-point `PointCloud2`, all with byte patterns the
checker can verify exactly.

```bash
python3 sensor_pub.py &
cd ../.. && dart run example/real_sensor_check.dart
```

Covers: CBOR and JSON image decode byte-for-byte, zero-copy `Uint8List` views,
`inf`/`nan` survival per encoding, point cloud payloads, and JSON
fragmentation.

## `tf_pub.py` — a realistic transform tree

Publishes `map -> odom -> base_link` at 50 Hz plus **three independent static
broadcasters** (`laser`, `camera`, `imu`). The three matter: a real robot has a
URDF publisher and one per sensor driver, and a transient-local subscription
only one deep keeps just the last of them. That is exactly the bug this fixture
caught — with the QoS profiles 0.1.0 shipped, `laser` and `camera` never
arrive at all.

```bash
python3 tf_pub.py &
cd ../.. && dart run example/real_tf_check.dart
```

## `sim_clock_pub.py` — a simulator that restarts

Publishes `/clock` in 6 s phases that start alternately from 500 s and from
0 s, as Gazebo does on every world reset, and a `use_sim_time` node
broadcasting `map -> base_link` stamped from it. The pose encodes the stamp
(`x` is sim seconds / 100), so the checker can tell which side of a restart
an answer came from.

```bash
python3 sim_clock_pub.py &
cd ../.. && dart run example/real_clock_jump_check.dart
```

Covers: the buffer following sim time back to zero, then on, and forward
again. Before the fix it kept answering the pre-restart pose forever.

## `map_pub.py` — a latched map

Publishes `/map` (40×30, every cell checkable) and `/big_map` (2048×2048)
once each, `transient_local`, the way `map_server` does, and then idles.

```bash
python3 map_pub.py &
cd ../.. && dart run example/real_map_check.dart
```

Covers: a client that connects *after* the map was published still receives
it, in CBOR and JSON, with every cell intact including the `-1` unknowns; a
4 MiB map arrives whole; and, as the control, a volatile subscriber gets
nothing. `RosMapView` depends on all of it.

## `slow_service.py` and `freeze_proxy.py` — a link under stress

`slow_service.py` serves `/slow`, which answers after 8 s, and `/fast`.
`freeze_proxy.py` sits between client and bridge and, on `SIGUSR1`, stops
forwarding without closing anything, the way a Wi-Fi dropout looks to a
socket.

```bash
python3 slow_service.py &
ros2 run demo_nodes_cpp talker &
python3 freeze_proxy.py 9091 9090 & A=$!
python3 freeze_proxy.py 9092 9090 & B=$!
cd ../.. && dart run example/real_link_check.dart \
  ws://localhost:9090 ws://localhost:9091 $A ws://localhost:9092 $B
```

Covers: a call after a timed-out one is not held up behind it; two listeners
on `/chatter` each see every message once; an idle healthy link survives its
pings, and, with pings off as in a browser, its idle probes; a silent link is
noticed both ways. Without the fixes the second call waits out its own
timeout, a message arrives twice, and the silent link is never noticed.

## TLS

`example/secure_connection.dart` needs a bridge launched with TLS instead:

```bash
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 \
  -nodes -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost"
ros2 launch rosbridge_server rosbridge_websocket_launch.xml \
  ssl:=true certfile:=cert.pem keyfile:=key.pem
```

Then `dart run example/secure_connection.dart wss://localhost:9090 cert.pem`.
Without the second argument it must fail with `CERTIFICATE_VERIFY_FAILED`;
that is the case worth checking, since a self-signed certificate is what
almost every robot on a private network has.
