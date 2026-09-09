import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:ros2_client/ros2_client.dart';
import 'package:test/test.dart';

import 'fake_bridge.dart';

void main() {
  setUpAll(registerStandardMessages);

  late FakeBridge bridge;
  late Ros2Client ros;

  Future<void> connect({ReconnectPolicy? policy}) async {
    bridge = FakeBridge();
    ros = Ros2Client(
      Uri.parse('ws://fake:9090'),
      transportFactory: (_) => bridge,
      reconnectPolicy: policy ?? ReconnectPolicy.none,
    );
    await ros.connect();
  }

  tearDown(() async {
    await ros.close();
  });

  group('connection', () {
    test('reaches connected state and announces status level', () async {
      await connect();
      expect(ros.isConnected, isTrue);
      expect(ros.state, RosConnectionState.connected);
      expect(bridge.lastOf('set_level'), isNotNull);
    });

    test('buffers commands sent while offline and replays them', () async {
      bridge = FakeBridge();
      ros = Ros2Client(Uri.parse('ws://fake:9090'),
          transportFactory: (_) => bridge,
          reconnectPolicy: ReconnectPolicy.none);

      // Publish before connecting: must not throw, must not be lost.
      final pub = ros.advertise<StringMsg>('/chatter');
      pub.publish(const StringMsg('queued'));
      expect(bridge.sent, isEmpty);

      await ros.connect();
      final published = bridge.opsOf('publish');
      expect(published, hasLength(1));
      expect((published.single['msg']! as Map)['data'], 'queued');

      // The advertise must not be sent twice: _resubscribeAll replays it from
      // live state, so queuing it in the outbox as well would duplicate it.
      expect(bridge.opsOf('advertise'), hasLength(1));
    });

    test('a subscribe made while offline is sent exactly once', () async {
      bridge = FakeBridge();
      ros = Ros2Client(Uri.parse('ws://fake:9090'),
          transportFactory: (_) => bridge,
          reconnectPolicy: ReconnectPolicy.none);

      ros.subscribe<StringMsg>('/chatter').listen((_) {});
      await pump();
      await ros.connect();
      await pump();

      expect(bridge.opsOf('subscribe'), hasLength(1));
    });

    test('connect() fails if close() happens while it is in flight', () async {
      final gate = GatedBridge();
      final client = Ros2Client(
        Uri.parse('ws://fake:9090'),
        transportFactory: (_) => gate,
        reconnectPolicy: ReconnectPolicy.none,
      );

      // Held open until released, so close() genuinely lands mid-connect.
      final connecting = client.connect();
      await pump();
      await client.close();
      gate.release();

      // Completing successfully would hand back a client that is closed.
      await expectLater(connecting, throwsA(isA<StateError>()));
      expect(client.state, RosConnectionState.closed);
    });

    test('re-issues subscriptions after a reconnect', () async {
      await connect(
          policy: const ReconnectPolicy(
              initialDelay: Duration(milliseconds: 1), jitter: 0));

      ros.subscribe<StringMsg>('/chatter').listen((_) {});
      await pump();
      expect(bridge.opsOf('subscribe'), hasLength(1));

      bridge.drop();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      // The client rebuilt the subscription without the caller re-subscribing.
      expect(bridge.opsOf('subscribe').length, greaterThanOrEqualTo(2));
      expect(bridge.connectAttempts, greaterThanOrEqualTo(2));
    });
  });

  group('topics', () {
    test('subscribe decodes into the generated Dart type', () async {
      await connect();
      final received = <Twist>[];
      ros.subscribe<Twist>('/cmd_vel').listen(received.add);
      await pump();

      bridge.publish('/cmd_vel', {
        'linear': {'x': 0.5, 'y': 0.0, 'z': 0.0},
        'angular': {'x': 0.0, 'y': 0.0, 'z': -0.25},
      });
      await pump();

      expect(received, hasLength(1));
      expect(received.single.linear.x, 0.5);
      expect(received.single.angular.z, -0.25);
    });

    test('subscribe sends the requested QoS profile', () async {
      await connect();
      ros
          .subscribe<LaserScan>('/scan', qos: QosProfile.sensorData)
          .listen((_) {});
      await pump();

      final qos = bridge.lastOf('subscribe')!['qos']! as Map<String, Object?>;
      // rosbridge only accepts lowercase policy *names*; integers fail silently.
      expect(qos['reliability'], 'best_effort');
      expect(qos['depth'], 5);
    });

    test('fans one publish out to every listener on the topic', () async {
      await connect();
      final a = <StringMsg>[], b = <StringMsg>[];
      ros.subscribe<StringMsg>('/chatter').listen(a.add);
      ros.subscribe<StringMsg>('/chatter').listen(b.add);
      await pump();

      bridge.publish('/chatter', {'data': 'hello'});
      await pump();

      expect(a.single.data, 'hello');
      expect(b.single.data, 'hello');
    });

    test('cancelling a subscription unsubscribes from the bridge', () async {
      await connect();
      final sub = ros.subscribe<StringMsg>('/chatter').listen((_) {});
      await pump();
      await sub.cancel();
      await pump();

      expect(bridge.opsOf('unsubscribe'), hasLength(1));
    });

    test('a malformed message does not kill the stream', () async {
      await connect();
      final received = <LaserScan>[];
      final errors = <RosStatus>[];
      ros.status.listen(errors.add);
      ros.subscribe<LaserScan>('/scan').listen(received.add);
      await pump();

      // `ranges` as a map is nonsense; the next good message must still arrive.
      bridge.publish('/scan', {'ranges': 'not-a-list', 'angle_min': 'bad'});
      bridge.publish('/scan', {
        'ranges': [1.0, 2.0],
        'angle_min': -1.5,
      });
      await pump();

      expect(received, hasLength(2));
      expect(received.last.ranges, [1.0, 2.0]);
    });

    test('advertise sends the correct ROS type and publishes', () async {
      await connect();
      final pub = ros.advertise<Twist>('/cmd_vel');
      pub.publish(Twist.drive(forward: 1.0, turn: 0.5));
      await pump();

      expect(bridge.lastOf('advertise')!['type'], 'geometry_msgs/msg/Twist');
      final msg = bridge.lastOf('publish')!['msg']! as Map<String, Object?>;
      expect((msg['linear']! as Map)['x'], 1.0);
      expect((msg['angular']! as Map)['z'], 0.5);
    });

    test('unregistered types fail loudly with a helpful message', () async {
      await connect();
      expect(
        () => ros.subscribe<_Unregistered>('/nope'),
        throwsA(isA<UnknownMessageTypeError>().having(
            (e) => e.toString(), 'message', contains('MessageRegistry'))),
      );
    });
  });

  group('services', () {
    test('resolves a call with the response values', () async {
      await connect();
      final future = ros.callServiceJson('/add', {'a': 2, 'b': 3});
      await pump();
      bridge.respondToCall({'sum': 5});

      expect(await future, {'sum': 5});
    });

    test('surfaces a failed call as ServiceCallException', () async {
      await connect();
      final future = ros.callServiceJson('/add', const {});
      await pump();
      bridge.respondToCall({'error': 'boom'}, result: false);

      await expectLater(future, throwsA(isA<ServiceCallException>()));
    });

    test('times out when the robot never answers', () async {
      await connect();
      await expectLater(
        ros.callServiceJson('/slow', const {},
            timeout: const Duration(milliseconds: 20)),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  group('actions', () {
    final codec = ActionCodec<_Goal, int, String>(
      actionType: 'test_msgs/action/Fibonacci',
      encodeGoal: (g) => {'order': g.order},
      decodeFeedback: (json) => (json['partial'] as num).toInt(),
      decodeResult: (json) => '${json['sequence']}',
    );

    test('streams feedback then completes with the result', () async {
      await connect();
      final handle =
          ros.sendGoal<_Goal, int, String>('/fib', _Goal(5), codec: codec);
      final feedback = <int>[];
      handle.feedback.listen(feedback.add);
      await pump();

      bridge.sendFeedback({'partial': 1});
      bridge.sendFeedback({'partial': 2});
      await pump();
      bridge.sendResult({'sequence': 'done'});

      expect(await handle.result, 'done');
      expect(feedback, [1, 2]);
      expect(bridge.lastOf('send_action_goal')!['action_type'],
          'test_msgs/action/Fibonacci');
    });

    test('an aborted goal throws ActionFailedException', () async {
      await connect();
      final handle =
          ros.sendGoal<_Goal, int, String>('/fib', _Goal(1), codec: codec);
      await pump();
      bridge.sendResult(const {}, status: GoalStatus.aborted.value);

      await expectLater(
        handle.result,
        throwsA(isA<ActionFailedException>()
            .having((e) => e.status, 'status', GoalStatus.aborted)),
      );
    });

    test('a goal with no reply fails once its timeout elapses', () async {
      await connect();
      // A goal sent to an action server that does not exist gets no reply at
      // all, so without a timeout this future never completes.
      final handle = ros.sendGoal<_Goal, int, String>(
        '/nonexistent',
        _Goal(1),
        codec: codec,
        timeout: const Duration(milliseconds: 30),
      );

      await expectLater(
        handle.result,
        throwsA(isA<ActionFailedException>()
            .having((e) => e.message, 'message', contains('No result'))),
      );
    });

    test('a goal that completes in time is unaffected by its timeout',
        () async {
      await connect();
      final handle = ros.sendGoal<_Goal, int, String>(
        '/fib',
        _Goal(1),
        codec: codec,
        timeout: const Duration(seconds: 5),
      );
      await pump();
      bridge.sendResult({'sequence': 'ok'});

      expect(await handle.result, 'ok');
    });

    test('cancel sends cancel_action_goal with the goal id', () async {
      await connect();
      final handle =
          ros.sendGoal<_Goal, int, String>('/fib', _Goal(9), codec: codec);
      await pump();
      handle.cancel();
      await pump();

      expect(bridge.lastOf('cancel_action_goal')!['id'], handle.goalId);

      // The server acknowledges the cancellation.
      bridge.sendResult(const {}, status: GoalStatus.canceled.value);
      await expectLater(
        handle.result,
        throwsA(isA<ActionFailedException>()
            .having((e) => e.status, 'status', GoalStatus.canceled)),
      );
    });
  });

  group('lifecycle safety', () {
    test('a goal whose result is never awaited does not crash on close',
        () async {
      await connect();
      final codec = ActionCodec<_Goal, int, String>(
        actionType: 'test_msgs/action/Fibonacci',
        encodeGoal: (g) => {'order': g.order},
        decodeFeedback: (json) => 0,
        decodeResult: (json) => '',
      );
      // Fire and forget, then shut down while the goal is still running.
      ros.sendGoal<_Goal, int, String>('/fib', _Goal(3), codec: codec);
      await pump();
      await ros.close();
      await pump();
      // Reaching here without an unhandled async error is the assertion.
      expect(ros.state, RosConnectionState.closed);
    });

    test('close() completes even with live subscriptions', () async {
      await connect();
      ros.subscribe<StringMsg>('/a').listen((_) {});
      ros.subscribe<Twist>('/b').listen((_) {});
      await pump();
      await ros.close().timeout(const Duration(seconds: 2));
      expect(ros.state, RosConnectionState.closed);
    });
  });

  group('encodings', () {
    test('CBOR typed arrays decode without a per-element copy', () async {
      await connect();
      final images = <RosImage>[];
      ros
          .subscribe<RosImage>('/camera/image_raw',
              compression: Compression.cbor)
          .listen(images.add);
      await pump();

      final pixels = Uint8List.fromList([10, 20, 30, 40, 50, 60]);
      bridge.emit(cborEncode(CborValue({
        'op': 'publish',
        'topic': '/camera/image_raw',
        'msg': {
          'height': 2,
          'width': 1,
          'encoding': 'rgb8',
          'step': 3,
          'data': CborBytes(pixels, tags: [CborTag.uint8Array]),
        },
      })));
      await pump();

      expect(images, hasLength(1));
      expect(images.single.data, pixels);
      expect(images.single.width, 1);
      expect(bridge.lastOf('subscribe')!['compression'], 'cbor');
    });

    test('base64 uint8[] from JSON decodes to the same bytes', () async {
      await connect();
      final images = <CompressedImage>[];
      ros.subscribe<CompressedImage>('/cam/compressed').listen(images.add);
      await pump();

      final jpeg = Uint8List.fromList([255, 216, 255, 224]);
      bridge.publish('/cam/compressed', {
        'format': 'jpeg',
        'data': base64Encode(jpeg),
      });
      await pump();

      expect(images.single.data, jpeg);
    });

    test('a reused fragment id starts a new group instead of dropping it',
        () async {
      await connect();
      final received = <StringMsg>[];
      ros.subscribe<StringMsg>('/chatter').listen(received.add);
      await pump();

      // One part of a two-part group that never completes.
      bridge.emit(jsonEncode({
        'op': 'fragment',
        'id': 'F1',
        'data': '{"op":',
        'num': 0,
        'total': 2
      }));
      await pump();

      // The same id reused for a complete single-part message.
      final whole = jsonEncode({
        'op': 'publish',
        'topic': '/chatter',
        'msg': {'data': 'second'}
      });
      bridge.emit(jsonEncode(
          {'op': 'fragment', 'id': 'F1', 'data': whole, 'num': 0, 'total': 1}));
      await pump();

      expect(received.single.data, 'second');
    });

    test('rejects a nonsense fragment header instead of allocating', () async {
      await connect();
      final errors = <RosStatus>[];
      ros.status.listen(errors.add);

      bridge.emit(jsonEncode(
          {'op': 'fragment', 'id': 'bad', 'data': 'x', 'num': 0, 'total': -1}));
      await pump();

      expect(errors.any((e) => e.level == StatusLevel.error), isTrue);
    });

    test('reassembles a fragmented message', () async {
      await connect();
      final received = <StringMsg>[];
      ros.subscribe<StringMsg>('/chatter').listen(received.add);
      await pump();

      final whole = jsonEncode({
        'op': 'publish',
        'topic': '/chatter',
        'msg': {'data': 'abc'}
      });
      final mid = whole.length ~/ 2;
      bridge.emit(jsonEncode({
        'op': 'fragment',
        'id': 'f1',
        'data': whole.substring(0, mid),
        'num': 0,
        'total': 2
      }));
      bridge.emit(jsonEncode({
        'op': 'fragment',
        'id': 'f1',
        'data': whole.substring(mid),
        'num': 1,
        'total': 2
      }));
      await pump();

      expect(received.single.data, 'abc');
    });
  });

  group('non-standard JSON from Python bridges', () {
    test('decodes bare Infinity, -Infinity and NaN in a laser scan', () async {
      await connect();
      final scans = <LaserScan>[];
      ros.subscribe<LaserScan>('/scan').listen(scans.add);
      await pump();

      // Exactly what Python's json.dumps emits for a scan with dropouts.
      bridge.emit('{"op":"publish","topic":"/scan","msg":'
          '{"angle_min":-1.5,"ranges":[1.5,Infinity,NaN,-Infinity,2.5]}}');
      await pump();

      expect(scans, hasLength(1));
      final ranges = scans.single.ranges;
      expect(ranges[0], 1.5);
      expect(ranges[1], double.infinity);
      expect(ranges[2].isNaN, isTrue);
      expect(ranges[3], double.negativeInfinity);
      expect(ranges[4], 2.5);
    });

    test('does not corrupt strings that contain those words', () async {
      await connect();
      final messages = <StringMsg>[];
      ros.subscribe<StringMsg>('/chatter').listen(messages.add);
      await pump();

      // The repair pass must skip string literals entirely.
      bridge.emit('{"op":"publish","topic":"/chatter","msg":'
          '{"data":"NaN and Infinity are words"},"extra":NaN}');
      await pump();

      expect(messages.single.data, 'NaN and Infinity are words');
    });

    test('a wrong-typed field is reported, not thrown into the zone', () async {
      await connect();
      final errors = <RosStatus>[];
      ros.status.listen(errors.add);
      final received = <StringMsg>[];
      ros.subscribe<StringMsg>('/chatter').listen(received.add);
      await pump();

      // Well-formed JSON, but `topic` is a number: handlers cast it to String.
      bridge.emit('{"op":"publish","topic":123,"msg":{"data":"x"}}');
      await pump();

      expect(errors.any((e) => e.level == StatusLevel.error), isTrue);

      // And the client keeps working afterwards.
      bridge.publish('/chatter', {'data': 'still alive'});
      await pump();
      expect(received.single.data, 'still alive');
    });

    test('genuinely malformed JSON still reports an error', () async {
      await connect();
      final errors = <RosStatus>[];
      ros.status.listen(errors.add);

      bridge.emit('{"op":"publish","topic":');
      await pump();

      expect(errors.any((e) => e.level == StatusLevel.error), isTrue);
    });
  });

  group('introspection', () {
    test('listTopics zips names with types', () async {
      await connect();
      final future = ros.listTopics();
      await pump();
      bridge.respondToCall({
        'topics': ['/scan', '/cmd_vel'],
        'types': ['sensor_msgs/msg/LaserScan', 'geometry_msgs/msg/Twist'],
      });

      expect(await future, [
        const TopicInfo('/scan', 'sensor_msgs/msg/LaserScan'),
        const TopicInfo('/cmd_vel', 'geometry_msgs/msg/Twist'),
      ]);
    });

    test('getParam decodes the JSON-encoded value', () async {
      await connect();
      final future = ros.getParam('/turtlesim:background_r');
      await pump();
      bridge.respondToCall({'value': '255', 'successful': true});

      expect(await future, 255);
    });

    test('unqualified parameter names are rejected up front', () async {
      await connect();
      expect(
        () => ros.getParam('background_r'),
        throwsA(isA<ArgumentError>()
            .having((e) => e.message, 'message', contains('<node>:<param>'))),
      );
    });
  });

  group('non-finite floats on publish', () {
    test('encodes inf and nan as null instead of throwing', () {
      // jsonEncode throws on non-finite doubles, and ROS produces them
      // constantly -- every out-of-range lidar beam is inf.
      final scan = LaserScan(
        ranges: Float32List.fromList([1.0, double.infinity, double.nan]),
        intensities: Float32List(0),
      );
      final encoded = WireCodec.encode({'op': 'publish', 'msg': scan.toJson()});
      expect(encoded, contains('[1.0,null,null]'));
    });

    test('encodes a non-finite scalar as null', () {
      final encoded = WireCodec.encode(
          {'op': 'publish', 'msg': const Float64Msg(double.nan).toJson()});
      expect(encoded, contains('"data":null'));
    });
  });

  group('message equality', () {
    test('sensor and nav messages compare by value, not identity', () {
      // The RosMessage contract promises value semantics so messages can be
      // used as Flutter widget inputs and cache keys.
      final a = LaserScan(
          ranges: Float32List.fromList([1, 2]), intensities: Float32List(0));
      final b = LaserScan(
          ranges: Float32List.fromList([1, 2]), intensities: Float32List(0));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final c = LaserScan(
          ranges: Float32List.fromList([1, 3]), intensities: Float32List(0));
      expect(a, isNot(equals(c)));
    });

    test('images with equal bytes but separate buffers compare equal', () {
      final a = RosImage(width: 2, data: Uint8List.fromList([1, 2, 3]));
      final b = RosImage(width: 2, data: Uint8List.fromList([1, 2, 3]));
      expect(a, equals(b));
    });

    test('NavSatFix preserves the constellation bitmask', () {
      final decoded = NavSatFix.fromJson(const {
        'status': {'status': 1, 'service': 7},
        'latitude': 1.0,
      });
      expect(decoded.service, 7);
      // And it survives a round trip rather than being reset to zero.
      expect(NavSatFix.fromJson(decoded.toJson()).service, 7);
    });
  });

  group('message registry', () {
    test('re-registering a type updates both the full and short names', () {
      // The two aliases for one ROS type must never resolve to different
      // codecs.
      const first = MessageCodec<StringMsg>(
          rosType: 'demo_msgs/msg/Thing',
          fromJson: StringMsg.fromJson,
          toJson: _stringToJson);
      const second = MessageCodec<StringMsg>(
          rosType: 'demo_msgs/msg/Thing',
          fromJson: StringMsg.fromJson,
          toJson: _stringToJson);

      MessageRegistry.register(first);
      MessageRegistry.register(second);

      expect(
          identical(MessageRegistry.byRosType('demo_msgs/msg/Thing'),
              MessageRegistry.byRosType('demo_msgs/Thing')),
          isTrue);
    });
  });

  group('protocol enums', () {
    test('Compression exposes every wire encoding', () {
      // Nothing in the library references Compression.png, so losing it to a
      // doc-comment edit did not fail analysis. This pins all four.
      expect(Compression.values.map((c) => c.wireName),
          containsAll(['none', 'png', 'cbor', 'cbor-raw']));
    });
  });

  group('QoS', () {
    test('named profiles match the rmw defaults', () {
      expect(QosProfile.sensorData.reliability, Reliability.bestEffort);
      expect(QosProfile.transientLocal.durability, Durability.transientLocal);
      expect(QosProfile.default_.reliability, Reliability.reliable);
    });

    test('serialises durations as secs/nsecs, the name rosbridge expects', () {
      const qos = QosProfile(deadline: Duration(milliseconds: 1500));
      final wire = qos.toWire()['deadline']! as Map<String, Object?>;
      expect(wire['secs'], 1);
      expect(wire['nsecs'], 500000000);
    });

    test('omits zero durations rather than sending them as zero', () {
      // A zero duration means "unset"; sending it would pin a real deadline.
      final wire = QosProfile.default_.toWire();
      expect(wire.containsKey('deadline'), isFalse);
      expect(wire.containsKey('lifespan'), isFalse);
    });

    test('omits system-default policies, which rosbridge cannot parse', () {
      final wire = QosProfile.systemDefault.toWire();
      expect(wire.containsKey('history'), isFalse);
      expect(wire.containsKey('reliability'), isFalse);
      expect(wire.containsKey('durability'), isFalse);
      expect(wire['depth'], 10);
    });

    test('emits string policy names for every named profile', () {
      expect(
          QosProfile.transientLocal.toWire()['durability'], 'transient_local');
      expect(QosProfile.default_.toWire()['reliability'], 'reliable');
      expect(QosProfile.default_.toWire()['history'], 'keep_last');
    });
  });

  group('reconnect policy', () {
    test('backs off exponentially and respects the cap', () {
      const policy = ReconnectPolicy(
        initialDelay: Duration(milliseconds: 100),
        maxDelay: Duration(seconds: 1),
        jitter: 0,
      );
      double fixed() => 0.5;
      expect(policy.delayFor(0, random: fixed).inMilliseconds, 100);
      expect(policy.delayFor(1, random: fixed).inMilliseconds, 200);
      expect(policy.delayFor(2, random: fixed).inMilliseconds, 400);
      expect(policy.delayFor(10, random: fixed).inMilliseconds, 1000);
    });

    test('ReconnectPolicy.none never retries', () {
      expect(ReconnectPolicy.none.shouldRetry(0), isFalse);
    });

    test('backoff does not reset until the link has proved stable', () async {
      // A server that accepts a connection then immediately drops it must be
      // backed off, not retried at the initial delay forever.
      final farm = FakeBridgeFarm();
      final client = Ros2Client(
        Uri.parse('ws://fake:9090'),
        transportFactory: (_) => farm.create(),
        reconnectPolicy: const ReconnectPolicy(
          initialDelay: Duration(milliseconds: 10),
          jitter: 0,
          stabilityWindow: Duration(seconds: 30),
        ),
      );
      addTearDown(client.close);
      await client.connect();
      expect(farm.connectAttempts, 1);

      farm.current.drop();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(farm.connectAttempts, 2, reason: 'first retry after ~10ms');

      farm.current.drop();
      // The second backoff is ~20ms, so nothing new inside 15ms.
      await Future<void>.delayed(const Duration(milliseconds: 15));
      expect(farm.connectAttempts, 2,
          reason: 'backoff grew instead of resetting on the brief connect');

      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(farm.connectAttempts, 3);
    });
  });
}

/// Lets microtasks and timers drain so stream events land.
Future<void> pump() => Future<void>.delayed(Duration.zero);

final class _Goal {
  _Goal(this.order);
  final int order;
}

final class _Unregistered {}

Map<String, Object?> _stringToJson(StringMsg m) => m.toJson();
