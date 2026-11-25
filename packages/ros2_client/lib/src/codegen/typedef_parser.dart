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
      throw TypedefException('Typedef for "${typedef.type}" is inconsistent: '
          '${typedef.fieldNames.length} names, '
          '${typedef.fieldTypes.length} types, '
          '${typedef.fieldArrayLen.length} array lengths');
    }

    final fieldNames = typedef.fieldNames.toSet();
    final defaults = _declaredDefaults(typedef, fieldNames);
    final fields = <FieldDef>[
      for (var i = 0; i < typedef.fieldNames.length; i++)
        _field(typedef.type, typedef.fieldNames[i], typedef.fieldTypes[i],
            typedef.fieldArrayLen[i], defaults[typedef.fieldNames[i]]),
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

  static FieldDef _field(String owner, String name, String rawType,
      int arrayLen, String? pythonDefault) {
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
      defaultValue: pythonDefault == null
          ? null
          : msgDefault(
              owner, name, type, isArray: arrayLen >= 0, pythonDefault),
    );
  }

  /// The suffix rosidl's Python classes give a field's declared default.
  static const _defaultSuffix = '__DEFAULT';

  /// The declared defaults, by field name, from the `<FIELD>__DEFAULT`
  /// entries rosapi lists among the constants.
  ///
  /// rosidl's Python classes carry one for each field whose `.msg` declares a
  /// default, and none otherwise, so these are exactly the defaults an offline
  /// run reads from the `.msg` itself. Without them `--from-robot` dropped
  /// every declared default: a goal's `uint8 attempts 3` came out as `0`,
  /// which the robot then received from every goal left at its default.
  static Map<String, String> _declaredDefaults(
      RosTypeDef typedef, Set<String> fieldNames) {
    final defaults = <String, String>{};
    final count = typedef.constNames.length < typedef.constValues.length
        ? typedef.constNames.length
        : typedef.constValues.length;
    for (var i = 0; i < count; i++) {
      final field = _defaultedField(typedef.constNames[i], fieldNames);
      if (field != null) defaults[field] = typedef.constValues[i];
    }
    return defaults;
  }

  /// The field a `<FIELD>__DEFAULT` entry belongs to, or `null` if [name] is
  /// not one. ROS 2 field names are lower case, so the match is exact.
  static String? _defaultedField(String name, Set<String> fieldNames) {
    if (!name.endsWith(_defaultSuffix)) return null;
    final field =
        name.substring(0, name.length - _defaultSuffix.length).toLowerCase();
    return fieldNames.contains(field) ? field : null;
  }

  /// Rewrites a Python repr of a default as `.msg` default text, the form
  /// the offline parser stores and the emitter reads.
  ///
  /// rosapi renders each shape differently: a string bare (`m1`), a bool as
  /// `True`, an unbounded number array as `array('i', [1, 2, 3])`, a fixed one
  /// as a numpy repr without commas (`[0.5 1.5 2.5]`), and a string array as a
  /// Python list. Anything else is refused rather than guessed at, since a
  /// wrong default is sent to the robot by every message left at it.
  @visibleForTesting
  static String msgDefault(
      String owner, String field, String type, String python,
      {required bool isArray}) {
    TypedefException refuse() => TypedefException(
        'Field "$field" of "$owner" has a default rosapi renders as '
        '"$python", which cannot be read reliably. Generate this package '
        'offline with --search instead.');
    final isString = type == 'string' || type == 'wstring';
    if (!isArray) {
      // Quoted, so a value that itself begins and ends with a quote keeps
      // them: the emitter strips one pair. Not trimmed: `" | "` is a default.
      if (isString) return '"$python"';
      final value = python.trim();
      // A `byte` default is a Python bytes object: `byte mode 3` is b'\x03'.
      if (type == 'byte') return '${parseBytesRepr(value) ?? (throw refuse())}';
      return value;
    }
    final value = python.trim();
    if (value.contains('...')) throw refuse(); // numpy elides long arrays
    final typed = RegExp(r"^array\('\w+',\s*(\[.*\])\)$").firstMatch(value);
    if (typed != null) return typed.group(1)!;
    if (value.startsWith('array(')) return '[]'; // array('d') is empty
    if (!value.startsWith('[') || !value.endsWith(']')) throw refuse();
    // A Python list, which is already `.msg` syntax. Never split a string
    // array on whitespace below: its elements may contain spaces.
    if (isString) return value;
    if (type == 'byte') {
      // A list of bytes objects, `[b'\x01', b'\x02']`. Matched whole, since
      // the byte 0x2c is itself `b','`.
      final inner = value.substring(1, value.length - 1).trim();
      final tokens =
          _bytesRepr.allMatches(inner).map((m) => m.group(0)!).toList();
      final rest =
          inner.replaceAll(_bytesRepr, '').replaceAll(RegExp(r'[\s,]'), '');
      if (rest.isNotEmpty) throw refuse();
      final bytes = [
        for (final t in tokens) parseBytesRepr(t) ?? (throw refuse())
      ];
      return '[${bytes.join(', ')}]';
    }
    final inner = value.substring(1, value.length - 1).trim();
    if (inner.isEmpty || inner.contains(',')) return value;
    // numpy: whitespace-separated, `0.` for a whole float, and floats printed
    // to at most 8 significant digits. One printed at all 8 may have been
    // rounded (0.123456789012 prints as 0.12345679), and a rounded default
    // would be sent to the robot, so that is refused rather than guessed at.
    final elements = inner.split(RegExp(r'\s+'));
    if ((type == 'float32' || type == 'float64') &&
        elements.any((e) => _significantDigits(e) >= 8)) {
      throw refuse();
    }
    return '[${elements.map((e) => e.replaceAllMapped(RegExp(r'\.(?=e|E|$)'), (_) => '.0')).join(', ')}]';
  }

  /// One Python bytes repr: `b'\x01'`, or `b"'"` for the byte that is a quote.
  static final _bytesRepr =
      RegExp(r"b'(?:[^'\\]|\\.)*'" r'|b"(?:[^"\\]|\\.)*"');

  /// The significant digits in a printed number's mantissa: `0.0125` has 3.
  static int _significantDigits(String number) {
    final mantissa = number.split(RegExp('[eE]')).first;
    final digits = mantissa.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.replaceFirst(RegExp('^0+'), '').length;
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
      if (name == _notAConstant ||
          fieldNames.contains(name) ||
          _defaultedField(name, fieldNames) != null) {
        continue;
      }
      final raw = typedef.constValues[i];
      // rosapi renders a `byte` constant with Python's bytes repr, so
      // diagnostic_msgs/DiagnosticStatus `byte OK=0` arrives as `b'\x00'`.
      // Taken as a string, `status.level == DiagnosticStatus.ok` compiled and
      // was always false.
      final byte = parseBytesRepr(raw);
      constants.add(byte != null
          ? ConstantDef(type: 'byte', name: name, value: '$byte')
          : ConstantDef(type: inferConstantType(raw), name: name, value: raw));
    }
    return constants;
  }

  /// The declared type of a constant, which rosapi does not report.
  ///
  /// Only the stringified value survives the round trip, so the width is not
  /// recoverable — `int32` stands in for every integer type. That costs
  /// nothing downstream, since every ROS integer maps to a Dart `int`.
  /// The value of a one-byte Python bytes repr such as `b'\x02'` or `b'A'`,
  /// or `null` if [value] is not one.
  static int? parseBytesRepr(String value) {
    final match =
        RegExp(r'''^b(['"])(.*)\1$''', dotAll: true).firstMatch(value);
    if (match == null) return null;
    final body = match.group(2)!;
    final bytes = <int>[];
    for (var i = 0; i < body.length; i++) {
      final c = body[i];
      if (c != r'\') {
        bytes.add(body.codeUnitAt(i));
        continue;
      }
      if (i + 1 >= body.length) return null;
      final e = body[++i];
      switch (e) {
        case 'x':
          if (i + 2 >= body.length) return null;
          final hex = int.tryParse(body.substring(i + 1, i + 3), radix: 16);
          if (hex == null) return null;
          bytes.add(hex);
          i += 2;
        case 'n':
          bytes.add(0x0a);
        case 'r':
          bytes.add(0x0d);
        case 't':
          bytes.add(0x09);
        case r'\' || "'" || '"':
          bytes.add(e.codeUnitAt(0));
        default:
          return null;
      }
    }
    return bytes.length == 1 && bytes.single < 256 ? bytes.single : null;
  }

  static String inferConstantType(String value) {
    if (value == 'True' || value == 'False') return 'bool';
    if (int.tryParse(value) != null) return 'int32';
    if (double.tryParse(value) != null) return 'float64';
    return 'string';
  }
}
