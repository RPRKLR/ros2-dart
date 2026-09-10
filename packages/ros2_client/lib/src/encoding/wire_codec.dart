import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:typed_data/typed_data.dart';

/// Decodes rosbridge frames off the wire into plain Dart structures.
///
/// Text frames are JSON. Binary frames are CBOR, whose RFC 8746 typed arrays
/// decode straight into [TypedData] (`Uint8List`, `Float32List`, ...). Those
/// are deliberately left untouched during normalisation: converting an image's
/// `data` field into a `List<int>` would allocate megabytes per frame and is
/// the single biggest performance trap in a rosbridge client.
abstract final class WireCodec {
  /// Decodes a WebSocket frame. [frame] is a `String` or a `List<int>`.
  static Map<String, Object?> decode(Object frame) {
    return switch (frame) {
      String() => _asStringMap(decodeJson(frame)),
      Uint8List() => _decodeCbor(frame),
      List<int>() => _decodeCbor(Uint8List.fromList(frame)),
      _ => throw FormatException('Unsupported frame type ${frame.runtimeType}'),
    };
  }

  /// Decodes a CBOR frame by walking the `CborValue` tree directly.
  ///
  /// Deliberately not `cborDecode(frame).toObject()`. A CBOR byte string --
  /// which is how rosbridge sends *every* `uint8[]`, so every camera image and
  /// every point cloud -- comes back from `toObject()` as a `List<int>` of
  /// boxed integers, and normalising that into a `List<Object?>` boxes them
  /// again. For a 1080p frame that is six million allocations before
  /// `Field.asBytes` has even started, and it made CBOR roughly five times
  /// *slower* than the base64 JSON path it exists to beat.
  ///
  /// Walking the tree keeps byte strings as `Uint8List` and typed arrays as
  /// their `TypedData` form, and does it in one pass instead of two.
  static Map<String, Object?> _decodeCbor(Uint8List frame) {
    final decoded = _fromCbor(cborDecode(frame));
    if (decoded is! Map<String, Object?>) {
      throw FormatException(
          'Expected a CBOR map, got ${decoded.runtimeType}');
    }
    return decoded;
  }

  static Object? _fromCbor(CborValue value) {
    // Order matters: CborTypedArray and CborBigInt both extend CborBytes.
    if (value is CborTypedArray) return value.toObject();
    if (value is CborBigInt) return value.toObject();
    if (value is CborBytes) return _bytesOf(value.bytes);
    if (value is CborMap) {
      final out = <String, Object?>{};
      for (final entry in value.entries) {
        out[_keyOf(entry.key)] = _fromCbor(entry.value);
      }
      return out;
    }
    if (value is CborList) {
      final out = List<Object?>.filled(value.length, null, growable: false);
      for (var i = 0; i < value.length; i++) {
        out[i] = _fromCbor(value[i]);
      }
      return out;
    }
    if (value is CborString) return value.toString();
    if (value is CborInt) return value.toInt();
    if (value is CborFloat) return value.value;
    if (value is CborBool) return value.value;
    if (value is CborNull || value is CborUndefined) return null;
    // Tags this client does not model (dates, URIs) still decode correctly.
    return normalize(value.toObject());
  }

