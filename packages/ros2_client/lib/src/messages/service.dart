import 'package:meta/meta.dart';

import 'message.dart';

/// Converter for a ROS 2 service's request/response pair.
///
/// Keyed by the Dart request type, which uniquely identifies the service
/// interface, so `callService(AddTwoIntsRequest(a: 1, b: 2))` needs no
/// type strings at the call site.
@immutable
final class ServiceCodec<Req, Res> {
  const ServiceCodec({
    required this.serviceType,
    required this.encodeRequest,
    required this.decodeResponse,
    this.decodeRequest,
    this.encodeResponse,
  });

  /// e.g. `example_interfaces/srv/AddTwoInts`.
  final String serviceType;

  final Map<String, Object?> Function(Req request) encodeRequest;
  final Res Function(Map<String, Object?> json) decodeResponse;

  /// Needed only to *serve* a service from Dart.
  final Req Function(Map<String, Object?> json)? decodeRequest;
  final Map<String, Object?> Function(Res response)? encodeResponse;

  @override
  String toString() => 'ServiceCodec<$Req, $Res>($serviceType)';
}

/// Registry of service codecs, keyed by Dart request type.
abstract final class ServiceRegistry {
  static final Map<Type, ServiceCodec<Object?, Object?>> _byRequestType = {};
  static final Map<String, ServiceCodec<Object?, Object?>> _byServiceType = {};

  static void register<Req, Res>(ServiceCodec<Req, Res> codec) {
    final erased = codec as ServiceCodec<Object?, Object?>;
    _byRequestType[Req] = erased;
    _byServiceType[codec.serviceType] = erased;
  }

  static ServiceCodec<Req, Res> of<Req, Res>() {
    final codec = _byRequestType[Req];
    if (codec == null) {
      throw UnknownMessageTypeError(
          'No service codec registered for request type `$Req`.');
    }
    return codec as ServiceCodec<Req, Res>;
  }

  static ServiceCodec<Object?, Object?>? byServiceType(String type) =>
      _byServiceType[type];

  @visibleForTesting
  static void reset() {
    _byRequestType.clear();
    _byServiceType.clear();
  }
}

/// Thrown when a service call is rejected or fails on the ROS side.
final class ServiceCallException implements Exception {
  ServiceCallException(this.service, this.message);
  final String service;
  final String message;

  @override
  String toString() => 'ServiceCallException($service): $message';
}
