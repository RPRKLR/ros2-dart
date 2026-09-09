import 'dart:convert';

import 'package:meta/meta.dart';

import '../client.dart';

/// A topic name paired with its ROS type.
@immutable
final class TopicInfo {
  const TopicInfo(this.name, this.type);
  final String name;
  final String type;

  @override
  bool operator ==(Object other) =>
      other is TopicInfo && other.name == name && other.type == type;
  @override
  int get hashCode => Object.hash(name, type);
  @override
  String toString() => '$name [$type]';
}

/// What a node publishes, subscribes to and serves.
@immutable
final class NodeInfo {
  const NodeInfo({
    required this.name,
    required this.publishing,
    required this.subscribing,
    required this.services,
  });

  final String name;
  final List<String> publishing;
  final List<String> subscribing;
  final List<String> services;

  @override
  String toString() => 'NodeInfo($name, ${publishing.length} pub, '
      '${subscribing.length} sub, ${services.length} srv)';
}

/// Live introspection of the ROS graph, via the `rosapi` node.
///
/// Every method here needs `rosapi` running — it ships with `rosbridge_suite`
/// and is started by `rosbridge_websocket_launch.xml`, so it is normally
/// present whenever rosbridge is.
///
/// Graph-wide queries are slow. `rosapi` fans out a service call to every node
/// and waits for all of them, so [listParams] in particular has been measured
/// at over 20 seconds on an idle graph — that is `rosapi`, not this client;
/// the same delay appears when calling it from `ros2 service call`. The
/// defaults here are set accordingly, and every method takes a [timeout].
extension Ros2Introspection on Ros2Client {
  /// Default timeout for graph-wide queries that fan out across every node.
  static const Duration graphQueryTimeout = Duration(seconds: 45);

  /// All advertised topics with their types.
  Future<List<TopicInfo>> listTopics(
      {Duration timeout = graphQueryTimeout}) async {
    final res =
        await callServiceJson('/rosapi/topics', const {}, timeout: timeout);
    final names = _strings(res['topics']);
    final types = _strings(res['types']);
    return [
      for (var i = 0; i < names.length; i++)
        TopicInfo(names[i], i < types.length ? types[i] : ''),
    ];
  }

  /// The ROS type of a single topic, or `null` if it is not advertised.
  Future<String?> topicType(String topic,
      {Duration timeout = graphQueryTimeout}) async {
    final res = await callServiceJson('/rosapi/topic_type', {'topic': topic},
        timeout: timeout);
    final type = res['type'];
    return (type is String && type.isNotEmpty) ? type : null;
  }

  /// Topics carrying [type], e.g. `sensor_msgs/msg/Image`.
  Future<List<String>> topicsForType(String type,
      {Duration timeout = graphQueryTimeout}) async {
    final res = await callServiceJson('/rosapi/topics_for_type', {'type': type},
        timeout: timeout);
    return _strings(res['topics']);
  }

  /// All node names in the graph.
  Future<List<String>> listNodes({Duration timeout = graphQueryTimeout}) async {
    final res =
        await callServiceJson('/rosapi/nodes', const {}, timeout: timeout);
    return _strings(res['nodes']);
  }

  /// Details for one node.
  Future<NodeInfo> nodeDetails(String node,
      {Duration timeout = graphQueryTimeout}) async {
    final res = await callServiceJson('/rosapi/node_details', {'node': node},
        timeout: timeout);
    return NodeInfo(
      name: node,
      publishing: _strings(res['publishing']),
      subscribing: _strings(res['subscribing']),
      services: _strings(res['services']),
    );
  }

  /// All advertised service names.
  Future<List<String>> listServices(
      {Duration timeout = graphQueryTimeout}) async {
    final res =
        await callServiceJson('/rosapi/services', const {}, timeout: timeout);
    return _strings(res['services']);
  }

  /// The type of a service, or `null` if unavailable.
  Future<String?> serviceType(String service,
      {Duration timeout = graphQueryTimeout}) async {
    final res = await callServiceJson(
        '/rosapi/service_type', {'service': service},
        timeout: timeout);
    final type = res['type'];
    return (type is String && type.isNotEmpty) ? type : null;
  }

  /// All action servers in the graph.
  ///
  /// Requires `rosbridge_suite` >= 2.0.0.
  Future<List<String>> listActionServers(
      {Duration timeout = graphQueryTimeout}) async {
    final res = await callServiceJson('/rosapi/action_servers', const {},
        timeout: timeout);
    return _strings(res['action_servers']);
  }

