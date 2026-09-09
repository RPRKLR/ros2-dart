import 'dart_emitter.dart';
import 'interface_def.dart';

/// Renders parsed interfaces into a Dart library.
final class LibraryWriter {
  LibraryWriter({
    required this.package,
    required this.messages,
    this.services = const [],
    this.actions = const [],
  });

  /// The ROS package these messages belong to, e.g. `sensor_msgs`.
  final String package;
  final List<MessageDef> messages;
  final List<ServiceDef> services;
  final List<ActionDef> actions;

  /// Every message body in this library, including the request/response and
  /// goal/result/feedback parts synthesised from services and actions.
  List<MessageDef> get _allMessages => [
        ...messages,
        for (final s in services) ...[s.request, s.response],
        for (final a in actions) ...[a.goal, a.result, a.feedback],
      ];

  /// Emits the complete `.dart` source for [package].
  String write() {
    final buffer = StringBuffer();
    _writeHeader(buffer);
    for (final message in _allMessages) {
      _writeMessage(buffer, message);
    }
    _writeRegistration(buffer);
    return buffer.toString();
  }

  void _writeHeader(StringBuffer out) {
    final deps = _externalPackages();
    out
      ..writeln('// GENERATED CODE - DO NOT EDIT BY HAND.')
      ..writeln('//')
      ..writeln('// Regenerate with:')
      ..writeln('//   dart run ros2_client:generate --package $package')
      ..writeln()
      ..writeln();
    if (_usesTypedData) {
      out
        ..writeln("import 'dart:typed_data';")
        ..writeln();
    }
    // The minimal surface, not the full barrel: importing ros2_client.dart
    // would make a generated `sensor_msgs/Image` ambiguous with the bundled
    // one wherever both are in scope.
    out.writeln("import 'package:ros2_client/codegen_support.dart';");
    for (final dep in deps) {
      out.writeln("import '$dep.dart';");
    }
    out.writeln();
  }

  /// True when any field maps to a `dart:typed_data` list.
  bool get _usesTypedData => _allMessages.any((m) => m.fields
      .any((f) => f.isArray && DartEmitter.typedListFor(f.type) != null));

  /// True when any field is a list, so `==` needs element-wise comparison.
  bool get _usesListEquals =>
      _allMessages.any((m) => m.fields.any((f) => f.isArray));

  /// Packages referenced by these messages, excluding this one and the types
  /// bundled with the client. Used by the CLI to pull in transitive deps.
  List<String> get referencedPackages => _externalPackages();

  /// Other generated libraries this one references.
  List<String> _externalPackages() {
    final deps = <String>{};
    for (final message in _allMessages) {
      for (final field in message.fields) {
        if (DartEmitter.scalarDartType(field.type) != null) continue;
        final parts = field.type.split('/');
        if (parts.length < 2) continue;
        if (parts.first != package) deps.add(parts.first);
      }
    }
    // std_msgs and builtin_interfaces used to be skipped here, on the
    // assumption that the client barrel supplied them. Generated code now
    // imports only codegen_support.dart, which exports no message classes, so
    // every referenced package must be imported and generated like any other.
    final sorted = deps.toList()..sort();
    return sorted;
  }

