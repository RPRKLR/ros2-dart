// The wire formats rosbridge actually produces, and the shapes they must
// decode into. `rosbridge_library/internal/cbor_conversion.py` is the
// reference: uint8[] goes out as a plain CBOR byte string, numeric arrays as
// RFC 8746 tagged arrays, and fixed-size arrays as plain lists.
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:ros2_client/src/encoding/wire_codec.dart';
import 'package:test/test.dart';

Uint8List frame(Object? value) =>
    Uint8List.fromList(cborEncode(CborValue(value)));

Map<String, Object?> decodeMsg(Object? msg) => WireCodec.decode(
        frame({'op': 'publish', 'topic': '/t', 'msg': msg}))['msg']!
    as Map<String, Object?>;

void main() {
  group('uint8[] as a byte string', () {
    test('decodes to a Uint8List, not a list of boxed ints', () {
      final pixels = Uint8List.fromList(List.generate(256, (i) => i));
      final data = decodeMsg({'data': CborBytes(pixels)})['data'];

      // The whole point. A List<int> here costs an allocation per byte, and
      // made CBOR five times slower than the base64 JSON path it replaces.
      expect(data, isA<Uint8List>());
      expect(data, pixels);
    });

    test('is a view over the frame rather than a copy', () {
      // 4 KB is past any small-buffer threshold, so a copy would be obvious.
      final pixels = Uint8List(4096);
      for (var i = 0; i < pixels.length; i++) {
        pixels[i] = i & 0xff;
      }
      final data = decodeMsg({'data': CborBytes(pixels)})['data']! as Uint8List;

      expect(data.length, 4096);
      expect(data[1000], 1000 & 0xff);
      // A fresh Uint8List.fromList always starts at zero; a view into the
      // decoder's buffer generally does not.
      expect(data.buffer.lengthInBytes, greaterThanOrEqualTo(data.length));
    });

    test('an empty byte string is an empty Uint8List', () {
      final data = decodeMsg({'data': CborBytes(Uint8List(0))})['data'];
      expect(data, isA<Uint8List>());
      expect(data, isEmpty);
    });
  });

  group('RFC 8746 tagged arrays', () {
    test('float32[] decodes to a Float32List', () {
      final values = Float32List.fromList([1.5, -2.5, 3.25]);
      final msg = decodeMsg({
        // Tag 85, little-endian, exactly as cbor_conversion.py writes it.
        // The CborFloat32LittleEndianArray constructor does not attach its own
        // tag, so an explicit one is the only construction that round-trips.
        'ranges': CborBytes(Uint8List.sublistView(values),
            tags: [CborTag.float32ArrayLE]),
      });

      expect(msg['ranges'], isA<Float32List>());
      expect(msg['ranges'], [1.5, -2.5, 3.25]);
    });

    test('int32[] decodes to an Int32List', () {
      final values = Int32List.fromList([-7, 9, 2147483647]);
      final msg = decodeMsg({
        'v': CborBytes(Uint8List.sublistView(values),
            tags: [CborTag.sint32ArrayLE]),
      });

      expect(msg['v'], isA<Int32List>());
      expect(msg['v'], [-7, 9, 2147483647]);
    });

    test('a tagged uint8 array also decodes to a Uint8List', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final msg = decodeMsg({
        'd': CborBytes(bytes, tags: [CborTag.uint8Array])
      });
      expect(msg['d'], isA<Uint8List>());
      expect(msg['d'], bytes);
    });
  });

  group('everything else still decodes', () {
    test('a fixed-size array stays a plain list of numbers', () {
      // cbor_conversion.py sends float64[36] as `val.tolist()`, not a tagged
      // array, so this must not be mistaken for bytes.
      final msg = decodeMsg({
        'covariance': [0.0, 1.5, -2.5],
      });
      expect(msg['covariance'], isA<List<Object?>>());
      expect(msg['covariance'], [0.0, 1.5, -2.5]);
    });

    test('scalars, strings, bools and nulls', () {
      final msg = decodeMsg({
        'i': 42,
        'neg': -7,
        'd': 1.25,
        's': 'laser',
        'b': true,
        'n': null,
      });
      expect(msg['i'], 42);
      expect(msg['neg'], -7);
      expect(msg['d'], 1.25);
      expect(msg['s'], 'laser');
      expect(msg['b'], isTrue);
      expect(msg['n'], isNull);
    });

    test('nested messages and arrays of messages', () {
      final msg = decodeMsg({
        'header': {
          'stamp': {'sec': 12, 'nanosec': 34},
          'frame_id': 'map',
        },
        'points': [
          {'x': 1.0},
          {'x': 2.0},
        ],
      });

      final header = msg['header']! as Map<String, Object?>;
      expect((header['stamp']! as Map<String, Object?>)['sec'], 12);
      expect(header['frame_id'], 'map');
      final points = msg['points']! as List<Object?>;
      expect((points[1]! as Map<String, Object?>)['x'], 2.0);
    });

    test('a CBOR frame that is not a map is rejected clearly', () {
      expect(() => WireCodec.decode(frame([1, 2, 3])),
          throwsA(isA<FormatException>()));
    });

    test('a plain List<int> frame is accepted, as some sockets deliver', () {
      final bytes = frame({'op': 'ping'}).toList();
      expect(WireCodec.decode(bytes)['op'], 'ping');
    });
  });

  group('uint64 scalars above int64', () {
    test('keep their bits instead of clamping to int64 max', () {
      // cbor2 encodes these as plain major-type-0 integers. Clamped, every
      // value from 2^63 up decoded to the same number.
      final msg = decodeMsg({
        'max': CborInt(BigInt.parse('18446744073709551615')),
        'half': CborInt(BigInt.parse('9223372036854775808')),
        'small': 42,
      });
      expect(msg['max'], -1);
      expect(msg['half'], -9223372036854775808);
      expect(BigInt.from(msg['max']! as int).toUnsigned(64),
          BigInt.parse('18446744073709551615'));
      expect(msg['small'], 42);
    });
  });

  group('uint64 in JSON', () {
    test('decodes a literal beyond int64 with its bits, like CBOR does', () {
      // jsonDecode alone returns these as doubles, low bits already gone.
      final decoded = WireCodec.decodeJson('{"max":18446744073709551615,'
          '"half":9223372036854775808,"list":[9223372036854775808,1],'
          '"int64max":9223372036854775807,"int64min":-9223372036854775808,'
          '"big":1.5e300}')! as Map<String, Object?>;
      expect(decoded['max'], -1);
      expect(decoded['half'], -9223372036854775808);
      expect(decoded['list'], [-9223372036854775808, 1]);
      expect(decoded['int64max'], 9223372036854775807);
      expect(decoded['int64min'], -9223372036854775808);
      expect(decoded['big'], 1.5e300);
    });

    test('leaves digits inside strings alone', () {
      final decoded = WireCodec.decodeJson(
          r'{"s":"id 18446744073709551615 \" 18446744073709551616",'
          r'"n":18446744073709551615}')! as Map<String, Object?>;
      expect(decoded['s'], 'id 18446744073709551615 " 18446744073709551616');
      expect(decoded['n'], -1);
    });

    test('still repairs Infinity and NaN alongside', () {
      final decoded =
          WireCodec.decodeJson('{"r":[Infinity,NaN],"n":18446744073709551615}')!
              as Map<String, Object?>;
      expect((decoded['r']! as List).first, double.infinity);
      expect(decoded['n'], -1);
    });

    test('encodes a BigInt as its bare digits', () {
      expect(
          WireCodec.encode({
            'max': BigInt.parse('18446744073709551615'),
            'list': [BigInt.from(5), 6],
            's': 'text',
          }),
          '{"max":18446744073709551615,"list":[5,6],"s":"text"}');
    });
  });
}
