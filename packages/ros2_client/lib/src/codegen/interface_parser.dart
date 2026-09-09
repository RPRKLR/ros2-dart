import 'interface_def.dart';

/// Thrown when an interface definition cannot be parsed.
final class InterfaceParseException implements Exception {
  InterfaceParseException(this.source, this.line, this.message);
  final String source;
  final int line;
  final String message;

  @override
  String toString() => 'InterfaceParseException($source:$line): $message';
}

/// Parses ROS 2 `.msg`, `.srv` and `.action` definitions.
///
/// Follows the IDL rules in the ROS 2 interface definition docs: primitives,
/// bounded/fixed/unbounded arrays, bounded strings, constants, and defaults.
abstract final class InterfaceParser {
  static const Set<String> primitives = {
    'bool',
    'byte',
    'char',
    'float32',
    'float64',
    'int8',
    'uint8',
    'int16',
    'uint16',
    'int32',
    'uint32',
    'int64',
    'uint64',
    'string',
    'wstring',
  };

  /// Parses a `.msg` body.
  static MessageDef parseMessage(
    String source, {
    required String package,
    required String name,
  }) {
    final lines = source.split('\n');
    final fields = <FieldDef>[];
    final constants = <ConstantDef>[];
    final docLines = <String>[];
    var stillLeadingComments = true;

    for (var i = 0; i < lines.length; i++) {
      final raw = lines[i];
      final trimmed = raw.trim();

      if (trimmed.isEmpty) {
        stillLeadingComments = stillLeadingComments && docLines.isEmpty;
        continue;
      }

      if (trimmed.startsWith('#')) {
        if (stillLeadingComments) {
          docLines.add(trimmed.substring(1).trim());
        }
        continue;
      }
      stillLeadingComments = false;

      final (content, comment) = _splitComment(trimmed);
      if (content.isEmpty) continue;

      try {
        if (_isConstant(content)) {
          constants.add(_parseConstant(content, comment));
        } else {
          fields.add(_parseField(content, comment));
        }
      } on FormatException catch (e) {
        throw InterfaceParseException('$package/$name', i + 1, e.message);
      }
    }

    return MessageDef(
      package: package,
      name: name,
      fields: fields,
      constants: constants,
      docComment: docLines.isEmpty ? null : docLines.join('\n'),
    );
  }

  /// Parses a `.srv` body, split on a `---` line.
  static ServiceDef parseService(
    String source, {
    required String package,
    required String name,
  }) {
    final parts = _splitSections(source);
    if (parts.length != 2) {
      throw InterfaceParseException('$package/$name', 0,
          'A .srv needs exactly one `---` separator, found ${parts.length - 1}');
    }
    return ServiceDef(
      package: package,
      name: name,
      request:
          parseMessage(parts[0], package: package, name: '${name}_Request'),
      response:
          parseMessage(parts[1], package: package, name: '${name}_Response'),
    );
  }

  /// Parses an `.action` body, split on two `---` lines.
  static ActionDef parseAction(
    String source, {
    required String package,
    required String name,
  }) {
    final parts = _splitSections(source);
    if (parts.length != 3) {
      throw InterfaceParseException('$package/$name', 0,
          'An .action needs exactly two `---` separators, found ${parts.length - 1}');
    }
    return ActionDef(
      package: package,
      name: name,
      goal: parseMessage(parts[0], package: package, name: '${name}_Goal'),
      result: parseMessage(parts[1], package: package, name: '${name}_Result'),
      feedback:
          parseMessage(parts[2], package: package, name: '${name}_Feedback'),
    );
  }

  static List<String> _splitSections(String source) {
    final sections = <String>[];
    final current = <String>[];
    for (final line in source.split('\n')) {
      if (line.trimRight() == '---') {
        sections.add(current.join('\n'));
        current.clear();
      } else {
        current.add(line);
      }
    }
    sections.add(current.join('\n'));
    return sections;
  }

  /// Splits a line into content and trailing comment, respecting quotes.
  ///
  /// A `#` inside a string default (`string greeting "a # b"`) is not a
  /// comment, so quote state has to be tracked rather than using indexOf.
  static (String, String?) _splitComment(String line) {
    var inSingle = false;
    var inDouble = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == r'\' && i + 1 < line.length) {
        i++;
        continue;
      }
      if (c == "'" && !inDouble) inSingle = !inSingle;
      if (c == '"' && !inSingle) inDouble = !inDouble;
      if (c == '#' && !inSingle && !inDouble) {
        final comment = line.substring(i + 1).trim();
        return (line.substring(0, i).trim(), comment.isEmpty ? null : comment);
      }
    }
    return (line.trim(), null);
  }

  /// A constant is `TYPE NAME=value`; the `=` must come before any whitespace
  /// that would start a default value.
  static bool _isConstant(String content) {
    final eq = content.indexOf('=');
    if (eq < 0) return false;
    // `string<=5 name` is a bounded string, not a constant.
    if (eq > 0 && content[eq - 1] == '<') return false;
    // Everything before `=` must be exactly `type name`, with no third token.
    final head = content.substring(0, eq).trim();
    return head.split(RegExp(r'\s+')).length == 2;
  }

  static ConstantDef _parseConstant(String content, String? comment) {
    final eq = content.indexOf('=');
    final head = content.substring(0, eq).trim();
    final value = content.substring(eq + 1).trim();
    final parts = head.split(RegExp(r'\s+'));
    return ConstantDef(
      type: parts[0],
      name: parts[1],
      value: value,
      comment: comment,
    );
  }

  static FieldDef _parseField(String content, String? comment) {
    final parts = content.split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw FormatException('Expected "<type> <name>", got "$content"');
    }

    var typeToken = parts[0];
    final name = parts[1];
    final defaultValue =
        parts.length > 2 ? parts.sublist(2).join(' ').trim() : null;

    // Bounded string: string<=10 or string<=10[]
    int? stringBound;
    final boundMatch = RegExp(r'^(w?string)<=(\d+)').firstMatch(typeToken);
    if (boundMatch != null) {
      stringBound = int.parse(boundMatch.group(2)!);
      typeToken = boundMatch.group(1)! + typeToken.substring(boundMatch.end);
    }

    var arrayKind = ArrayKind.none;
    int? arraySize;
    final arrayMatch = RegExp(r'\[(.*)\]$').firstMatch(typeToken);
    if (arrayMatch != null) {
      final inner = arrayMatch.group(1)!.trim();
      typeToken = typeToken.substring(0, arrayMatch.start);
      if (inner.isEmpty) {
        arrayKind = ArrayKind.unbounded;
      } else if (inner.startsWith('<=')) {
        arrayKind = ArrayKind.bounded;
        arraySize = int.tryParse(inner.substring(2));
      } else {
        arrayKind = ArrayKind.fixed;
        arraySize = int.tryParse(inner);
      }
    }

    return FieldDef(
      type: typeToken,
      name: name,
      arrayKind: arrayKind,
      arraySize: arraySize,
      defaultValue: defaultValue,
      stringBound: stringBound,
      comment: comment,
    );
  }
}
