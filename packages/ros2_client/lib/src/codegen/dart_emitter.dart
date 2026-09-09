import 'interface_def.dart';

/// Generates Dart source from parsed ROS interface definitions.
abstract final class DartEmitter {
  /// Names exported by `package:flutter/material.dart`, which would force a
  /// `hide` clause on every user file if a message shadowed them.
  static const Map<String, String> reservedTypeNames = {
    'Image': 'RosImage',
    'Path': 'RosPath',
    'Transform': 'RosTransform',
    'TransformStamped': 'RosTransformStamped',
    'ConnectionState': 'RosConnectionState',
    'Duration': 'RosDuration',
    'Time': 'RosTime',
    'String': 'StringMsg',
    'Color': 'RosColor',
    'Text': 'RosText',
    'Table': 'RosTable',
    'Route': 'RosRoute',
  };

  /// `dart:core` names a message must never shadow.
  ///
  /// A `zed_msgs/msg/Object` generated as `class Object` shadows
  /// `dart:core.Object` for the whole library, and every `Map<String, Object?>`
  /// and `Object.hashAll` in the generated code then fails to resolve.
  static const Set<String> dartCoreTypeNames = {
    'Object',
    'List',
    'Map',
    'Set',
    'String',
    'int',
    'double',
    'num',
    'bool',
    'Type',
    'Function',
    'Symbol',
    'Iterable',
    'Iterator',
    'Future',
    'Stream',
    'Comparable',
    'Exception',
    'Error',
    'Duration',
    'DateTime',
    'Uri',
    'Pattern',
    'RegExp',
    'StringBuffer',
    'Record',
    'Enum',
    'Null',
    'Never',
    'BigInt',
    'Runes',
    'StackTrace',
    'Invocation',
    'Expando',
  };

  /// Dart keywords and common member names that cannot be field identifiers.
  static const Set<String> reservedFieldNames = {
    'assert',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'do',
    'else',
    'enum',
    'extends',
    'false',
    'final',
    'finally',
    'for',
    'if',
    'in',
    'is',
    'new',
    'null',
    'rethrow',
    'return',
    'super',
    'switch',
    'this',
    'throw',
    'true',
    'try',
    'var',
    'void',
    'while',
    'with',
    'hashCode',
    'runtimeType',
    'toString',
    'noSuchMethod',
    'rosType',
    'toJson',
  };

  /// The Dart class name for a ROS type name.
  ///
  /// Service and action parts arrive as `AddTwoInts_Request`; ROS type names
  /// are otherwise PascalCase with no underscores, so stripping them is safe
  /// and yields `AddTwoIntsRequest`.
  static String className(String rosTypeName) {
    final short = rosTypeName.split('/').last.replaceAll('_', '');
    final mapped = reservedTypeNames[short];
    if (mapped != null) return mapped;
    return dartCoreTypeNames.contains(short) ? 'Ros$short' : short;
  }

  /// snake_case -> camelCase, avoiding Dart keywords.
  static String fieldName(String rosName) {
    final parts = rosName.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'field';
    final buffer = StringBuffer(parts.first.toLowerCase());
    for (final part in parts.skip(1)) {
      buffer.write(part[0].toUpperCase());
      buffer.write(part.substring(1));
    }
    var name = buffer.toString();
    if (reservedFieldNames.contains(name)) name = '${name}Value';
    if (RegExp(r'^[0-9]').hasMatch(name)) name = 'f$name';
    return name;
  }

  /// SCREAMING_SNAKE -> screamingSnake, for generated constants.
  ///
  /// [taken] are the field names already declared on the same class. ROS lets
  /// a constant and a field differ only in case — `int32 POINTS=8` alongside
  /// `Point[] points` in visualization_msgs/Marker — which collapses to the
  /// same Dart identifier and makes the class fail to compile. On a clash the
  /// constant gets a `Const` suffix, since the field is what user code
  /// reaches for far more often.
  static String constantName(String rosName, {Set<String> taken = const {}}) {
    final name = fieldName(rosName.toLowerCase());
    return taken.contains(name) ? '${name}Const' : name;
  }

