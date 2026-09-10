import 'dart:convert';
import 'dart:typed_data';

/// Field decoding helpers shared by all generated message classes.
///
/// These absorb the differences between rosbridge's JSON and CBOR encodings so
/// generated code — and user code — never has to care which is in use.
abstract final class Field {
  /// Reads [key] from [json] as a double, distinguishing three cases that a
  /// bare value cannot.
  ///
  /// * **Key absent** — the message did not carry this field, so [orAbsent]
  ///   applies. That is the value the `.msg` declares, which is not always
  ///   zero: `geometry_msgs/Quaternion` declares `float64 w 1`, and decoding
  ///   an absent rotation as all-zeros produces the *invalid* quaternion. A
  ///   zero quaternion behaves like identity when rotating a point but
  ///   annihilates a Hamilton product, so one such link silently erases the
  ///   rotation of an entire tf chain.
  /// * **Value `null`** — rosbridge writes `null` for every non-finite float
  ///   (`message_conversion.py`: "JSON does not support Inf and NaN. They are
  ///   mapped to None"). `null` therefore means "no measurement", and NaN is
  ///   how ROS spells that. Returning `0.0` turns an unknown battery charge
  ///   into a confident zero and puts a NaN pose at the origin.
  /// * **Value present** — decoded as [asDouble].
  ///
  /// The array converters have always mapped `null` to NaN; this brings
  /// scalars into line with them.
  static double doubleAt(Map<String, Object?> json, String key,
      [double orAbsent = 0]) {
    if (!json.containsKey(key)) return orAbsent;
    final value = json[key];
    return value == null ? double.nan : asDouble(value);
  }

  /// Reads [key] as an int, falling back to [orAbsent] when it is absent or
  /// null. Unlike floats there is no "unknown" integer, so null is treated as
  /// absent rather than mapped to a sentinel.
  static int intAt(Map<String, Object?> json, String key, [int orAbsent = 0]) =>
      json[key] == null ? orAbsent : asInt(json[key]);

  /// Reads [key] as a bool, falling back to [orAbsent].
  static bool boolAt(Map<String, Object?> json, String key,
          [bool orAbsent = false]) =>
      json[key] == null ? orAbsent : asBool(json[key]);

  /// Reads [key] as a string, falling back to [orAbsent].
  static String stringAt(Map<String, Object?> json, String key,
          [String orAbsent = '']) =>
      json[key] == null ? orAbsent : asString(json[key]);

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
  ///
  /// Accepts any `Map`, not only `Map<String, Object?>`: a hand-built message
  /// or a fixture can easily hold `Map<Object?, Object?>`, and filtering those
  /// out silently produced an *empty* array rather than an error.
  ///
  /// An element that is not a map is a corrupt message, and throws. Dropping
  /// it would renumber everything after it — a path's waypoints shift by one,
  /// with nothing to indicate they had. The client catches decode failures per
  /// message and reports them on `status`, so one bad message is lost rather
  /// than the subscription.
  static List<T> asList<T>(Object? v, T Function(Map<String, Object?>) from) {
    if (v is! List) return const [];
    return List<T>.unmodifiable(v.map((element) {
      if (element is Map<String, Object?>) return from(element);
      if (element is Map<Object?, Object?>) {
        return from(element.cast<String, Object?>());
      }
      throw FormatException(
          'Expected a message in an array, got ${element.runtimeType}');
    }));
  }

  /// Decodes a nested message, tolerating a missing field.
  ///
  /// An absent message decodes from an empty map, so every field falls back to
  /// the default its `.msg` declares — which is why [doubleAt] takes one.
  static T asMessage<T>(Object? v, T Function(Map<String, Object?>) from) =>
      from(switch (v) {
        final Map<String, Object?> m => m,
        final Map<Object?, Object?> m => m.cast<String, Object?>(),
        _ => const {},
      });

  /// Encodes a `uint8[]` for the JSON wire form.
  static Object encodeBytes(Uint8List bytes) => base64Encode(bytes);

  /// Encodes a numeric typed array for the JSON wire form.
  static List<num> encodeNumbers(List<num> values) =>
      values.toList(growable: false);
}
