/// Collects `rosapi` typedefs into per-package sets of definitions.
///
/// Pure: it takes decoded typedef maps and produces the same definitions the
/// `.msg` parser does, so the network half of online generation stays in the
/// CLI and this half stays testable.
library;

import 'interface_def.dart';
import 'typedef_parser.dart';

/// Accumulates definitions harvested from a live robot.
final class TypedefHarvest {
  /// Messages by package, keyed by ROS type so a nested type pulled in by
  /// several roots is only emitted once.
  final Map<String, Map<String, MessageDef>> _messages = {};
  final Map<String, List<ServiceDef>> _services = {};
  final Map<String, List<ActionDef>> _actions = {};
  final List<String> _problems = [];

  /// Types that failed to parse, with the reason.
  List<String> get problems => List.unmodifiable(_problems);

  /// Every package that has at least one definition.
  List<String> get packages =>
      {..._messages.keys, ..._services.keys, ..._actions.keys}.toList()..sort();

  List<MessageDef> messagesFor(String package) =>
      (_messages[package]?.values.toList() ?? [])
        ..sort((a, b) => a.name.compareTo(b.name));

  List<ServiceDef> servicesFor(String package) =>
      List.unmodifiable(_services[package] ?? const []);

  List<ActionDef> actionsFor(String package) =>
      List.unmodifiable(_actions[package] ?? const []);

  int get messageCount =>
      _messages.values.fold(0, (sum, byType) => sum + byType.length);

  /// Adds a message and every type it contains.
  ///
  /// `rosapi` resolves recursively, so [typedefs] is the whole closure with
  /// the requested type first.
  void addMessages(Iterable<Map<String, Object?>> typedefs) {
    for (final typedef in typedefs) {
      _tryAdd(typedef);
    }
  }

  /// Adds a service from its request and response closures.
  ///
  /// [rosType] is the full `package/srv/Name`. The first entry of each list is
  /// the request or response itself; the rest are ordinary nested messages,
  /// which are collected alongside so the generated code compiles.
  void addService(
    String rosType,
    List<Map<String, Object?>> request,
    List<Map<String, Object?>> response,
  ) {
    final (package, name) = _splitInterface(rosType, 'srv');
    if (package == null) return;

    final requestDef = _head(request, rosType, 'request');
    final responseDef = _head(response, rosType, 'response');
    // Nested types still have to be emitted even if the head failed.
    addMessages(request.skip(1));
    addMessages(response.skip(1));
    if (requestDef == null || responseDef == null) return;

    _services.putIfAbsent(package, () => []).add(ServiceDef(
          package: package,
          name: name,
          request: requestDef,
          response: responseDef,
        ));
  }

  /// Adds an action from its goal, result and feedback closures.
  void addAction(
    String rosType,
    List<Map<String, Object?>> goal,
    List<Map<String, Object?>> result,
    List<Map<String, Object?>> feedback,
  ) {
    final (package, name) = _splitInterface(rosType, 'action');
    if (package == null) return;

    final goalDef = _head(goal, rosType, 'goal');
    final resultDef = _head(result, rosType, 'result');
    final feedbackDef = _head(feedback, rosType, 'feedback');
    addMessages(goal.skip(1));
    addMessages(result.skip(1));
    addMessages(feedback.skip(1));
    if (goalDef == null || resultDef == null || feedbackDef == null) return;

    _actions.putIfAbsent(package, () => []).add(ActionDef(
          package: package,
          name: name,
          goal: goalDef,
          result: resultDef,
          feedback: feedbackDef,
        ));
  }

  /// Parses the first typedef of a closure, recording a problem if it fails.
  MessageDef? _head(
      List<Map<String, Object?>> typedefs, String rosType, String part) {
    if (typedefs.isEmpty) {
      _problems.add('$rosType: rosapi returned no $part definition');
      return null;
    }
    try {
      return TypedefParser.toMessage(RosTypeDef.fromJson(typedefs.first));
    } on TypedefException catch (e) {
      _problems.add('$rosType ($part): ${e.message}');
      return null;
    }
  }

  void _tryAdd(Map<String, Object?> typedef) {
    final parsed = RosTypeDef.fromJson(typedef);
    try {
      final message = TypedefParser.toMessage(parsed);
      _messages
          .putIfAbsent(message.package, () => {})
          .putIfAbsent(message.name, () => message);
    } on TypedefException catch (e) {
      _problems.add('${parsed.type}: ${e.message}');
    }
  }

  /// Splits `package/srv/Name` or `package/action/Name`.
  ///
  /// The middle segment is optional: `rosapi/interfaces` reports the three-part
  /// form, but a user naming a type by hand may leave it out.
  (String?, String) _splitInterface(String rosType, String kind) {
    final parts = rosType.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) {
      _problems.add('$rosType: expected "package/$kind/Name"');
      return (null, '');
    }
    return (parts.first, parts.last);
  }
}
