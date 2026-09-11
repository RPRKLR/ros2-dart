// Compiled for web and WASM in CI. Not a test of behaviour: it exists so a
// stray dart:io import anywhere in the library fails the build, which is the
// only thing that keeps the browser-support claim honest.
//
// Touching every part of the public surface is the point — an unreferenced
// library is tree-shaken away and would not be checked at all.
import 'dart:typed_data';
import 'package:ros2_client/ros2_client.dart';

Object? sink;

Future<void> main() async {
  registerStandardMessages();
  // protocols: the browser's only handshake header, so it has to compile here.
  final ros = Ros2Client(Uri.parse('wss://robot.example:9090'),
      protocols: const ['rosbridge.v1']);
  sink = ros.waitUntilConnected(timeout: const Duration(seconds: 5));
  sink = ros.probeBridge();
  sink = ros.nextRetryAt;
  sink = ros.subscribe<LaserScan>('/scan',
      qos: QosProfile.sensorData,
      compression: Compression.cbor,
      backpressure: Backpressure.latest);
  sink = ros.advertise<Twist>('/cmd_vel', perishable: true);
  sink = ros.callServiceJson('/x', const {});
  sink = ros.listTopics();
  sink = ros.messageTypedefs('sensor_msgs/msg/Image');

  final tf = TfListener(ros)..start();
  sink = tf.buffer.lookup('map', 'base_link');
  sink = Quaternion.fromRpy(0.1, 0.2, 0.3).rpy;
  sink = const RosTransform().toMatrix4();

  final cloud = PointCloud2(
    width: 1,
    pointStep: 16,
    fields: const [
      PointField(name: 'x', offset: 0, datatype: PointField.float32),
      PointField(name: 'y', offset: 4, datatype: PointField.float32),
      PointField(name: 'z', offset: 8, datatype: PointField.float32),
    ],
    data: Uint8List(16),
  );
  sink = cloud.reader().xyz();
  sink = WireCodec.decode('{"op":"status"}');
}