  /// Maps a ROS scalar type to its Dart type.
  static String? scalarDartType(String rosType) => switch (rosType) {
        'bool' => 'bool',
        'byte' || 'char' => 'int',
        'int8' || 'uint8' || 'int16' || 'uint16' => 'int',
        'int32' || 'uint32' || 'int64' || 'uint64' => 'int',
        'float32' || 'float64' => 'double',
        'string' || 'wstring' => 'String',
        _ => null,
      };

  /// The typed-data list class for a numeric array, if one fits exactly.
  ///
  /// Using these rather than `List<num>` is what lets a CBOR payload land
  /// without a per-element copy.
  static String? typedListFor(String rosType) => switch (rosType) {
        'uint8' || 'byte' || 'char' => 'Uint8List',
        'int8' => 'Int8List',
        'int16' => 'Int16List',
        'uint16' => 'Uint16List',
        'int32' => 'Int32List',
        'uint32' => 'Uint32List',
        'int64' => 'Int64List',
        'uint64' => 'Uint64List',
        'float32' => 'Float32List',
        'float64' => 'Float64List',
        _ => null,
      };

  /// The Dart type for a field, including array wrapping.
  static String dartTypeOf(FieldDef field) {
    final scalar = scalarDartType(field.type);
    if (!field.isArray) {
      return scalar ?? className(field.type);
    }
    final typed = typedListFor(field.type);
    if (typed != null) return typed;
    return 'List<${scalar ?? className(field.type)}>';
  }

  /// The `Field.*` expression that decodes this field from JSON.
  static String decodeExpr(FieldDef field) {
    final key = "'${field.name}'";
    if (field.isArray) {
      final typed = typedListFor(field.type);
      if (typed != null) {
        return switch (typed) {
          'Uint8List' => 'Field.asBytes(json[$key])',
          'Int8List' => 'Field.asInt8List(json[$key])',
          'Int32List' => 'Field.asInt32List(json[$key])',
          'Float32List' => 'Field.asFloat32List(json[$key])',
          'Float64List' => 'Field.asFloat64List(json[$key])',
          'Int16List' => 'Field.asInt16List(json[$key])',
          'Uint16List' => 'Field.asUint16List(json[$key])',
          'Uint32List' => 'Field.asUint32List(json[$key])',
          'Int64List' => 'Field.asInt64List(json[$key])',
          'Uint64List' => 'Field.asUint64List(json[$key])',
          _ => 'Field.asFloat64List(json[$key])',
        };
      }
      // Scalars with no typed-data equivalent still need a scalar decoder;
      // falling through would treat `bool[]` as an array of messages.
      final scalar = scalarDartType(field.type);
      if (scalar == 'String') return 'Field.asStringList(json[$key])';
      if (scalar == 'bool') return 'Field.asBoolList(json[$key])';
      // An explicit type argument: inference cannot resolve it from a
      // constructor tear-off alone.
      final element = className(field.type);
      return 'Field.asList<$element>(json[$key], $element.fromJson)';
    }

    return switch (scalarDartType(field.type)) {
      'bool' => 'Field.asBool(json[$key])',
      'int' => 'Field.asInt(json[$key])',
      'double' => 'Field.asDouble(json[$key])',
      'String' => 'Field.asString(json[$key])',
      _ => 'Field.asMessage(json[$key], ${className(field.type)}.fromJson)',
    };
  }

  /// The expression that encodes this field back to JSON.
  static String encodeExpr(FieldDef field) {
    final name = fieldName(field.name);
    if (field.isArray) {
      final typed = typedListFor(field.type);
      if (typed == 'Uint8List') return 'Field.encodeBytes($name)';
      if (typed != null) return 'Field.encodeNumbers($name)';
      // Scalar lists serialise as themselves; only message lists need toJson.
      if (scalarDartType(field.type) != null) return name;
      return '$name.map((${className(field.type)} e) => e.toJson()).toList()';
    }
    if (scalarDartType(field.type) != null) return name;
    return '$name.toJson()';
  }

