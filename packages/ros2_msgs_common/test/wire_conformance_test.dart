// The generated classes against what rosbridge 2.0.8 accepts. Each of these
// was a publish the bridge dropped with an error only on its own console.
import 'dart:convert';
import 'dart:typed_data';

import 'package:ros2_client/ros2_client.dart';
import 'package:ros2_msgs_common/humble/action_msgs.dart' as humble_action;
import 'package:ros2_msgs_common/humble/geometry_msgs.dart' as humble_geo;
import 'package:ros2_msgs_common/humble/std_msgs.dart' as humble;
import 'package:ros2_msgs_common/jazzy/std_msgs.dart' as jazzy;
import 'package:test/test.dart';

/// What the client would put on the wire for [message].
Map<String, Object?> wire(RosMessage message) =>
    jsonDecode(WireCodec.encode(message.toJson())) as Map<String, Object?>;

void main() {
  group('std_msgs/ByteMultiArray', () {
    // byte[] is sequence<octet>, which rosbridge does not base64-decode: it
    // rejects a string with "msg is not a list type, but a <class 'str'>".
    test('humble sends data as a list of ints', () {
      final m = humble.ByteMultiArray(data: Uint8List.fromList([1, 2, 255]));
      expect(wire(m)['data'], [1, 2, 255]);
    });

    test('jazzy sends data as a list of ints', () {
      final m = jazzy.ByteMultiArray(data: Uint8List.fromList([1, 2, 255]));
      expect(wire(m)['data'], [1, 2, 255]);
    });

    test('decodes the list form back', () {
      final m = humble.ByteMultiArray.fromJson({
        'layout': {'dim': <Object?>[], 'data_offset': 0},
        'data': [7, 8],
      });
      expect(m.data, [7, 8]);
    });
  });

  group('uint64 at or above 2^63', () {
    test('UInt64 round-trips the maximum through the wire', () {
      final text = '{"data":18446744073709551615}';
      final decoded = humble.UInt64.fromJson(
          WireCodec.decodeJson(text) as Map<String, Object?>);
      expect(decoded.data, -1, reason: 'held as its two\'s-complement bits');
      expect(WireCodec.encode(decoded.toJson()), text);
    });

    test('UInt64MultiArray encodes each element unsigned', () {
      final m =
          humble.UInt64MultiArray(data: Uint64List.fromList([1, -1, 1 << 63]));
      expect(WireCodec.encode({'data': m.toJson()['data']}),
          '{"data":[1,18446744073709551615,9223372036854775808]}');
    });
  });

  group('an absent fixed-size array decodes at its declared length', () {
    // rosbridge asserts the length; [] made the message unpublishable.
    test('PoseWithCovariance keeps 36 covariance entries', () {
      final m = humble_geo.PoseWithCovariance.fromJson(const {});
      expect(m.covariance, hasLength(36));
      expect(wire(m)['covariance'], hasLength(36));
    });

    test('a nested UUID decodes as 16 bytes', () {
      final m = humble_action.GoalInfo.fromJson(const {});
      expect(m.goalId.uuid, hasLength(16));
    });
  });
}
