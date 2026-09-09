import 'package:ros2_client/src/codegen/dart_emitter.dart';
import 'package:ros2_client/src/codegen/interface_def.dart';
import 'package:ros2_client/src/codegen/interface_parser.dart';
import 'package:ros2_client/src/codegen/library_writer.dart';
import 'package:test/test.dart';

MessageDef parse(String source,
        {String pkg = 'test_msgs', String name = 'T'}) =>
    InterfaceParser.parseMessage(source, package: pkg, name: name);

void main() {
  group('parser: fields', () {
    test('reads a plain field', () {
      final msg = parse('float64 radius');
      expect(msg.fields.single.type, 'float64');
      expect(msg.fields.single.name, 'radius');
      expect(msg.fields.single.isArray, isFalse);
    });

    test('distinguishes the three array forms', () {
      final msg = parse('''
float64[] unbounded
float64[3] fixed
float64[<=8] bounded
''');
      expect(msg.fields[0].arrayKind, ArrayKind.unbounded);
      expect(msg.fields[1].arrayKind, ArrayKind.fixed);
      expect(msg.fields[1].arraySize, 3);
      expect(msg.fields[2].arrayKind, ArrayKind.bounded);
      expect(msg.fields[2].arraySize, 8);
    });

    test('reads bounded strings, including bounded arrays of them', () {
      final msg = parse('''
string<=10 short_name
string<=5[<=3] names
''');
      expect(msg.fields[0].type, 'string');
      expect(msg.fields[0].stringBound, 10);
      expect(msg.fields[1].type, 'string');
      expect(msg.fields[1].stringBound, 5);
      expect(msg.fields[1].arrayKind, ArrayKind.bounded);
    });

    test('reads nested and namespaced types', () {
      final msg = parse('''
std_msgs/Header header
geometry_msgs/Pose[] poses
''');
      expect(msg.fields[0].type, 'std_msgs/Header');
      expect(msg.fields[1].type, 'geometry_msgs/Pose');
      expect(msg.fields[1].isArray, isTrue);
    });

    test('captures default values', () {
      final msg = parse('int32 count 42');
      expect(msg.fields.single.defaultValue, '42');
    });
  });

  group('parser: constants and comments', () {
    test('separates constants from fields', () {
      final msg = parse('''
int8 STATUS_NO_FIX = -1
int8 STATUS_FIX = 0
int8 status
''');
      expect(msg.constants, hasLength(2));
      expect(msg.constants.first.name, 'STATUS_NO_FIX');
      expect(msg.constants.first.value, '-1');
      expect(msg.fields, hasLength(1));
    });

    test('a bounded string is not mistaken for a constant', () {
      final msg = parse('string<=5 name');
      expect(msg.constants, isEmpty);
      expect(msg.fields, hasLength(1));
    });

    test('strips trailing comments but keeps them as docs', () {
      final msg = parse('float64 x  # metres from origin');
      expect(msg.fields.single.name, 'x');
      expect(msg.fields.single.comment, 'metres from origin');
    });

    test('a # inside a quoted default is not a comment', () {
      final msg = parse('string label "a # b"  # real comment');
      expect(msg.fields.single.defaultValue, '"a # b"');
      expect(msg.fields.single.comment, 'real comment');
    });

    test('collects the leading block as a doc comment', () {
      final msg = parse('''
# A test message.
# Second line.

int32 x
''');
      expect(msg.docComment, contains('A test message.'));
      expect(msg.docComment, contains('Second line.'));
    });
  });

  group('parser: services and actions', () {
    test('splits a .srv on ---', () {
      final srv = InterfaceParser.parseService(
        'int64 a\nint64 b\n---\nint64 sum\n',
        package: 'example_interfaces',
        name: 'AddTwoInts',
      );
      expect(srv.request.fields.map((f) => f.name), ['a', 'b']);
      expect(srv.response.fields.single.name, 'sum');
      expect(srv.rosType, 'example_interfaces/srv/AddTwoInts');
    });

    test('splits an .action on two ---', () {
      final action = InterfaceParser.parseAction(
        'float32 theta\n---\nfloat32 delta\n---\nfloat32 remaining\n',
        package: 'turtlesim',
        name: 'RotateAbsolute',
      );
      expect(action.goal.fields.single.name, 'theta');
      expect(action.result.fields.single.name, 'delta');
      expect(action.feedback.fields.single.name, 'remaining');
    });

    test('rejects a .srv with the wrong number of separators', () {
      expect(
        () => InterfaceParser.parseService('a\n---\nb\n---\nc',
            package: 'p', name: 'N'),
        throwsA(isA<InterfaceParseException>()),
      );
    });
  });

  group('emitter: naming', () {
    test('snake_case becomes camelCase', () {
      expect(DartEmitter.fieldName('angle_min'), 'angleMin');
      expect(DartEmitter.fieldName('child_frame_id'), 'childFrameId');
    });

    test('Dart keywords get a suffix', () {
      expect(DartEmitter.fieldName('default'), 'defaultValue');
      expect(DartEmitter.fieldName('class'), 'classValue');
    });

    test('names colliding with material.dart are Ros-prefixed', () {
      expect(DartEmitter.className('sensor_msgs/Image'), 'RosImage');
      expect(DartEmitter.className('nav_msgs/Path'), 'RosPath');
      expect(DartEmitter.className('turtlesim/Color'), 'RosColor');
      expect(DartEmitter.className('sensor_msgs/LaserScan'), 'LaserScan');
    });

    test('a constant clashing with a field is renamed, not the field', () {
      // visualization_msgs/Marker really does have `int32 POINTS=8` and
      // `Point[] points`, which collapse to the same Dart identifier.
      expect(
          DartEmitter.constantName('POINTS', taken: {'points'}), 'pointsConst');
      expect(DartEmitter.constantName('POINTS'), 'points');
    });
  });

  group('emitter: types', () {
    FieldDef f(String type, {bool array = false}) => FieldDef(
          type: type,
          name: 'v',
          arrayKind: array ? ArrayKind.unbounded : ArrayKind.none,
        );

    test('numeric arrays map to typed-data lists', () {
      expect(DartEmitter.dartTypeOf(f('uint8', array: true)), 'Uint8List');
      expect(DartEmitter.dartTypeOf(f('float32', array: true)), 'Float32List');
      expect(DartEmitter.dartTypeOf(f('int32', array: true)), 'Int32List');
    });

    test('bool and string arrays map to plain lists', () {
      expect(DartEmitter.dartTypeOf(f('bool', array: true)), 'List<bool>');
      expect(DartEmitter.dartTypeOf(f('string', array: true)), 'List<String>');
    });

    test('bool[] decodes with a scalar helper, not as a message list', () {
      expect(DartEmitter.decodeExpr(f('bool', array: true)),
          contains('asBoolList'));
      expect(DartEmitter.decodeExpr(f('bool', array: true)),
          isNot(contains('fromJson')));
    });

    test('message lists get an explicit type argument', () {
      final expr = DartEmitter.decodeExpr(f('geometry_msgs/Pose', array: true));
      expect(expr, contains('Field.asList<Pose>'));
    });

    test('scalar lists encode as themselves', () {
      expect(DartEmitter.encodeExpr(f('bool', array: true)), 'v');
      expect(DartEmitter.encodeExpr(f('string', array: true)), 'v');
      expect(DartEmitter.encodeExpr(f('uint8', array: true)),
          contains('encodeBytes'));
    });
  });

  group('emitter: literals and defaults', () {
    test('honours a declared scalar default', () {
      // geometry_msgs/Quaternion declares `float64 w 1`; ignoring it makes a
      // default-built Quaternion (0,0,0,0) rather than the identity rotation.
      final msg = parse('float64 x\nfloat64 w 1');
      expect(DartEmitter.constDefaultFor(msg.fields[0]), '0');
      expect(DartEmitter.constDefaultFor(msg.fields[1]), '1.0');
    });

    test('honours a declared string default', () {
      final msg = parse('string relative_to "world"');
      expect(DartEmitter.constDefaultFor(msg.fields.single), "'world'");
    });

    test('honours an array default for non-typed-data lists', () {
      // Numeric arrays map to typed-data lists, which have no const form, so
      // they route through fallbackFor instead.
      final msg = parse('string[] names [a, b]');
      expect(
          DartEmitter.constDefaultFor(msg.fields.single), "const ['a', 'b']");
    });

    test('typed-array defaults become a fromList fallback', () {
      final msg = parse('float32[] gains [0.5, 1.5]');
      expect(DartEmitter.fallbackFor(msg.fields.single),
          'Float32List.fromList(const [0.5, 1.5])');
    });

    test('converts binary and octal literals, which Dart has no syntax for',
        () {
      // ublox_ubx_msgs uses `uint8 CALIB_STATUS_CALIBRATING = 0b01`.
      expect(DartEmitter.literal('0b01', 'int'), '1');
      expect(DartEmitter.literal('0b11', 'int'), '3');
      expect(DartEmitter.literal('-0b10', 'int'), '-2');
      expect(DartEmitter.literal('0o17', 'int'), '15');
      // Hex is valid Dart and must pass through untouched.
      expect(DartEmitter.literal('0xFF', 'int'), '0xFF');
    });

    test('appends .0 only when a double literal needs it', () {
      expect(DartEmitter.literal('5', 'double'), '5.0');
      expect(DartEmitter.literal('5.5', 'double'), '5.5');
      // Case-insensitive: `1E10.0` would not be a valid literal.
      expect(DartEmitter.literal('1e10', 'double'), '1e10');
      expect(DartEmitter.literal('1E10', 'double'), '1E10');
    });

    test('renames message types that shadow dart:core', () {
      // zed_msgs/msg/Object as `class Object` shadows dart:core.Object for the
      // whole library and breaks every Map<String, Object?> in it.
      expect(DartEmitter.className('zed_msgs/Object'), 'RosObject');
      expect(DartEmitter.className('pkg/List'), 'RosList');
      expect(DartEmitter.className('pkg/Marker'), 'Marker');
    });
  });

  group('writer: services and actions', () {
    String emitService(String source, {String name = 'AddTwoInts'}) =>
        LibraryWriter(
          package: 'example_interfaces',
          messages: const [],
          services: [
            InterfaceParser.parseService(source,
                package: 'example_interfaces', name: name),
          ],
        ).write();

    test('emits request and response classes plus a ServiceCodec', () {
      final code = emitService('int64 a\nint64 b\n---\nint64 sum\n');
      expect(code, contains('final class AddTwoIntsRequest'));
      expect(code, contains('final class AddTwoIntsResponse'));
      expect(code, contains('ServiceRegistry.register'));
      expect(code,
          contains('ServiceCodec<AddTwoIntsRequest, AddTwoIntsResponse>'));
      expect(
          code, contains("serviceType: 'example_interfaces/srv/AddTwoInts'"));
    });

    test('drops the underscore from synthesised part names', () {
      // The parser names parts `AddTwoInts_Request`; `AddTwoInts_Request` is
      // not idiomatic Dart.
      expect(DartEmitter.className('pkg/srv/AddTwoInts_Request'),
          'AddTwoIntsRequest');
      expect(DartEmitter.className('pkg/action/Fibonacci_Feedback'),
          'FibonacciFeedback');
    });

    test('emits goal, result and feedback classes plus an ActionCodec', () {
      final code = LibraryWriter(
        package: 'turtlesim',
        messages: const [],
        actions: [
          InterfaceParser.parseAction(
            'float32 theta\n---\nfloat32 delta\n---\nfloat32 remaining\n',
            package: 'turtlesim',
            name: 'RotateAbsolute',
          ),
        ],
      ).write();

      expect(code, contains('final class RotateAbsoluteGoal'));
      expect(code, contains('final class RotateAbsoluteResult'));
      expect(code, contains('final class RotateAbsoluteFeedback'));
      // Order matters: ActionCodec is <Goal, Feedback, Result>.
      expect(
          code,
          contains('ActionCodec<RotateAbsoluteGoal, RotateAbsoluteFeedback, '
              'RotateAbsoluteResult>'));
      expect(code, contains("actionType: 'turtlesim/action/RotateAbsolute'"));
    });

    test('service parts contribute to dependency analysis', () {
      final writer = LibraryWriter(
        package: 'nav_msgs',
        messages: const [],
        services: [
          InterfaceParser.parseService(
            'string map_url\n---\nnav_msgs/OccupancyGrid map\n'
            'builtin_interfaces/Time stamp\n',
            package: 'nav_msgs',
            name: 'LoadMap',
          ),
        ],
      );
      expect(writer.referencedPackages, contains('builtin_interfaces'));
    });
  });

  group('writer: generated source', () {
    String emit(String source, {String pkg = 'test_msgs', String name = 'T'}) =>
        LibraryWriter(
          package: pkg,
          messages: [parse(source, pkg: pkg, name: name)],
        ).write();

    test('a message with no fields gets a bare constructor', () {
      // `const Empty({})` is a syntax error.
      final code = emit('', name: 'Empty');
      expect(code, contains('const Empty();'));
      expect(code, isNot(contains('const Empty({')));
    });

    test('typed-data fields use a nullable param and ?? fallback', () {
      final code = emit('float32[] ranges');
      expect(code, contains('Float32List? ranges'));
      expect(code, contains('ranges = ranges ?? Float32List(0)'));
      // Cannot be const once an initialiser is involved.
      expect(code, isNot(contains('const T({')));
    });

    test('scalar-only messages keep a const constructor', () {
      final code = emit('float64 x\nfloat64 y');
      expect(code, contains('const T({'));
      expect(code, contains('this.x = 0'));
    });

    test('imports only the codegen support surface', () {
      // Importing the full barrel would make generated messages ambiguous
      // with the bundled ones.
      final code = emit('float64 x');
      expect(
          code, contains("import 'package:ros2_client/codegen_support.dart'"));
      expect(code,
          isNot(contains("import 'package:ros2_client/ros2_client.dart'")));
    });

    test('only imports dart:typed_data when it is used', () {
      expect(emit('float64 x'), isNot(contains("import 'dart:typed_data'")));
      expect(emit('float32[] r'), contains("import 'dart:typed_data'"));
    });

    test('reports cross-package references for transitive generation', () {
      final writer = LibraryWriter(
        package: 'visualization_msgs',
        messages: [
          parse('std_msgs/Header header\nbuiltin_interfaces/Duration lifetime',
              pkg: 'visualization_msgs', name: 'Marker'),
        ],
      );
      expect(writer.referencedPackages,
          containsAll(['std_msgs', 'builtin_interfaces']));
    });

    test('escapes angle brackets in doc comments', () {
      // ROS comments contain things like `value <= 100`, which markdown reads
      // as an HTML tag.
      final code = emit('int32 x  # must be <= 100 and > 0');
      expect(code, contains('&lt;= 100'));
      expect(code, contains('&gt; 0'));
    });

    test('disambiguates two constants that mangle to one identifier', () {
      final code = emit('int32 FOO_BAR=1\nint32 FOO__BAR=2');
      expect(code, contains('fooBar = 1'));
      expect(code, contains('fooBarConst = 2'));
    });

    test('emits registration and equality helpers', () {
      final code = emit('float64[] ranges');
      expect(code, contains('void registerTestMsgs()'));
      expect(code, contains('MessageRegistry.register'));
      expect(code, contains('bool _listEquals'));
    });
  });
}
