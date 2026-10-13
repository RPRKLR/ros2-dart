import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'connect_channel.dart' if (dart.library.io) 'connect_channel_io.dart';
import 'transport.dart';

/// A [RosTransport] over a WebSocket, working on every Flutter target
/// (mobile, desktop, and web, where `dart:io` is unavailable).
final class WebSocketTransport implements RosTransport {
  WebSocketTransport(
    this.uri, {
    this.protocols,
    this.connectTimeout = const Duration(seconds: 10),
    this.pingInterval = const Duration(seconds: 5),
    WebSocketChannel Function(Uri, {Iterable<String>? protocols})?
        channelFactory,
  }) : _channelFactory = channelFactory;

  final Uri uri;
  final Iterable<String>? protocols;
  final Duration connectTimeout;

  /// How often to ping the bridge, or `null` not to.
  ///
  /// A Wi-Fi drop or a robot losing power usually leaves the socket half
  /// open: nothing arrives, nothing errors, and without pings the client
  /// stays "connected" indefinitely while every command goes nowhere. A ping
  /// unanswered by the next one closes the link and starts a reconnect, so
  /// one is noticed within about twice this. Native platforms only; browsers
  /// do not let a page send pings. Ignored when a `channelFactory` is given.
  final Duration? pingInterval;
  final WebSocketChannel Function(Uri, {Iterable<String>? protocols})?
      _channelFactory;

  WebSocketChannel? _channel;
  final _incoming = StreamController<Object>.broadcast();
  bool _closed = false;

  @override
  Stream<Object> get incoming => _incoming.stream;

  @override
  Future<void> connect() async {
    if (_closed) {
      throw StateError(
          'WebSocketTransport has been closed and cannot reconnect. '
          'Create a new instance.');
    }
    final factory = _channelFactory;
    final channel = factory != null
        ? factory(uri, protocols: protocols)
        : connectChannel(uri, protocols: protocols, pingInterval: pingInterval);
    _channel = channel;

    await channel.ready.timeout(
      connectTimeout,
      onTimeout: () => throw TimeoutException(
          'Timed out connecting to $uri after $connectTimeout', connectTimeout),
    );

    channel.stream.listen(
      (frame) {
        if (frame is Object && !_incoming.isClosed) _incoming.add(frame);
      },
      onError: (Object e, StackTrace s) {
        if (!_incoming.isClosed) _incoming.addError(e, s);
      },
      onDone: () {
        // Surface remote closure as a stream error so the client's reconnect
        // path is driven by exactly one signal.
        if (!_incoming.isClosed && !_closed) {
          _incoming.addError(
            WebSocketChannelException(
                'Connection to $uri closed by peer (code ${channel.closeCode})'),
            StackTrace.current,
          );
        }
      },
      cancelOnError: false,
    );
  }

  @override
  void send(String data) {
    final channel = _channel;
    if (channel == null) {
      throw StateError('Cannot send before connect() completes.');
    }
    channel.sink.add(data);
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _channel?.sink.close();
    await _incoming.close();
  }
}