  /// The raw `.msg` text for [type] and everything it depends on.
  ///
  /// This is what makes runtime code generation possible: point the generator
  /// at a live robot and it can emit Dart classes for types it has never seen.
  Future<List<String>> messageDefinition(String type) async {
    final res =
        await callServiceJson('/rosapi/message_details', {'type': type});
    final defs = res['typedefs'];
    return defs is List ? defs.map((d) => jsonEncode(d)).toList() : const [];
  }

  /// ROS distro reported by the robot, e.g. `humble`.
  Future<String> rosDistro() async {
    final res = await callServiceJson('/rosapi/get_ros_version', const {});
    return '${res['distro'] ?? ''}';
  }

  // ------------------------------------------------------------- parameters

  /// Every known parameter, as `<node>:<param>`.
  ///
  /// Two caveats, both properties of `rosapi` rather than this client:
  ///
  ///  * it is **slow** — measured at 20+ seconds on an idle graph, because
  ///    `rosapi` queries every node and waits for all of them;
  ///  * it returns an empty list unless the bridge was launched with a
  ///    `params_glob`, which defaults to empty and blocks enumeration:
  ///    `ros2 launch rosbridge_server rosbridge_websocket_launch.xml
  ///    params_glob:="[*]"`.
  ///
  /// [getParam] and [setParam] need neither — they respond in milliseconds and
  /// work without a glob, so prefer them when you already know the name.
  Future<List<String>> listParams(
      {Duration timeout = graphQueryTimeout}) async {
    final res = await callServiceJson('/rosapi/get_param_names', const {},
        timeout: timeout);
    return _strings(res['names']);
  }

  /// Reads a parameter.
  ///
  /// ROS 2 parameters belong to a node, so [name] must be `<node>:<param>`,
  /// for example `/turtlesim:background_r`. Values come back JSON-encoded and
  /// are decoded here, so you get an `int`, `String`, `List`, etc.
  Future<Object?> getParam(String name,
      {Object? defaultValue,
      Duration timeout = const Duration(seconds: 10)}) async {
    _assertQualified(name, 'getParam');
    final res = await callServiceJson(
        '/rosapi/get_param',
        {
          'name': name,
          'default_value': defaultValue == null ? '' : jsonEncode(defaultValue),
        },
        timeout: timeout);
    if (res['successful'] == false) return defaultValue;
    return _decodeParam(res['value'], defaultValue);
  }

  /// Writes a parameter. [name] must be `<node>:<param>`.
  ///
  /// Returns `false` (with the reason on the [Ros2Client.status] stream) if the
  /// node rejected the write — read-only parameters are common.
  Future<bool> setParam(String name, Object? value,
      {Duration timeout = const Duration(seconds: 10)}) async {
    _assertQualified(name, 'setParam');
    final res = await callServiceJson(
        '/rosapi/set_param',
        {
          'name': name,
          'value': jsonEncode(value),
        },
        timeout: timeout);
    // rosbridge 2.0.x omits `successful` on success, so only an explicit
    // false counts as a rejection.
    return res['successful'] != false;
  }

  /// Whether a parameter exists. [name] must be `<node>:<param>`.
  Future<bool> hasParam(String name,
      {Duration timeout = const Duration(seconds: 10)}) async {
    _assertQualified(name, 'hasParam');
    final res = await callServiceJson('/rosapi/has_param', {'name': name},
        timeout: timeout);
    return res['exists'] == true;
  }

  void _assertQualified(String name, String method) {
    if (!name.contains(':')) {
      throw ArgumentError.value(
        name,
        'name',
        'ROS 2 parameters are node-scoped. $method expects "<node>:<param>", '
            'e.g. "/turtlesim:background_r". Use listParams() to discover '
            'valid names.',
      );
    }
  }

  static Object? _decodeParam(Object? raw, Object? fallback) {
    if (raw is! String || raw.isEmpty) return fallback;
    try {
      return jsonDecode(raw);
    } on FormatException {
      // rosapi returns bare strings unquoted for some parameter types.
      return raw;
    }
  }

  static List<String> _strings(Object? value) =>
      value is List ? value.map((e) => '$e').toList(growable: false) : const [];
}