  /// The payload of a CBOR byte string as a `Uint8List`, without copying it.
  ///
  /// The cbor package hands back a `Uint8Buffer` from `package:typed_data`,
  /// which is a `List<int>` but *not* a `TypedData`, so `Uint8List.fromList`
  /// on it copies element by element — a megabyte at a time for camera frames.
  /// It does expose its backing store, so a view costs nothing. The buffer may
  /// be longer than the logical length, hence the explicit length.
  static Uint8List _bytesOf(List<int> bytes) => switch (bytes) {
        final Uint8List list => list,
        final Uint8Buffer buffer =>
          Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.length),
        _ => Uint8List.fromList(bytes),
      };

  static String _keyOf(CborValue key) =>
      key is CborString ? key.toString() : '${_fromCbor(key)}';

  /// Decodes a JSON text frame, tolerating the non-standard numeric literals
  /// some bridges emit.
  ///
  /// Python's `json.dumps` writes bare `Infinity`, `-Infinity` and `NaN`, which
  /// are not valid JSON and which `jsonDecode` rejects outright. ROS publishes
  /// those values constantly — every out-of-range lidar beam is `inf` — so a
  /// strict parse would kill an entire topic on the first scan. The fast path
  /// is untouched; the rewrite only runs after a parse has already failed.
  static Object? decodeJson(String source) {
    try {
      return jsonDecode(source);
    } on FormatException {
      final repaired = _replaceNonFiniteLiterals(source);
      if (repaired == null) rethrow;
      return jsonDecode(repaired);
    }
  }

  /// Rewrites bare `Infinity` / `-Infinity` / `NaN` tokens to JSON-legal forms,
  /// skipping anything inside a string literal so a message whose *text*
  /// contains "NaN" is not corrupted.
  ///
  /// Returns `null` if there was nothing to replace, so a genuinely malformed
  /// document still reports its original error.
  static String? _replaceNonFiniteLiterals(String source) {
    final out = StringBuffer();
    var replaced = false;
    var i = 0;
    var inString = false;

    while (i < source.length) {
      final char = source[i];

      if (inString) {
        out.write(char);
        if (char == r'\' && i + 1 < source.length) {
          out.write(source[i + 1]);
          i += 2;
          continue;
        }
        if (char == '"') inString = false;
        i++;
        continue;
      }

      if (char == '"') {
        inString = true;
        out.write(char);
        i++;
        continue;
      }

      // `1e999` overflows to double.infinity, preserving the exact value.
      if (source.startsWith('-Infinity', i)) {
        out.write('-1e999');
        i += 9;
        replaced = true;
        continue;
      }
      if (source.startsWith('Infinity', i)) {
        out.write('1e999');
        i += 8;
        replaced = true;
        continue;
      }
      // NaN has no JSON form; null round-trips to double.nan in the float
      // array converters, which is what a NaN reading means anyway.
      if (source.startsWith('NaN', i)) {
        out.write('null');
        i += 3;
        replaced = true;
        continue;
      }

      out.write(char);
      i++;
    }

    return replaced ? out.toString() : null;
  }

  /// Encodes an outbound command as JSON text.
  ///
  /// Non-finite doubles are written as `null`, because `jsonEncode` throws on
  /// them outright — and ROS produces them constantly, so without this,
  /// republishing a `LaserScan` whose out-of-range beams are `inf` crashes.
  /// `null` is also exactly what rosbridge itself puts on the wire for a
  /// non-finite float, so this matches the encoding on the way back in.
  static String encode(Map<String, Object?> command) =>
      jsonEncode(command, toEncodable: _encodable);

  static Object? _encodable(Object? value) {
    if (value is double && !value.isFinite) return null;
    return value;
  }

  static Map<String, Object?> _asStringMap(Object? value) {
    if (value is! Map) {
      throw FormatException(
          'Expected a CBOR/JSON map, got ${value.runtimeType}');
    }
    return normalizeMap(value);
  }

  /// Recursively retypes `Map<Object?, Object?>` to `Map<String, Object?>`,
  /// leaving [TypedData] payloads by reference.
  static Map<String, Object?> normalizeMap(Map<Object?, Object?> map) {
    final out = <String, Object?>{};
    for (final entry in map.entries) {
      out['${entry.key}'] = normalize(entry.value);
    }
    return out;
  }

  /// Normalises an arbitrary decoded value.
  static Object? normalize(Object? value) {
    // Fast path: typed arrays and scalars pass straight through.
    if (value is TypedData) return value;
    if (value is num || value is String || value is bool || value == null) {
      return value;
    }
    if (value is Map) return normalizeMap(value);
    if (value is List) {
      final normalized =
          List<Object?>.filled(value.length, null, growable: false);
      for (var i = 0; i < value.length; i++) {
        normalized[i] = normalize(value[i]);
      }
      return normalized;
    }
    return value;
  }
}
