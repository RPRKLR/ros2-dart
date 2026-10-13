// Verifies an OccupancyGrid reaches a client that connects *after* it was
// published, as RosMapView relies on: map_server publishes once, latched.
//
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml
//   python3 tool/robot_fixtures/map_pub.py
//   dart run example/real_map_check.dart
import 'dart:async';
import 'dart:io';

import 'package:ros2_client/ros2_client.dart';

var failures = 0;

void check(String what, bool ok, [String detail = '']) {
  stdout.writeln(
      '${ok ? 'ok  ' : 'FAIL'}  $what${detail.isEmpty ? '' : '  $detail'}');
  if (!ok) failures++;
}

Future<OccupancyGrid?> firstMap(Ros2Client ros, String topic,
    {required QosProfile qos,
    required Compression compression,
    Duration timeout = const Duration(seconds: 15)}) async {
  try {
    return await ros
        .subscribe<OccupancyGrid>(topic, qos: qos, compression: compression)
        .first
        .timeout(timeout);
  } on TimeoutException {
    return null;
  }
}

Future<void> main(List<String> args) async {
  registerStandardMessages();
  final uri = Uri.parse(args.isEmpty ? 'ws://localhost:9090' : args.first);

  for (final compression in [Compression.cbor, Compression.none]) {
    final name = compression.wireName;
    // A fresh connection per run, so neither sees the other's subscription.
    final ros = Ros2Client(uri, reconnectPolicy: ReconnectPolicy.none);
    await ros.connect();

    final map = await firstMap(ros, '/map',
        qos: QosProfile.transientLocal, compression: compression);
    check('[$name] late subscriber receives the latched /map', map != null);
    if (map != null) {
      final info = map.info;
      check(
          '[$name] dimensions and resolution',
          info.width == 40 &&
              info.height == 30 &&
              (info.resolution - 0.05).abs() < 1e-6,
          '${info.width}x${info.height} @ ${info.resolution}');
      check(
          '[$name] origin',
          info.origin.position.x == -2.0 && info.origin.position.y == -1.5,
          '${info.origin.position}');
      check('[$name] frame_id', map.header.frameId == 'map');
      var wrong = 0;
      for (var r = 0; r < 30; r++) {
        for (var c = 0; c < 40; c++) {
          if (map.at(c, r) != const [-1, 0, 100][(c + r) % 3]) wrong++;
        }
      }
      check('[$name] every cell, including -1 unknowns', wrong == 0,
          '$wrong of 1200 wrong');
    }

    final big = await firstMap(ros, '/big_map',
        qos: QosProfile.transientLocal,
        compression: compression,
        timeout: const Duration(seconds: 30));
    check(
        '[$name] a 2048x2048 map arrives',
        big != null &&
            big.data.length == 2048 * 2048 &&
            big.at(64, 0) == 100 &&
            big.at(0, 0) == 0);
    await ros.close();
  }

  // The control: without transient_local the same map never arrives, which
  // is what makes the QoS above the thing under test.
  final ros = Ros2Client(uri, reconnectPolicy: ReconnectPolicy.none);
  await ros.connect();
  final volatile = await firstMap(ros, '/map',
      qos: QosProfile.default_,
      compression: Compression.cbor,
      timeout: const Duration(seconds: 5));
  check('[control] a volatile subscriber does not get the latched map',
      volatile == null);
  await ros.close();

  stdout.writeln(failures == 0 ? '\nall passed' : '\n$failures FAILED');
  exit(failures == 0 ? 0 : 1);
}
