// Connecting over TLS (`wss://`), including to a robot with a self-signed
// certificate — which is what almost every robot on a private network has.
//
// On the robot:
//   openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem \
//     -days 365 -nodes -subj "/CN=robot.local" \
//     -addext "subjectAltName=DNS:robot.local"
//   ros2 launch rosbridge_server rosbridge_websocket_launch.xml \
//     ssl:=true certfile:=cert.pem keyfile:=key.pem
//
// Then:
//   dart run example/secure_connection.dart wss://robot.local:9090 cert.pem
import 'dart:io';

import 'package:ros2_client/ros2_client.dart';
import 'package:web_socket_channel/io.dart';

Future<void> main(List<String> args) async {
  registerStandardMessages();

  final uri = Uri.parse(args.isEmpty ? 'wss://localhost:9090' : args.first);
  final certPath = args.length > 1 ? args[1] : null;

  // With a certificate signed by a public CA, nothing special is needed:
  //
  //   final ros = Ros2Client(Uri.parse('wss://robot.example.com:9090'));
  //
  // A self-signed certificate fails with CERTIFICATE_VERIFY_FAILED, because
  // Dart has no reason to trust it. The fix is to trust *that* certificate,
  // not to switch verification off — pinning it by file means a different
  // certificate on the same address is still rejected, which is the whole
  // point of using TLS on a network you do not fully control.
  final ros = Ros2Client(
    uri,
    transportFactory: certPath == null
        ? null
        : (target) {
            final context = SecurityContext(withTrustedRoots: true)
              ..setTrustedCertificates(certPath);
            final client = HttpClient(context: context);
            return WebSocketTransport(
              target,
              channelFactory: (u, {Iterable<String>? protocols}) =>
                  IOWebSocketChannel.connect(u,
                      protocols: protocols, customClient: client),
            );
          },
  );

  try {
    await ros.connect().timeout(const Duration(seconds: 15));
    stdout.writeln('Connected to $uri');
    final topics = await ros.listTopics();
    stdout.writeln('${topics.length} topics:');
    for (final topic in topics.take(10)) {
      stdout.writeln('  $topic');
    }
  } on Object catch (e) {
    stderr.writeln('Could not connect to $uri: $e');
    if ('$e'.contains('CERTIFICATE_VERIFY_FAILED')) {
      stderr.writeln('\nThe robot is using a certificate Dart does not trust. '
          'Pass its .pem as the second argument to pin it.');
    }
    await ros.close();
    exit(1);
  }
  await ros.close();
}
