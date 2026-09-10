// What a decoded field means when the wire does not carry a plain number.
//
// rosbridge writes `null` for every non-finite float, and omits nothing — so
// an absent key and a null value mean different things, and conflating them
// turns "no measurement" into a confident zero.
import 'dart:math' as math;

import 'package:ros2_client/ros2_client.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(registerStandardMessages);

  group('absent versus null', () {
    test('an absent key takes the declared default', () {
      expect(Field.doubleAt(const {}, 'x'), 0.0);
      expect(Field.doubleAt(const {}, 'w', 1), 1.0);
      expect(Field.intAt(const {}, 'n', 7), 7);
      expect(Field.boolAt(const {}, 'b', true), isTrue);
      expect(Field.stringAt(const {}, 's', 'none'), 'none');
    });

    test('a null float is NaN, because that is what null meant', () {
      // message_conversion.py: "JSON does not support Inf and NaN. They are
      // mapped to None and encoded as null."
      expect(Field.doubleAt(const {'x': null}, 'x').isNaN, isTrue);
      // Even when a default exists: the field was sent, and it was not finite.
      expect(Field.doubleAt(const {'w': null}, 'w', 1).isNaN, isTrue);
    });

    test('a present value wins over the default', () {
      expect(Field.doubleAt(const {'w': 0.5}, 'w', 1), 0.5);
      expect(Field.intAt(const {'n': 3}, 'n', 7), 3);
    });

    test('scalars now agree with the array converters', () {
      // The array path has always mapped null to NaN; scalars returned 0.
      expect(Field.asFloat64List(const [null]).single.isNaN, isTrue);
      expect(Field.doubleAt(const {'x': null}, 'x').isNaN, isTrue);
    });
  });

  group('a NaN measurement is not a zero reading', () {
    test('BatteryState keeps unknown values unknown', () {
      const frame = '{"op":"publish","topic":"/battery","msg":'
          '{"voltage":12.4,"current":NaN,"charge":NaN,"percentage":NaN}}';
      final battery = BatteryState.fromJson(
          WireCodec.decode(frame)['msg']! as Map<String, Object?>);

      // ROS uses NaN for "unknown" throughout BatteryState. Reporting 0%
      // charge on a healthy robot is worse than reporting nothing.
      expect(battery.percentage.isNaN, isTrue);
      expect(battery.charge.isNaN, isTrue);
      expect(battery.voltage, 12.4);
    });
  });

  group('an absent nested message is valid, not all-zero', () {
    test('an absent rotation decodes to the identity quaternion', () {
      // geometry_msgs/Quaternion declares `float64 w 1`.
      expect(Field.asMessage(null, Quaternion.fromJson), Quaternion.identity);
      expect(Pose.fromJson(const {}).orientation, Quaternion.identity);
      expect(const RosTransform().rotation, Quaternion.identity);
    });

    test('so one absent link no longer erases a whole rotation chain', () {
      final absent = Field.asMessage(null, Quaternion.fromJson);
      final quarterTurn = Quaternion.fromYaw(math.pi / 2);

      // The zero quaternion behaves like identity when rotating a point but
      // annihilates a Hamilton product, so a 90-degree turn silently became
      // no turn at all, with no exception and no NaN to notice.
      final composed = absent * quarterTurn;
      final rotated = composed.rotate(const Vector3(x: 1));
      expect(rotated.y, closeTo(1.0, 1e-9));
      expect(composed.norm, closeTo(1.0, 1e-9));
    });

    test('ColorRGBA defaults to opaque', () {
      expect(ColorRGBA.fromJson(const {}).a, 1.0);
    });
  });

  group('arrays of messages', () {
    test('a corrupt element is reported, not silently dropped', () {
      // Dropping renumbers everything after it: a path's waypoints shift by
      // one with nothing to indicate they had.
      expect(
        () => RosPath.fromJson(const {
          'poses': [
            {
              'pose': {
                'position': {'x': 1.0}
              }
            },
            null,
            {
              'pose': {
                'position': {'x': 3.0}
              }
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('a loosely typed map is accepted rather than yielding nothing', () {
      // whereType<Map<String, Object?>> filtered these out, so the array
      // decoded as empty instead of failing.
      final path = RosPath.fromJson(<String, Object?>{
        'poses': [
          <Object?, Object?>{
            'pose': {
              'position': {'x': 1.5},
            },
          },
        ],
      });
      expect(path.poses.single.pose.position.x, 1.5);
    });

    test('a well-formed array still decodes in order', () {
      final path = RosPath.fromJson(const {
        'poses': [
          {
            'pose': {
              'position': {'x': 1.0}
            }
          },
          {
            'pose': {
              'position': {'x': 2.0}
            }
          },
        ],
      });
      expect(path.poses.map((p) => p.pose.position.x), [1.0, 2.0]);
    });
  });
}
