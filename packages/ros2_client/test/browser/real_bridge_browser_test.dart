// A browser making a service call and sending an action goal through a REAL
// rosbridge, under dart2js and dart2wasm. The web runtime differs from the
// VM where it matters: its own WebSocket, which cannot ping, so the client
// probes idle links itself; JavaScript numbers; and CBOR decoding into typed
// arrays. A VM test of the same calls says nothing about any of them.
//
// Skipped unless asked for, since it needs a live robot. With the setup of
// example/real_bridge_check.dart (a bridge on localhost:9090, turtlesim and
// demo_nodes_cpp's talker and add_two_ints_server):
//
//   dart test -p chrome --run-skipped -t real-bridge
//   dart test -p chrome --compiler dart2wasm --run-skipped -t real-bridge
@TestOn('browser')
@Tags(['real-bridge'])
library;

import 'package:ros2_client/ros2_client.dart';
import 'package:test/test.dart';

const _bridge = 'ws://127.0.0.1:9090';

void main() {
  late Ros2Client ros;

  setUpAll(() async {
    registerStandardMessages();
    ros = Ros2Client(Uri.parse(_bridge));
    await ros.connect().timeout(const Duration(seconds: 10));
  });
  tearDownAll(() => ros.close());

  test('a typed service call: add_two_ints', () async {
    // Large enough that a 32-bit truncation anywhere would show.
    final res = await ros.callServiceJson(
        '/add_two_ints', {'a': 3000000000, 'b': 1234567},
        type: 'example_interfaces/srv/AddTwoInts');
    expect(res['sum'], 3001234567);
  });

  test('a service the robot does not have fails, and does not hang', () async {
    await expectLater(
        ros.callServiceJson('/no_such_service', const {},
            type: 'example_interfaces/srv/AddTwoInts',
            timeout: const Duration(seconds: 3)),
        throwsA(anything));
  });

  test('an action goal with feedback and result: rotate_absolute', () async {
    final poseType = await ros.topicType('/turtle1/pose') ?? '';
    final package = poseType.split('/').first;
    final codec = ActionCodec<double, double, double>(
      actionType: '$package/action/RotateAbsolute',
      encodeGoal: (theta) => {'theta': theta},
      decodeFeedback: (json) => (json['remaining'] as num?)?.toDouble() ?? 0,
      decodeResult: (json) => (json['delta'] as num?)?.toDouble() ?? 0,
    );
    // Alternate the target, so a rerun still has a turn to make.
    final heading = await ros.subscribeJson('/turtle1/pose').first;
    final theta = ((heading['theta'] as num?) ?? 0) > 0 ? -1.2 : 1.2;

    final handle = ros.sendGoal<double, double, double>(
        '/turtle1/rotate_absolute', theta,
        codec: codec, timeout: const Duration(seconds: 20));
    final feedback = <double>[];
    handle.feedback.listen(feedback.add);
    final delta = await handle.result;
    expect(feedback, isNotEmpty);
    expect(delta.abs(), greaterThan(0.1));
  });

  test('a cancelled goal ends cancelled', () async {
    final poseType = await ros.topicType('/turtle1/pose') ?? '';
    final package = poseType.split('/').first;
    final codec = ActionCodec<double, double, double>(
      actionType: '$package/action/RotateAbsolute',
      encodeGoal: (theta) => {'theta': theta},
      decodeFeedback: (json) => (json['remaining'] as num?)?.toDouble() ?? 0,
      decodeResult: (json) => (json['delta'] as num?)?.toDouble() ?? 0,
    );
    final heading = await ros.subscribeJson('/turtle1/pose').first;
    final theta = ((heading['theta'] as num?) ?? 0) > 0 ? -3.0 : 3.0;
    final handle = ros.sendGoal<double, double, double>(
        '/turtle1/rotate_absolute', theta,
        codec: codec, timeout: const Duration(seconds: 20));
    await handle.feedback.first;
    handle.cancel();
    await expectLater(
        handle.result,
        throwsA(isA<ActionFailedException>()
            .having((e) => e.status, 'status', GoalStatus.canceled)));
  });

  test('a CBOR topic decodes in the browser', () async {
    final pose = await ros
        .subscribeJson('/turtle1/pose', compression: Compression.cbor)
        .first;
    expect(pose['x'], isA<num>());
  });
}
