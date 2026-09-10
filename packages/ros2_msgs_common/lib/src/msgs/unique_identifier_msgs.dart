// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package unique_identifier_msgs

import 'dart:typed_data';

import 'package:ros2_client/codegen_support.dart';

/// A universally unique identifier (UUID).
///
/// http://en.wikipedia.org/wiki/Universally_unique_identifier
/// http://tools.ietf.org/html/rfc4122.html
///
/// `unique_identifier_msgs/msg/UUID`
final class UUID implements RosMessage {
  UUID({
    Uint8List? uuid,
  }) : uuid = uuid ?? Uint8List(0);

  factory UUID.fromJson(Map<String, Object?> json) => UUID(
        uuid: Field.asBytes(json['uuid']),
      );

  /// Fixed length: 16.
  final Uint8List uuid;

  @override
  String get rosType => 'unique_identifier_msgs/msg/UUID';

  @override
  Map<String, Object?> toJson() => {
        'uuid': Field.encodeBytes(uuid),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UUID && _listEquals(other.uuid, uuid));

  @override
  int get hashCode => Object.hashAll([
        ...uuid,
      ]);

  @override
  String toString() => 'UUID(${toJson()})';
}

/// Element-wise list comparison used by generated `==`.
bool _listEquals(List<Object?> a, List<Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Registers every message in `unique_identifier_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerUniqueIdentifierMsgs() {
  MessageRegistry.register(const MessageCodec<UUID>(
    rosType: 'unique_identifier_msgs/msg/UUID',
    fromJson: UUID.fromJson,
    toJson: _toJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
