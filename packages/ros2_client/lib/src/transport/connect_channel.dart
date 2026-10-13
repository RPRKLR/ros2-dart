import 'package:web_socket_channel/web_socket_channel.dart';

/// Opens a channel where `dart:io` is unavailable (the web).
///
/// Browsers answer pings but give scripts no way to send one, so
/// [pingInterval] cannot be honoured here.
WebSocketChannel connectChannel(Uri uri,
        {Iterable<String>? protocols, Duration? pingInterval}) =>
    WebSocketChannel.connect(uri, protocols: protocols);

/// Browsers cannot ping, so [Ros2Client] checks an idle link itself.
// Nullable to match the dart:io variant, which is null.
// ignore: unnecessary_nullable_for_final_variable_declarations
const Duration? defaultIdleProbeInterval = Duration(seconds: 5);
