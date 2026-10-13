import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Opens a channel that pings the bridge every [pingInterval].
///
/// A pong that does not arrive before the next ping closes the socket, which
/// is the only way a half-open link is ever noticed: no error, no close, just
/// silence, and a client that reports itself connected forever.
WebSocketChannel connectChannel(Uri uri,
        {Iterable<String>? protocols, Duration? pingInterval}) =>
    IOWebSocketChannel.connect(uri,
        protocols: protocols, pingInterval: pingInterval);

/// Pings already notice a dead link here, at no cost to the bridge.
const Duration? defaultIdleProbeInterval = null;
