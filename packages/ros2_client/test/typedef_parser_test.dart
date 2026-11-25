// Fixtures here are verbatim `rosapi/message_details` output, captured from
// rosapi 2.0.7 on ROS 2 Humble. The quirks they pin — IDL primitive spellings,
// field names reported as constants, SLOT_TYPES — are all real.
import 'package:ros2_client/src/codegen/interface_def.dart';
import 'package:ros2_client/src/codegen/interface_parser.dart';
import 'package:ros2_client/src/codegen/library_writer.dart';
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

/// The `.msg` [defaultsTypedef] was captured from.
const defaultsMsg = '''
float32[3] xyz [0.5, 1.5, 2.5]
int32[] codes [1, 2, 3]
string name "m1"
bool on true
uint8 attempts 3
float64 gain -0.25
string[] tags ["a", "b"]
int64 big 9007199254740993
float64 plain
''';

/// `get_typedef` for [defaultsMsg], captured from rosapi 4.2.1 on Lyrical
/// (SLOT_TYPES trimmed). Each field with a declared default gets a
/// `<FIELD>__DEFAULT` entry holding a Python repr, in a different shape per
/// kind; `plain` declares none and gets none.
const defaultsTypedef = {
  'type': 'demo_robot_msgs/Defaults',
  'fieldnames': [
    'xyz', 'codes', 'name', 'on', 'attempts', 'gain', 'tags', 'big', 'plain' //
  ],
  'fieldtypes': [
    'float', 'int32', 'string', 'boolean', 'uint8', 'double', 'string', //
    'int64', 'double',
  ],
  'fieldarraylen': [3, 0, -1, -1, -1, -1, 0, -1, -1],
  'examples': [
    '[]', '[]', 'm1', 'True', '3', '-0.25', '[]', '9007199254740993', '0.0' //
  ],
  'constnames': [
    'ATTEMPTS__DEFAULT',
    'BIG__DEFAULT',
    'CODES__DEFAULT',
    'GAIN__DEFAULT',
    'NAME__DEFAULT',
    'ON__DEFAULT',
    'SLOT_TYPES',
    'TAGS__DEFAULT',
    'XYZ__DEFAULT',
    'attempts',
    'big',
    'codes',
    'gain',
    'name',
    'on',
    'plain',
    'tags',
    'xyz',
  ],
  'constvalues': [
    '3',
    '9007199254740993',
    "array('i', [1, 2, 3])",
    '-0.25',
    'm1',
    'True',
    '(<rosidl_parser.definition.Array object at 0x7f>,)',
    "['a', 'b']",
    '[0.5 1.5 2.5]',
    '3',
    '9007199254740993',
    "array('i', [1, 2, 3])",
    '-0.25',
    'm1',
    'True',
    '0.0',
    "['a', 'b']",
    '[0.5 1.5 2.5]',
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

      expect(
          scan.fields.firstWhere((f) => f.name == 'angle_min').type, 'float32');
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

      final covariance = pose.fields.firstWhere((f) => f.name == 'covariance');
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

  group('declared defaults (rosapi 4.x)', () {
    test('a field default is a default, not a constant', () {
      final defaults = parse(defaultsTypedef);
      // Listed as ATTEMPTS__DEFAULT and friends, these became constants such
      // as `attemptsDefault`, while the fields themselves defaulted to zero.
      expect(defaults.constants, isEmpty);
      final byName = {for (final f in defaults.fields) f.name: f.defaultValue};
      expect(byName, {
        'xyz': '[0.5, 1.5, 2.5]',
        'codes': '[1, 2, 3]',
        'name': '"m1"',
        'on': 'True',
        'attempts': '3',
        'gain': '-0.25',
        'tags': "['a', 'b']",
        'big': '9007199254740993',
        'plain': null,
      });
    });

    test('generates the same code as the .msg it came from', () {
      String emit(MessageDef m) =>
          LibraryWriter(package: 'demo_robot_msgs', messages: [m]).write();
      final offline = InterfaceParser.parseMessage(defaultsMsg,
          package: 'demo_robot_msgs', name: 'Defaults');
      final online = emit(parse(defaultsTypedef));
      expect(online, emit(offline));
      expect(online, contains('this.attempts = 3'));
    });

    test('reads each repr shape rosapi uses', () {
      String read(String type, String python, {bool isArray = false}) =>
          TypedefParser.msgDefault('demo/T', 'f', type, python,
              isArray: isArray);
      expect(
          read('float64', '[0.  1.5 2. ]', isArray: true), '[0.0, 1.5, 2.0]');
      expect(read('float64', '[1.e-03 2.5e+00]', isArray: true),
          '[1.0e-03, 2.5e+00]');
      expect(read('bool', '[ True False]', isArray: true), '[True, False]');
      expect(read('float64', "array('d')", isArray: true), '[]');
      expect(read('string', "['a b.']", isArray: true), "['a b.']");
      // A string that happens to be quoted keeps its quotes.
      expect(read('string', '"quoted"'), '""quoted""');
    });

    // Verbatim str() of rosidl's Python defaults on Lyrical, for
    // `byte mode 3`, `byte[] raw [1, 2]`, `float64[2] k [0.123456789012, 1.0]`,
    // `float64[] dyn [0.123456789012]` and `string sep " | "`.
    test('decodes byte defaults, which Python holds as bytes', () {
      String read(String python, {bool isArray = false}) =>
          TypedefParser.msgDefault('demo/Edge', 'f', 'byte', python,
              isArray: isArray);
      expect(read(r"b'\x03'"), '3');
      expect(read(r"[b'\x01', b'\x02']", isArray: true), '[1, 2]');
      // 0x2c is a comma, and 0x27 a quote; neither may split the list.
      expect(read(r"""[b',', b"'", b'A']""", isArray: true), '[44, 39, 65]');
      expect(() => read('3'), throwsA(isA<TypedefException>()));
    });

    test('refuses a fixed float array numpy may have rounded', () {
      // numpy prints at most 8 significant digits.
      expect(
          () => TypedefParser.msgDefault(
              'demo/Edge', 'k', 'float64', '[0.12345679 1.        ]',
              isArray: true),
          throwsA(isA<TypedefException>()));
      // Fewer digits were printed exactly.
      expect(
          TypedefParser.msgDefault('demo/Edge', 'h', 'float64', '[0.5  0.25]',
              isArray: true),
          '[0.5, 0.25]');
      // An unbounded array keeps full precision.
      expect(
          TypedefParser.msgDefault(
              'demo/Edge', 'dyn', 'float64', "array('d', [0.123456789012])",
              isArray: true),
          '[0.123456789012]');
      // Integers are printed exactly however long.
      expect(
          TypedefParser.msgDefault(
              'demo/Edge', 'i', 'int64', '[123456789012 2]',
              isArray: true),
          '[123456789012, 2]');
    });

    test('keeps the whitespace of a string default', () {
      expect(
          TypedefParser.msgDefault('demo/Edge', 'sep', 'string', ' | ',
              isArray: false),
          '" | "');
    });

    test('refuses what it cannot read rather than guessing', () {
      // numpy elides arrays longer than its print threshold.
      expect(
          () => TypedefParser.msgDefault(
              'demo/T', 'f', 'float64', '[0. 0. 0. ... 0. 0. 0.]',
              isArray: true),
          throwsA(isA<TypedefException>()
              .having((e) => e.message, 'message', contains('--search'))));
      expect(
          () => TypedefParser.msgDefault('demo/T', 'f', 'uint8', r"b'\x01\x02'",
              isArray: true),
          throwsA(isA<TypedefException>()));
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