  /// Renders a ROS literal as Dart source.
  ///
  /// ROS constants use C-style bases that Dart does not share: `0b01` is a
  /// valid ROS literal and a syntax error in Dart, which has no binary form.
  static String literal(String raw, String dartType) {
    final value = raw.trim();
    if (value.isEmpty) return dartType == 'String' ? "''" : '0';

    if (dartType == 'String') {
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        final inner = value.substring(1, value.length - 1);
        return "'${inner.replaceAll(r'\', r'\\').replaceAll("'", r"\'")}'";
      }
      return "'${value.replaceAll(r'\', r'\\').replaceAll("'", r"\'")}'";
    }

    if (dartType == 'bool') {
      final lower = value.toLowerCase();
      return (lower == '1' || lower == 'true') ? 'true' : 'false';
    }

    // Binary and octal have no Dart syntax; convert to decimal. Hex is fine.
    final negative = value.startsWith('-');
    final magnitude = negative ? value.substring(1) : value;
    final lower = magnitude.toLowerCase();
    if (lower.startsWith('0b') || lower.startsWith('0o')) {
      final radix = lower.startsWith('0b') ? 2 : 8;
      final parsed = int.tryParse(magnitude.substring(2), radix: radix);
      if (parsed != null) {
        final result = negative ? -parsed : parsed;
        return dartType == 'double' ? '$result.0' : '$result';
      }
    }

    if (dartType == 'double') {
      // Case-insensitive: `1E10.0` is not a valid literal.
      final hasExponent = value.toLowerCase().contains('e');
      if (!value.contains('.') && !hasExponent) return '$value.0';
    }
    return value;
  }

  /// A const-safe default for a field, or `null` when the field must be
  /// initialised in the constructor body instead.
  ///
  /// Typed-data lists and nested messages have no const empty form, so those
  /// are handled with a nullable parameter and a `??` initialiser, which keeps
  /// every field optional without ever failing to compile.
  static String? constDefaultFor(FieldDef field) {
    final scalar = scalarDartType(field.type);

    if (field.isArray) {
      if (typedListFor(field.type) != null) return null;
      final elements = _defaultElements(field);
      if (elements != null && scalar != null) {
        return 'const [${elements.map((e) => literal(e, scalar)).join(', ')}]';
      }
      return 'const []';
    }

    // A `.msg` default is part of the interface contract:
    // geometry_msgs/Quaternion declares `float64 w 1`, so a default-built
    // Quaternion must be the identity rotation, not all zeros.
    final declared = field.defaultValue;
    if (declared != null && scalar != null) return literal(declared, scalar);

    return switch (scalar) {
      'bool' => 'false',
      'int' => '0',
      'double' => '0',
      'String' => "''",
      _ => null,
    };
  }

  /// Splits a `[a, b, c]` array default into its element texts.
  static List<String>? _defaultElements(FieldDef field) {
    final raw = field.defaultValue?.trim();
    if (raw == null || !raw.startsWith('[') || !raw.endsWith(']')) return null;
    final inner = raw.substring(1, raw.length - 1).trim();
    if (inner.isEmpty) return const [];
    // Good enough for ROS defaults, which are scalars; a comma inside a quoted
    // string would need a real tokeniser, and does not occur in practice.
    return inner.split(',').map((e) => e.trim()).toList();
  }

  /// The fallback expression used by a `??` initialiser.
  static String fallbackFor(FieldDef field) {
    if (field.isArray) {
      final typed = typedListFor(field.type);
      if (typed != null) {
        final elements = _defaultElements(field);
        final scalar = scalarDartType(field.type);
        if (elements != null && elements.isNotEmpty && scalar != null) {
          final values = elements.map((e) => literal(e, scalar)).join(', ');
          return '$typed.fromList(const [$values])';
        }
        return '$typed(0)';
      }
      return 'const []';
    }
    return '${className(field.type)}()';
  }
}
