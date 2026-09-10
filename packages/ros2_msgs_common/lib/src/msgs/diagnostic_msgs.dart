// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package diagnostic_msgs

import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;

/// This message is used to send diagnostic information about the state of the robot.
///
/// `diagnostic_msgs/msg/DiagnosticArray`
final class DiagnosticArray implements RosMessage {
  DiagnosticArray({
    ros2.Header? header,
    this.status = const [],
  }) : header = header ?? ros2.Header();

  factory DiagnosticArray.fromJson(Map<String, Object?> json) =>
      DiagnosticArray(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        status: Field.asList<DiagnosticStatus>(
            json['status'], DiagnosticStatus.fromJson),
      );

  /// for timestamp
  final ros2.Header header;

  /// an array of components being reported on
  final List<DiagnosticStatus> status;

  @override
  String get rosType => 'diagnostic_msgs/msg/DiagnosticArray';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'status': status.map((DiagnosticStatus e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiagnosticArray &&
          other.header == header &&
          _listEquals(other.status, status));

  @override
  int get hashCode => Object.hashAll([
        header,
        ...status,
      ]);

  @override
  String toString() => 'DiagnosticArray(${toJson()})';
}

/// This message holds the status of an individual component of the robot.
///
/// `diagnostic_msgs/msg/DiagnosticStatus`
final class DiagnosticStatus implements RosMessage {
  const DiagnosticStatus({
    this.level = 0,
    this.name = '',
    this.message = '',
    this.hardwareId = '',
    this.values = const [],
  });

  factory DiagnosticStatus.fromJson(Map<String, Object?> json) =>
      DiagnosticStatus(
        level: Field.asInt(json['level']),
        name: Field.asString(json['name']),
        message: Field.asString(json['message']),
        hardwareId: Field.asString(json['hardware_id']),
        values: Field.asList<KeyValue>(json['values'], KeyValue.fromJson),
      );

  static const int ok = 0;
  static const int warn = 1;
  static const int error = 2;
  static const int stale = 3;

  final int level;
  final String name;
  final String message;
  final String hardwareId;
  final List<KeyValue> values;

  @override
  String get rosType => 'diagnostic_msgs/msg/DiagnosticStatus';

