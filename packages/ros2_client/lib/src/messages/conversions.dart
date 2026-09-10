import 'dart:convert';
import 'dart:typed_data';

/// Field decoding helpers shared by all generated message classes.
///
/// These absorb the differences between rosbridge's JSON and CBOR encodings so
/// generated code — and user code — never has to care which is in use.
abstract final class Field {
  static double asDouble(Object? v) => switch (v) {
        final double d => d,
        final int i => i.toDouble(),
        final String s => double.tryParse(s) ?? double.nan,
        _ => 0.0,
      };

  static int asInt(Object? v) => switch (v) {
        final int i => i,
        final double d => d.toInt(),
        final String s => int.tryParse(s) ?? 0,
        _ => 0,
      };

  static bool asBool(Object? v) => v == true || v == 1;

  static String asString(Object? v) => v is String ? v : (v?.toString() ?? '');

  /// Decodes a ROS `uint8[]` field.
  ///
  /// rosbridge sends these three different ways depending on transport:
  /// a base64 `String` over JSON, a `Uint8List` under CBOR typed arrays, and a
  /// plain `List<int>` from some bridges and test fixtures.
  static Uint8List asBytes(Object? v) => switch (v) {
        final Uint8List b => b,
        final String s => base64Decode(s),
        final List<Object?> l => Uint8List.fromList(l.map(asInt).toList()),
        final TypedData t =>
          t.buffer.asUint8List(t.offsetInBytes, t.lengthInBytes),
        _ => Uint8List(0),
      };

  /// Decodes a ROS `float32[]` field, avoiding a copy when CBOR already
  /// delivered a [Float32List].
  ///
  /// A `null` element becomes [double.nan]: it is how a `NaN` reading survives
  /// a JSON round trip, and NaN is the correct "no measurement" value for the
  /// sensor arrays where this occurs.
  static Float32List asFloat32List(Object? v) => switch (v) {
        final Float32List f => f,
        final List<Object?> l =>
          Float32List.fromList(l.map(_measurement).toList(growable: false)),
        _ => Float32List(0),
      };

  static Float64List asFloat64List(Object? v) => switch (v) {
        final Float64List f => f,
        final List<Object?> l =>
          Float64List.fromList(l.map(_measurement).toList(growable: false)),
        _ => Float64List(0),
      };

  static double _measurement(Object? v) => v == null ? double.nan : asDouble(v);

  static Int32List asInt32List(Object? v) => switch (v) {
        final Int32List i => i,
        final List<Object?> l =>
          Int32List.fromList(l.map(asInt).toList(growable: false)),
        _ => Int32List(0),
      };

  static Int8List asInt8List(Object? v) => switch (v) {
        final Int8List i => i,
        final List<Object?> l =>
          Int8List.fromList(l.map(asInt).toList(growable: false)),
        _ => Int8List(0),
      };

  static Int16List asInt16List(Object? v) => switch (v) {
        final Int16List i => i,
        final List<Object?> l =>
          Int16List.fromList(l.map(asInt).toList(growable: false)),
        _ => Int16List(0),
      };

  static Uint16List asUint16List(Object? v) => switch (v) {
        final Uint16List i => i,
        final List<Object?> l =>
          Uint16List.fromList(l.map(asInt).toList(growable: false)),
        _ => Uint16List(0),
      };

  static Uint32List asUint32List(Object? v) => switch (v) {
        final Uint32List i => i,
        final List<Object?> l =>
          Uint32List.fromList(l.map(asInt).toList(growable: false)),
        _ => Uint32List(0),
      };

  static Int64List asInt64List(Object? v) => switch (v) {
        final Int64List i => i,
        final List<Object?> l =>
          Int64List.fromList(l.map(asInt).toList(growable: false)),
        _ => Int64List(0),
      };

  static Uint64List asUint64List(Object? v) => switch (v) {
        final Uint64List i => i,
        final List<Object?> l =>
          Uint64List.fromList(l.map(asInt).toList(growable: false)),
        _ => Uint64List(0),
      };

  /// Decodes a ROS `bool[]` field. There is no typed-data list for booleans.
  static List<bool> asBoolList(Object? v) =>
      v is List ? v.map(asBool).toList(growable: false) : const <bool>[];

  static List<String> asStringList(Object? v) =>
      v is List ? v.map(asString).toList(growable: false) : const [];

  /// Decodes an array of nested messages.
  static List<T> asList<T>(Object? v, T Function(Map<String, Object?>) from) {
    if (v is! List) return const [];
    return v
        .whereType<Map<String, Object?>>()
        .map(from)
        .toList(growable: false);
  }

  /// Decodes a nested message, tolerating a missing field.
  static T asMessage<T>(Object? v, T Function(Map<String, Object?>) from) =>
      from(v is Map<String, Object?> ? v : const {});

  /// Encodes a `uint8[]` for the JSON wire form.
  static Object encodeBytes(Uint8List bytes) => base64Encode(bytes);

  /// Encodes a numeric typed array for the JSON wire form.
  static List<num> encodeNumbers(List<num> values) =>
      values.toList(growable: false);
}
