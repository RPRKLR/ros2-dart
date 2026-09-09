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
  static String className(String rosTypeName) {
    final short = rosTypeName.split('/').last;
    return reservedTypeNames[short] ?? short;
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

  /// A const-safe default for a field, or `null` when the field must be
  /// initialised in the constructor body instead.
  ///
  /// Typed-data lists and nested messages have no const empty form, so those
  /// are handled with a nullable parameter and a `??` initialiser, which keeps
  /// every field optional without ever failing to compile.
  static String? constDefaultFor(FieldDef field) {
    if (field.isArray) {
      if (typedListFor(field.type) != null) return null;
      return 'const []';
    }
    return switch (scalarDartType(field.type)) {
      'bool' => 'false',
      'int' => '0',
      'double' => '0',
      'String' => "''",
      _ => null,
    };
  }

  /// The fallback expression used by a `??` initialiser.
  static String fallbackFor(FieldDef field) {
    if (field.isArray) {
      final typed = typedListFor(field.type);
      if (typed != null) return '$typed(0)';
      return 'const []';
    }
    return '${className(field.type)}()';
  }
}
