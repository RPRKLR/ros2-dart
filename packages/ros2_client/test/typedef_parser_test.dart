// Fixtures here are verbatim `rosapi/message_details` output, captured from
// rosapi 2.0.7 on ROS 2 Humble. The quirks they pin — IDL primitive spellings,
// field names reported as constants, SLOT_TYPES — are all real.
import 'package:ros2_client/src/codegen/interface_def.dart';
import 'package:ros2_client/src/codegen/typedef_parser.dart';
import 'package:test/test.dart';

/// `get_typedef('geometry_msgs/Point')`.
const pointTypedef = {
  'type': 'geometry_msgs/Point',
  'fieldnames': ['x', 'y', 'z'],
  'fieldtypes': ['double', 'double', 'double'],
  'fieldarraylen': [-1, -1, -1],
  'examples': ['0.0', '0.0', '0.0'],
  'constnames': ['SLOT_TYPES', 'x', 'y', 'z'],
  'constvalues': [
    '(<rosidl_parser.definition.BasicType object at 0x7cfcfcfbe8f0>,)',
    '0.0',
    '0.0',
    '0.0',
  ],
};

/// `get_typedef('sensor_msgs/LaserScan')`, trimmed to the interesting fields.
const laserScanTypedef = {
  'type': 'sensor_msgs/LaserScan',
  'fieldnames': ['header', 'angle_min', 'ranges', 'intensities'],
  'fieldtypes': ['std_msgs/Header', 'float', 'float', 'float'],
  'fieldarraylen': [-1, -1, 0, 0],
  'examples': ['{}', '0.0', '[]', '[]'],
  'constnames': <String>[],
  'constvalues': <String>[],
};

/// `get_typedef('geometry_msgs/PoseWithCovariance')` — a fixed-length array.
const poseWithCovarianceTypedef = {
  'type': 'geometry_msgs/PoseWithCovariance',
  'fieldnames': ['pose', 'covariance'],
  'fieldtypes': ['geometry_msgs/Pose', 'double'],
  'fieldarraylen': [-1, 36],
  'examples': ['{}', '[]'],
  'constnames': ['SLOT_TYPES', 'covariance', 'pose'],
  'constvalues': ['(<rosidl_parser...>,)', '[0. 0. 0.]', 'geometry_msgs...'],
};

/// `get_typedef('visualization_msgs/Marker')`, trimmed. Marker is the reason
/// constant filtering has to be per-message: it has real constants *and*
/// fields whose names collide with them in the same flat list.
const markerTypedef = {
  'type': 'visualization_msgs/Marker',
  'fieldnames': ['id', 'type', 'action', 'points', 'frame_locked'],
  'fieldtypes': ['int32', 'int32', 'int32', 'geometry_msgs/Point', 'boolean'],
  'fieldarraylen': [-1, -1, -1, 0, -1],
  'examples': ['0', '0', '0', '[]', 'False'],
  'constnames': [
    'ADD',
    'ARROW',
    'CUBE',
    'POINTS',
    'SLOT_TYPES',
    'action',
    'frame_locked',
    'id',
    'points',
    'type',
  ],
  'constvalues': [
    '0',
    '0',
    '1',
    '8',
    '(<rosidl_parser.definition.NamedType object at 0x7f>,)',
    '0',
    'False',
    '0',
    '[]',
    '0',
  ],
};

MessageDef parse(Map<String, Object?> json) =>
    TypedefParser.toMessage(RosTypeDef.fromJson(json));

