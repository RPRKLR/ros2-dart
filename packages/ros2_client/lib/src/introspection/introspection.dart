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

  /// Every interface type the robot knows about, e.g. `sensor_msgs/msg/Image`.
  Future<List<String>> listInterfaces(
      {Duration timeout = graphQueryTimeout}) async {
    final res = await callServiceJson('/rosapi/interfaces', const {},
        timeout: timeout);
    return _strings(res['interfaces']);
  }

  /// Structured definitions of [type] and every type it contains.
  ///
  /// This is what makes generating from a live robot possible: no ROS install
  /// and no source tree, just a WebSocket. `rosapi` resolves nested types
  /// recursively, so one call returns the whole dependency closure.
  ///
  /// The result is raw `rosapi_msgs/msg/TypeDef` maps; `TypedefParser` in the
  /// codegen library turns them into the same definitions the `.msg` parser
  /// produces.
  ///
  /// **`rosapi` cannot describe a type with a bounded array or bounded
  /// string.** `sequence<T, N>` and `string<N>` both make it raise an
  /// `AssertionError` internally, which arrives here as a failed service call.
  /// Generate those packages from source instead. Verified against rosapi
  /// 2.0.7 on Humble with `shape_msgs/SolidPrimitive`.
  Future<List<Map<String, Object?>>> messageTypedefs(String type,
          {Duration timeout = graphQueryTimeout}) =>
      _typedefs('/rosapi/message_details', type, timeout);

  /// Structured definitions of a service's request message.
  Future<List<Map<String, Object?>>> serviceRequestTypedefs(String type,
          {Duration timeout = graphQueryTimeout}) =>
      _typedefs('/rosapi/service_request_details', type, timeout);

  /// Structured definitions of a service's response message.
  Future<List<Map<String, Object?>>> serviceResponseTypedefs(String type,
          {Duration timeout = graphQueryTimeout}) =>
      _typedefs('/rosapi/service_response_details', type, timeout);

  /// Structured definitions of an action's goal message.
  Future<List<Map<String, Object?>>> actionGoalTypedefs(String type,
          {Duration timeout = graphQueryTimeout}) =>
      _typedefs('/rosapi/action_goal_details', type, timeout);

  /// Structured definitions of an action's result message.
  Future<List<Map<String, Object?>>> actionResultTypedefs(String type,
          {Duration timeout = graphQueryTimeout}) =>
      _typedefs('/rosapi/action_result_details', type, timeout);

  /// Structured definitions of an action's feedback message.
  Future<List<Map<String, Object?>>> actionFeedbackTypedefs(String type,
          {Duration timeout = graphQueryTimeout}) =>
      _typedefs('/rosapi/action_feedback_details', type, timeout);

  Future<List<Map<String, Object?>>> _typedefs(
      String service, String type, Duration timeout) async {
    final res =
        await callServiceJson(service, {'type': type}, timeout: timeout);
    final defs = res['typedefs'];
    if (defs is! List) return const [];
    return [
      for (final def in defs)
        if (def is Map) def.cast<String, Object?>(),
    ];
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
  /// Returns whether the value actually took effect, by reading it back.
  ///
  /// **`rosapi/set_param` cannot report failure.** Its `.srv` response section
  /// is empty — there is no `successful` field — and `rosapi_node` swallows
  /// every error: a `ValueError` is caught and logged, a name blocked by
  /// `params_glob` returns early, and `call_set_parameters` runs inside
  /// `contextlib.suppress(Exception)` without inspecting the result. So the
  /// service answers identically whether the node exists, the parameter
  /// exists, the type matches, the value is in range, or none of the above.
  ///
  /// Reading the value back is the only way to know. Pass `verify: false` to
  /// skip it and get the old fire-and-forget behaviour, which always returns
  /// true — including when nothing happened.
  Future<bool> setParam(String name, Object? value,
      {bool verify = true,
      Duration timeout = const Duration(seconds: 10)}) async {
    _assertQualified(name, 'setParam');
    await callServiceJson(
        '/rosapi/set_param',
        {
          'name': name,
          'value': jsonEncode(value),
        },
        timeout: timeout);
    if (!verify) return true;

    // A sentinel default distinguishes "missing" from "equals what I set":
    // getParam returns the caller's default on any failure, so reusing `value`
    // as the default would report success for a parameter that does not exist.
    const missing = '\u0000ros2_client:absent';
    final readBack =
        await getParam(name, defaultValue: missing, timeout: timeout);
    if (readBack == missing) return false;
    return _paramEquals(readBack, value);
  }

  /// Compares a read-back parameter with what was written.
  ///
  /// Deliberately loose about numbers: a `1` written to a double parameter
  /// reads back as `1.0`, and that is a success, not a mismatch.
  static bool _paramEquals(Object? readBack, Object? written) {
    if (readBack is num && written is num) return readBack == written;
    if (readBack is List && written is List) {
      if (readBack.length != written.length) return false;
      for (var i = 0; i < readBack.length; i++) {
        if (!_paramEquals(readBack[i], written[i])) return false;
      }
      return true;
    }
    return readBack == written;
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