  void _writeMessage(StringBuffer out, MessageDef message) {
    final name = DartEmitter.className(message.name);
    final fields = message.fields;

    // A field needs a `??` initialiser when it has no const-safe default:
    // typed-data lists and nested messages.
    final needsInitialiser = {
      for (final f in fields) f.name: DartEmitter.constDefaultFor(f) == null,
    };
    final anyInitialiser = needsInitialiser.values.any((v) => v);

    if (message.docComment != null) {
      for (final line in message.docComment!.split('\n')) {
        out.writeln('/// ${line.trim()}');
      }
      out.writeln('///');
    }
    out
      ..writeln('/// `${message.package}/msg/${message.name}`')
      ..writeln('final class $name implements RosMessage {');

    // Constructor. An empty named-parameter group (`const Empty({})`) is a
    // syntax error, so a message with no fields gets a bare constructor.
    if (fields.isEmpty) {
      out.writeln('  const $name();');
    } else {
      out
        ..write(anyInitialiser ? '  $name({' : '  const $name({')
        ..writeln();
      for (final field in fields) {
        final dart = DartEmitter.fieldName(field.name);
        if (needsInitialiser[field.name]!) {
          out.writeln('    ${DartEmitter.dartTypeOf(field)}? $dart,');
        } else {
          out.writeln(
              '    this.$dart = ${DartEmitter.constDefaultFor(field)},');
        }
      }
      out.write('  })');
      final initialisers = fields
          .where((f) => needsInitialiser[f.name]!)
          .map((f) =>
              '${DartEmitter.fieldName(f.name)} = ${DartEmitter.fieldName(f.name)} ?? ${DartEmitter.fallbackFor(f)}')
          .toList();
      if (initialisers.isEmpty) {
        out.writeln(';');
      } else {
        out
          ..writeln(' : ')
          ..writeln('        ${initialisers.join(',\n        ')};');
      }
    }
    out.writeln();

    // fromJson.
    out.writeln(
        '  factory $name.fromJson(Map<String, Object?> json) => $name(');
    for (final field in fields) {
      out.writeln(
          '        ${DartEmitter.fieldName(field.name)}: ${DartEmitter.decodeExpr(field)},');
    }
    out
      ..writeln('      );')
      ..writeln();

    // Constants. Field names are reserved first: a constant that collapses to
    // the same Dart identifier as a field is renamed, not the other way round.
    final fieldNames = {
      for (final f in fields) DartEmitter.fieldName(f.name),
    };
    for (final constant in message.constants) {
      final dartType = DartEmitter.scalarDartType(constant.type) ?? 'Object';
      final value = _literal(constant.value, dartType);
      if (constant.comment != null) out.writeln('  /// ${constant.comment}');
      final name = DartEmitter.constantName(constant.name, taken: fieldNames);
      out.writeln('  static const $dartType $name = $value;');
    }
    if (message.constants.isNotEmpty) out.writeln();

    // Fields.
    for (final field in fields) {
      if (field.comment != null) out.writeln('  /// ${field.comment}');
      if (field.arrayKind == ArrayKind.fixed) {
        out.writeln('  /// Fixed length: ${field.arraySize}.');
      } else if (field.arrayKind == ArrayKind.bounded) {
        out.writeln('  /// At most ${field.arraySize} elements.');
      }
      out.writeln(
          '  final ${DartEmitter.dartTypeOf(field)} ${DartEmitter.fieldName(field.name)};');
    }
    out.writeln();

    // rosType + toJson.
    out
      ..writeln('  @override')
      ..writeln(
          "  String get rosType => '${message.package}/msg/${message.name}';")
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Map<String, Object?> toJson() => {');
    for (final field in fields) {
      out.writeln("        '${field.name}': ${DartEmitter.encodeExpr(field)},");
    }
    out
      ..writeln('      };')
      ..writeln();

    _writeEquality(out, name, fields);

    out
      ..writeln('}')
      ..writeln();
  }

  void _writeEquality(StringBuffer out, String name, List<FieldDef> fields) {
    // Typed-data and list fields need element-wise comparison; identity would
    // report two structurally identical messages as different.
    final needsDeep = fields.any((f) => f.isArray);
    out
      ..writeln('  @override')
      ..writeln('  bool operator ==(Object other) =>')
      ..writeln('      identical(this, other) ||');
    if (fields.isEmpty) {
      out.writeln('      other is $name;');
    } else {
      final comparisons = fields.map((f) {
        final n = DartEmitter.fieldName(f.name);
        return f.isArray ? '_listEquals(other.$n, $n)' : 'other.$n == $n';
      }).join(' &&\n          ');
      out
        ..writeln('      (other is $name &&')
        ..writeln('          $comparisons);');
    }
    out.writeln();

    out
      ..writeln('  @override')
      ..writeln('  int get hashCode => Object.hashAll([');
    for (final field in fields) {
      final n = DartEmitter.fieldName(field.name);
      out.writeln(field.isArray ? '        ...$n,' : '        $n,');
    }
    out
      ..writeln('      ]);')
      ..writeln();

    out
      ..writeln('  @override')
      ..writeln("  String toString() => '$name(\${toJson()})';");
    if (needsDeep) {
      // Emitted once per library, below.
    }
  }

  void _writeRegistration(StringBuffer out) {
    if (_usesListEquals) {
      out
        ..writeln('/// Element-wise list comparison used by generated `==`.')
        ..writeln('bool _listEquals(List<Object?> a, List<Object?> b) {')
        ..writeln('  if (identical(a, b)) return true;')
        ..writeln('  if (a.length != b.length) return false;')
        ..writeln('  for (var i = 0; i < a.length; i++) {')
        ..writeln('    if (a[i] != b[i]) return false;')
        ..writeln('  }')
        ..writeln('  return true;')
        ..writeln('}')
        ..writeln();
    }
    out
      ..writeln('/// Registers every message in `$package`.')
      ..writeln('///')
      ..writeln(
          '/// Call once at startup, before the first subscribe or advertise.')
      ..writeln('void register${_pascal(package)}() {');
    for (final message in _allMessages) {
      final name = DartEmitter.className(message.name);
      out
        ..writeln('  MessageRegistry.register(const MessageCodec<$name>(')
        ..writeln("    rosType: '${message.package}/msg/${message.name}',")
        ..writeln('    fromJson: $name.fromJson,')
        ..writeln('    toJson: _toJson,')
        ..writeln('  ));');
    }
    for (final service in services) {
      final req = DartEmitter.className(service.request.name);
      final res = DartEmitter.className(service.response.name);
      out
        ..writeln('  ServiceRegistry.register(')
        ..writeln('      const ServiceCodec<$req, $res>(')
        ..writeln("    serviceType: '${service.rosType}',")
        ..writeln('    encodeRequest: _toJson,')
        ..writeln('    decodeResponse: $res.fromJson,')
        ..writeln('    decodeRequest: $req.fromJson,')
        ..writeln('    encodeResponse: _toJson,')
        ..writeln('  ));');
    }
    for (final action in actions) {
      final goal = DartEmitter.className(action.goal.name);
      final result = DartEmitter.className(action.result.name);
      final feedback = DartEmitter.className(action.feedback.name);
      out
        ..writeln('  ActionRegistry.register(')
        ..writeln('      const ActionCodec<$goal, $feedback, $result>(')
        ..writeln("    actionType: '${action.rosType}',")
        ..writeln('    encodeGoal: _toJson,')
        ..writeln('    decodeFeedback: $feedback.fromJson,')
        ..writeln('    decodeResult: $result.fromJson,')
        ..writeln('  ));');
    }
    out
      ..writeln('}')
      ..writeln()
      ..writeln('Map<String, Object?> _toJson(RosMessage m) => m.toJson();');
  }

  static String _pascal(String snake) => snake
      .split('_')
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + p.substring(1))
      .join();

  /// Renders a constant's value as a Dart literal.
  static String _literal(String raw, String dartType) {
    final value = raw.trim();
    if (dartType == 'String') {
      if (value.startsWith('"') || value.startsWith("'")) return value;
      return "'${value.replaceAll(r'\', r'\\').replaceAll("'", r"\'")}'";
    }
    if (dartType == 'bool') {
      return (value == '1' || value.toLowerCase() == 'true') ? 'true' : 'false';
    }
    if (dartType == 'double' && !value.contains('.') && !value.contains('e')) {
      return '$value.0';
    }
    return value;
  }
}
