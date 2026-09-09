import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';

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
      Uint8List() => _asStringMap(cborDecode(frame).toObject()),
      List<int>() =>
        _asStringMap(cborDecode(Uint8List.fromList(frame)).toObject()),
      _ => throw FormatException('Unsupported frame type ${frame.runtimeType}'),
    };
  }

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
  /// Outbound traffic is command-shaped (small), so JSON keeps the wire
  /// human-inspectable with no measurable cost.
  static String encode(Map<String, Object?> command) => jsonEncode(command);

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
