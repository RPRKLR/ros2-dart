/// Converts `rosapi/message_details` typedefs into the same [MessageDef] the
/// `.msg` parser produces, so a live robot can drive code generation.
library;

import 'package:meta/meta.dart';

import 'interface_def.dart';

/// Thrown when a typedef cannot be turned into a message definition.
final class TypedefException implements Exception {
  TypedefException(this.message);
  final String message;

  @override
  String toString() => 'TypedefException: $message';
}

/// One `rosapi_msgs/msg/TypeDef`, as returned by `rosapi/message_details`.
///
/// The parallel-array shape is rosapi's, not ours: field `i` is described by
/// `fieldNames[i]`, `fieldTypes[i]` and `fieldArrayLen[i]`.
@immutable
final class RosTypeDef {
  const RosTypeDef({
    required this.type,
    required this.fieldNames,
    required this.fieldTypes,
    required this.fieldArrayLen,
    this.constNames = const [],
    this.constValues = const [],
  });

  factory RosTypeDef.fromJson(Map<String, Object?> json) => RosTypeDef(
        type: '${json['type'] ?? ''}',
        fieldNames: _strings(json['fieldnames']),
        fieldTypes: _strings(json['fieldtypes']),
        fieldArrayLen: _ints(json['fieldarraylen']),
        constNames: _strings(json['constnames']),
        constValues: _strings(json['constvalues']),
      );

  /// `package/TypeName`, e.g. `sensor_msgs/LaserScan`.
  final String type;

  final List<String> fieldNames;
  final List<String> fieldTypes;

  /// `-1` not an array, `0` unbounded, `> 0` a fixed length.
  final List<int> fieldArrayLen;

  final List<String> constNames;
  final List<String> constValues;

  static List<String> _strings(Object? value) =>
      value is List ? [for (final v in value) '$v'] : const [];

  static List<int> _ints(Object? value) => value is List
      ? [for (final v in value) v is num ? v.toInt() : int.tryParse('$v') ?? -1]
      : const [];

  @override
  String toString() => 'RosTypeDef($type, ${fieldNames.length} fields)';
}

/// Turns rosapi typedefs into [MessageDef]s.
abstract final class TypedefParser {
  /// rosapi reports the IDL spelling of the primitives, while `.msg` files —
  /// and therefore the emitter — use the ROS names. Without this remap every
  /// `float64` field arrives as `double` and is generated as a nested message
  /// class that does not exist.
  static const _idlToRos = {
    'double': 'float64',
    'float': 'float32',
    'boolean': 'bool',
    'octet': 'byte',
  };

  /// Attributes rosapi reports as constants that are not constants.
  ///
  /// `_handle_constant_information` walks `inspect.getmembers`, which picks up
  /// every generated property. Field names are filtered per-message; this is
  /// the one fixed name that is never a field.
  static const _notAConstant = 'SLOT_TYPES';

  /// Converts one typedef into a message definition.
  ///
  /// Throws [TypedefException] if the parallel arrays disagree, which means a
  /// malformed response rather than an unsupported type.
  static MessageDef toMessage(RosTypeDef typedef) {
    final (package, name) = splitType(typedef.type);
    if (package.isEmpty || name.isEmpty) {
      throw TypedefException('Malformed type name "${typedef.type}"; '
          'expected "package/TypeName"');
    }
    if (typedef.fieldTypes.length != typedef.fieldNames.length ||
        typedef.fieldArrayLen.length != typedef.fieldNames.length) {
      throw TypedefException(
          'Typedef for "${typedef.type}" is inconsistent: '
          '${typedef.fieldNames.length} names, '
          '${typedef.fieldTypes.length} types, '
          '${typedef.fieldArrayLen.length} array lengths');
    }

    final fields = <FieldDef>[
      for (var i = 0; i < typedef.fieldNames.length; i++)
        _field(typedef.type, typedef.fieldNames[i], typedef.fieldTypes[i],
            typedef.fieldArrayLen[i]),
    ];

    return MessageDef(
      package: package,
      name: name,
      fields: fields,
      constants: _constants(typedef, {for (final f in fields) f.name}),
    );
  }

  /// Splits `package/Type` or `package/msg/Type` into its parts.
  static (String, String) splitType(String type) {
    final parts = type.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) return ('', '');
    return (parts.first, parts.last);
  }

  static FieldDef _field(
      String owner, String name, String rawType, int arrayLen) {
    // rosapi's regex captures the whole of `sequence<T, N>` as the type, and
    // leaves `string<N>` intact. In practice rosapi raises before returning
    // either, but a future version that stops raising must not silently
    // generate a class named after the bound.
    if (rawType.contains(',') || rawType.contains('<')) {
      throw TypedefException(
          'Field "$name" of "$owner" has bounded type "$rawType", which '
          'rosapi cannot describe. Generate this package offline with '
          '--search instead.');
    }

    final type = _idlToRos[rawType] ?? rawType;
    return FieldDef(
      type: type,
      name: name,
      arrayKind: switch (arrayLen) {
        < 0 => ArrayKind.none,
        0 => ArrayKind.unbounded,
        _ => ArrayKind.fixed,
      },
      arraySize: arrayLen > 0 ? arrayLen : null,
    );
  }

  /// Real constants, separated from the noise rosapi mixes in with them.
  static List<ConstantDef> _constants(
      RosTypeDef typedef, Set<String> fieldNames) {
    final constants = <ConstantDef>[];
    final count = typedef.constNames.length < typedef.constValues.length
        ? typedef.constNames.length
        : typedef.constValues.length;

    for (var i = 0; i < count; i++) {
      final name = typedef.constNames[i];
      // Every field appears here too, carrying its default value, and so does
      // SLOT_TYPES, whose value is a Python repr with a memory address in it.
      if (name == _notAConstant || fieldNames.contains(name)) continue;
      final value = typedef.constValues[i];
      constants.add(
          ConstantDef(type: inferConstantType(value), name: name, value: value));
    }
    return constants;
  }

  /// The declared type of a constant, which rosapi does not report.
  ///
  /// Only the stringified value survives the round trip, so the width is not
  /// recoverable — `int32` stands in for every integer type. That costs
  /// nothing downstream, since every ROS integer maps to a Dart `int`.
  static String inferConstantType(String value) {
    if (value == 'True' || value == 'False') return 'bool';
    if (int.tryParse(value) != null) return 'int32';
    if (double.tryParse(value) != null) return 'float64';
    return 'string';
  }
}