  @override
  Map<String, Object?> toJson() => {
        'level': level,
        'name': name,
        'message': message,
        'hardware_id': hardwareId,
        'values': values.map((KeyValue e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiagnosticStatus &&
          other.level == level &&
          other.name == name &&
          other.message == message &&
          other.hardwareId == hardwareId &&
          _listEquals(other.values, values));

  @override
  int get hashCode => Object.hashAll([
        level,
        name,
        message,
        hardwareId,
        ...values,
      ]);

  @override
  String toString() => 'DiagnosticStatus(${toJson()})';
}

/// What to label this value when viewing.
///
/// `diagnostic_msgs/msg/KeyValue`
final class KeyValue implements RosMessage {
  const KeyValue({
    this.key = '',
    this.value = '',
  });

  factory KeyValue.fromJson(Map<String, Object?> json) => KeyValue(
        key: Field.asString(json['key']),
        value: Field.asString(json['value']),
      );

  final String key;
  final String value;

  @override
  String get rosType => 'diagnostic_msgs/msg/KeyValue';

  @override
  Map<String, Object?> toJson() => {
        'key': key,
        'value': value,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValue && other.key == key && other.value == value);

  @override
  int get hashCode => Object.hashAll([
        key,
        value,
      ]);

  @override
  String toString() => 'KeyValue(${toJson()})';
}

/// This service is used as part of the process for loading analyzers at runtime,
/// and should be used by a loader script or program, not as a standalone service.
/// Information about dynamic addition of analyzers can be found at
/// http://wiki.ros.org/diagnostics/Tutorials/Adding%20Analyzers%20at%20Runtime
///
/// `diagnostic_msgs/msg/AddDiagnostics_Request`
final class AddDiagnosticsRequest implements RosMessage {
  const AddDiagnosticsRequest({
    this.loadNamespace = '',
  });

  factory AddDiagnosticsRequest.fromJson(Map<String, Object?> json) =>
      AddDiagnosticsRequest(
        loadNamespace: Field.asString(json['load_namespace']),
      );

  final String loadNamespace;

  @override
  String get rosType => 'diagnostic_msgs/msg/AddDiagnostics_Request';

  @override
  Map<String, Object?> toJson() => {
        'load_namespace': loadNamespace,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AddDiagnosticsRequest && other.loadNamespace == loadNamespace);

  @override
  int get hashCode => Object.hashAll([
        loadNamespace,
      ]);

  @override
  String toString() => 'AddDiagnosticsRequest(${toJson()})';
}

/// True if diagnostic aggregator was updated with new diagnostics, False
/// otherwise. A false return value means that either there is a bond in the
/// aggregator which already used the requested namespace, or the initialization
/// of analyzers failed.
///
/// `diagnostic_msgs/msg/AddDiagnostics_Response`
final class AddDiagnosticsResponse implements RosMessage {
  const AddDiagnosticsResponse({
    this.success = false,
    this.message = '',
  });

  factory AddDiagnosticsResponse.fromJson(Map<String, Object?> json) =>
      AddDiagnosticsResponse(
        success: Field.asBool(json['success']),
        message: Field.asString(json['message']),
      );

  final bool success;
  final String message;

  @override
  String get rosType => 'diagnostic_msgs/msg/AddDiagnostics_Response';

  @override
  Map<String, Object?> toJson() => {
        'success': success,
        'message': message,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AddDiagnosticsResponse &&
          other.success == success &&
          other.message == message);

  @override
  int get hashCode => Object.hashAll([
        success,
        message,
      ]);

  @override
  String toString() => 'AddDiagnosticsResponse(${toJson()})';
}

/// `diagnostic_msgs/msg/SelfTest_Request`
final class SelfTestRequest implements RosMessage {
  const SelfTestRequest();

  factory SelfTestRequest.fromJson(Map<String, Object?> json) =>
      SelfTestRequest();

  @override
  String get rosType => 'diagnostic_msgs/msg/SelfTest_Request';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SelfTestRequest;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'SelfTestRequest(${toJson()})';
}

/// `diagnostic_msgs/msg/SelfTest_Response`
final class SelfTestResponse implements RosMessage {
  const SelfTestResponse({
    this.id = '',
    this.passed = 0,
    this.status = const [],
  });

  factory SelfTestResponse.fromJson(Map<String, Object?> json) =>
      SelfTestResponse(
        id: Field.asString(json['id']),
        passed: Field.asInt(json['passed']),
        status: Field.asList<DiagnosticStatus>(
            json['status'], DiagnosticStatus.fromJson),
      );

  final String id;
  final int passed;
  final List<DiagnosticStatus> status;

  @override
  String get rosType => 'diagnostic_msgs/msg/SelfTest_Response';

  @override
  Map<String, Object?> toJson() => {
        'id': id,
        'passed': passed,
        'status': status.map((DiagnosticStatus e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SelfTestResponse &&
          other.id == id &&
          other.passed == passed &&
          _listEquals(other.status, status));

  @override
  int get hashCode => Object.hashAll([
        id,
        passed,
        ...status,
      ]);

  @override
  String toString() => 'SelfTestResponse(${toJson()})';
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

/// Registers every message in `diagnostic_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerDiagnosticMsgs() {
  MessageRegistry.register(const MessageCodec<DiagnosticArray>(
    rosType: 'diagnostic_msgs/msg/DiagnosticArray',
    fromJson: DiagnosticArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<DiagnosticStatus>(
    rosType: 'diagnostic_msgs/msg/DiagnosticStatus',
    fromJson: DiagnosticStatus.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<KeyValue>(
    rosType: 'diagnostic_msgs/msg/KeyValue',
    fromJson: KeyValue.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<AddDiagnosticsRequest>(
    rosType: 'diagnostic_msgs/msg/AddDiagnostics_Request',
    fromJson: AddDiagnosticsRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<AddDiagnosticsResponse>(
    rosType: 'diagnostic_msgs/msg/AddDiagnostics_Response',
    fromJson: AddDiagnosticsResponse.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SelfTestRequest>(
    rosType: 'diagnostic_msgs/msg/SelfTest_Request',
    fromJson: SelfTestRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SelfTestResponse>(
    rosType: 'diagnostic_msgs/msg/SelfTest_Response',
    fromJson: SelfTestResponse.fromJson,
    toJson: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<AddDiagnosticsRequest, AddDiagnosticsResponse>(
    serviceType: 'diagnostic_msgs/srv/AddDiagnostics',
    encodeRequest: _toJson,
    decodeResponse: AddDiagnosticsResponse.fromJson,
    decodeRequest: AddDiagnosticsRequest.fromJson,
    encodeResponse: _toJson,
  ));
  ServiceRegistry.register(
      const ServiceCodec<SelfTestRequest, SelfTestResponse>(
    serviceType: 'diagnostic_msgs/srv/SelfTest',
    encodeRequest: _toJson,
    decodeResponse: SelfTestResponse.fromJson,
    decodeRequest: SelfTestRequest.fromJson,
    encodeResponse: _toJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
