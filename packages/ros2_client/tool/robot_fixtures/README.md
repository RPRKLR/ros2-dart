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
  send_action_goals_in_new_thread:=true \
  params_glob:="[*]"
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