void main() {
  group('primitive spelling', () {
    test('remaps IDL names to the ROS names the emitter expects', () {
      final point = parse(pointTypedef);

      expect(point.package, 'geometry_msgs');
      expect(point.name, 'Point');
      // rosapi says "double"; a .msg file says "float64". Generating the
      // former produces a reference to a nested class that does not exist.
      expect(point.fields.map((f) => f.type), everyElement('float64'));
      expect(point.fields.map((f) => f.name), ['x', 'y', 'z']);
    });

    test('maps float to float32 and boolean to bool', () {
      final marker = parse(markerTypedef);
      final scan = parse(laserScanTypedef);

      expect(scan.fields.firstWhere((f) => f.name == 'angle_min').type,
          'float32');
      expect(marker.fields.firstWhere((f) => f.name == 'frame_locked').type,
          'bool');
    });

    test('leaves nested message types as package/Type', () {
      final scan = parse(laserScanTypedef);
      expect(
          scan.fields.firstWhere((f) => f.name == 'header').type,
          // The offline parser stores what the .msg says, so the online path
          // must not helpfully expand this to std_msgs/msg/Header.
          'std_msgs/Header');
    });
  });

  group('arrays', () {
    test('reads -1, 0 and N as none, unbounded and fixed', () {
      final scan = parse(laserScanTypedef);
      final pose = parse(poseWithCovarianceTypedef);

      expect(scan.fields.firstWhere((f) => f.name == 'header').arrayKind,
          ArrayKind.none);
      expect(scan.fields.firstWhere((f) => f.name == 'ranges').arrayKind,
          ArrayKind.unbounded);

      final covariance =
          pose.fields.firstWhere((f) => f.name == 'covariance');
      expect(covariance.arrayKind, ArrayKind.fixed);
      expect(covariance.arraySize, 36);
      expect(covariance.type, 'float64');
    });

    test('rejects a bounded type rather than naming a class after it', () {
      // rosapi's own regex turns `sequence<double, 3>` into `double, 3`.
      // It raises before returning today, but must never be generated.
      expect(
        () => parse({
          'type': 'shape_msgs/SolidPrimitive',
          'fieldnames': ['dimensions'],
          'fieldtypes': ['double, 3'],
          'fieldarraylen': [0],
          'constnames': <String>[],
          'constvalues': <String>[],
        }),
        throwsA(isA<TypedefException>()
            .having((e) => e.message, 'message', contains('--search'))),
      );
    });

    test('rejects a bounded string', () {
      expect(
        () => parse({
          'type': 'rmw_dds_common/NodeEntitiesInfo',
          'fieldnames': ['node_name'],
          'fieldtypes': ['string<256>'],
          'fieldarraylen': [-1],
          'constnames': <String>[],
          'constvalues': <String>[],
        }),
        throwsA(isA<TypedefException>()),
      );
    });
  });

  group('constants', () {
    test('keeps real constants and drops the fields rosapi mixes in', () {
      final marker = parse(markerTypedef);
      final names = marker.constants.map((c) => c.name).toList();

      expect(names, ['ADD', 'ARROW', 'CUBE', 'POINTS']);
      // SLOT_TYPES' value is a Python repr containing a memory address, so it
      // is never stable and never a constant.
      expect(names, isNot(contains('SLOT_TYPES')));
      // `type`, `id`, `action` and `points` are fields, listed here with their
      // default values purely because rosapi walks inspect.getmembers.
      expect(names, isNot(contains('type')));
      expect(names, isNot(contains('points')));

      expect(marker.constants.firstWhere((c) => c.name == 'POINTS').value, '8');
    });

    test('drops every reported constant when all of them are fields', () {
      expect(parse(pointTypedef).constants, isEmpty);
    });

    test('infers a type from the stringified value', () {
      expect(TypedefParser.inferConstantType('8'), 'int32');
      expect(TypedefParser.inferConstantType('-1'), 'int32');
      expect(TypedefParser.inferConstantType('1.5'), 'float64');
      // Python stringifies booleans capitalised.
      expect(TypedefParser.inferConstantType('True'), 'bool');
      expect(TypedefParser.inferConstantType('False'), 'bool');
      expect(TypedefParser.inferConstantType('warn'), 'string');
    });
  });

  group('malformed responses', () {
    test('rejects parallel arrays of different lengths', () {
      expect(
        () => parse({
          'type': 'pkg/Thing',
          'fieldnames': ['a', 'b'],
          'fieldtypes': ['int32'],
          'fieldarraylen': [-1, -1],
        }),
        throwsA(isA<TypedefException>()
            .having((e) => e.message, 'message', contains('inconsistent'))),
      );
    });

    test('rejects a type name with no package', () {
      expect(
        () => parse({
          'type': 'Thing',
          'fieldnames': <String>[],
          'fieldtypes': <String>[],
          'fieldarraylen': <int>[],
        }),
        throwsA(isA<TypedefException>()),
      );
    });

    test('accepts the three-segment form as well', () {
      final def = parse({
        'type': 'sensor_msgs/msg/Imu',
        'fieldnames': <String>[],
        'fieldtypes': <String>[],
        'fieldarraylen': <int>[],
      });
      expect(def.package, 'sensor_msgs');
      expect(def.name, 'Imu');
      expect(def.rosType, 'sensor_msgs/msg/Imu');
    });
  });
}
