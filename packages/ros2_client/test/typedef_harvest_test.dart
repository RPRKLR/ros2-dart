import 'package:ros2_client/src/codegen/typedef_harvest.dart';
import 'package:test/test.dart';

Map<String, Object?> typedef_(
  String type, {
  List<String> fields = const [],
  List<String> types = const [],
  List<int> arrays = const [],
}) =>
    {
      'type': type,
      'fieldnames': fields,
      'fieldtypes': types,
      'fieldarraylen': arrays.isEmpty ? List.filled(fields.length, -1) : arrays,
      'constnames': <String>[],
      'constvalues': <String>[],
    };

/// A `sensor_msgs/LaserScan` closure as rosapi returns it: the root first,
/// then every nested type, across package boundaries.
final laserScanClosure = [
  typedef_('sensor_msgs/LaserScan',
      fields: ['header', 'ranges'],
      types: ['std_msgs/Header', 'float'],
      arrays: [-1, 0]),
  typedef_('std_msgs/Header',
      fields: ['stamp', 'frame_id'],
      types: ['builtin_interfaces/Time', 'string']),
  typedef_('builtin_interfaces/Time',
      fields: ['sec', 'nanosec'], types: ['int32', 'uint32']),
];

void main() {
  test('groups a closure by package', () {
    final harvest = TypedefHarvest()..addMessages(laserScanClosure);

    expect(harvest.packages,
        ['builtin_interfaces', 'sensor_msgs', 'std_msgs']);
    expect(harvest.messagesFor('sensor_msgs').single.name, 'LaserScan');
    expect(harvest.messagesFor('std_msgs').single.name, 'Header');
    expect(harvest.messageCount, 3);
    expect(harvest.problems, isEmpty);
  });

  test('emits a shared nested type once across several roots', () {
    final harvest = TypedefHarvest()
      ..addMessages(laserScanClosure)
      ..addMessages([
        typedef_('nav_msgs/Odometry',
            fields: ['header'], types: ['std_msgs/Header']),
        // Every closure repeats Header; emitting it twice would produce a
        // library that does not compile.
        typedef_('std_msgs/Header',
            fields: ['stamp', 'frame_id'],
            types: ['builtin_interfaces/Time', 'string']),
      ]);

    expect(harvest.messagesFor('std_msgs'), hasLength(1));
    expect(harvest.messageCount, 4);
  });

  test('builds a service from its request and response closures', () {
    final harvest = TypedefHarvest()
      ..addService(
        'example_interfaces/srv/AddTwoInts',
        [
          typedef_('example_interfaces/AddTwoInts_Request',
              fields: ['a', 'b'], types: ['int64', 'int64'])
        ],
        [
          typedef_('example_interfaces/AddTwoInts_Response',
              fields: ['sum'], types: ['int64'])
        ],
      );

    final service = harvest.servicesFor('example_interfaces').single;
    expect(service.name, 'AddTwoInts');
    expect(service.rosType, 'example_interfaces/srv/AddTwoInts');
    // The naming has to match the offline parser's, or the two paths generate
    // different class names for the same service.
    expect(service.request.name, 'AddTwoInts_Request');
    expect(service.response.name, 'AddTwoInts_Response');
    expect(harvest.problems, isEmpty);
  });

  test('builds an action and keeps the types nested inside it', () {
    final harvest = TypedefHarvest()
      ..addAction(
        'nav2_msgs/action/NavigateToPose',
        [
          typedef_('nav2_msgs/NavigateToPose_Goal',
              fields: ['pose'], types: ['geometry_msgs/PoseStamped']),
          typedef_('geometry_msgs/PoseStamped',
              fields: ['header'], types: ['std_msgs/Header']),
        ],
        [typedef_('nav2_msgs/NavigateToPose_Result')],
        [
          typedef_('nav2_msgs/NavigateToPose_Feedback',
              fields: ['distance_remaining'], types: ['float'])
        ],
      );

    final action = harvest.actionsFor('nav2_msgs').single;
    expect(action.name, 'NavigateToPose');
    expect(action.goal.name, 'NavigateToPose_Goal');
    expect(action.feedback.fields.single.type, 'float32');

    // The goal's nested PoseStamped belongs to geometry_msgs and has to be
    // emitted there, or nav2_msgs.dart imports a class nobody generated.
    expect(harvest.messagesFor('geometry_msgs').single.name, 'PoseStamped');
  });

  test('records a bad type as a problem and keeps the rest', () {
    final harvest = TypedefHarvest()
      ..addMessages([
        typedef_('sensor_msgs/Imu', fields: ['x'], types: ['double']),
        // rosapi leaks the bound into the type name for sequence<double, 3>.
        typedef_('shape_msgs/SolidPrimitive',
            fields: ['dimensions'], types: ['double, 3'], arrays: [0]),
      ]);

    expect(harvest.messagesFor('sensor_msgs'), hasLength(1));
    expect(harvest.problems.single, contains('shape_msgs/SolidPrimitive'));
    expect(harvest.packages, isNot(contains('shape_msgs')));
  });

  test('still emits nested types when a service head fails', () {
    final harvest = TypedefHarvest()
      ..addService(
        'my_msgs/srv/Bad',
        [
          typedef_('my_msgs/Bad_Request',
              fields: ['name'], types: ['string<256>']),
          typedef_('std_msgs/Header', fields: ['frame_id'], types: ['string']),
        ],
        [typedef_('my_msgs/Bad_Response')],
      );

    expect(harvest.servicesFor('my_msgs'), isEmpty);
    expect(harvest.problems.single, contains('request'));
    expect(harvest.messagesFor('std_msgs'), hasLength(1));
  });

  test('reports an empty closure rather than emitting a broken service', () {
    final harvest = TypedefHarvest()
      ..addService('my_msgs/srv/Missing', const [], const []);

    expect(harvest.servicesFor('my_msgs'), isEmpty);
    expect(harvest.problems, hasLength(2));
    expect(harvest.problems.first, contains('no request definition'));
  });
}
