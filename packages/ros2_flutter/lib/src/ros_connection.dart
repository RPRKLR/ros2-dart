import 'package:flutter/widgets.dart';
import 'package:ros2_client/ros2_client.dart';

/// Owns a [Ros2Client] and exposes it to the widget subtree.
///
/// Handles the lifecycle most apps get wrong: connecting on mount, closing on
/// dispose, and reconnecting when the app returns from the background (mobile
/// platforms silently kill sockets while suspended).
class RosConnection extends StatefulWidget {
  /// Builds and owns a client for [uri], closing it when this widget is
  /// disposed.
  const RosConnection({
    required Uri this.uri,
    required this.child,
    this.reconnectPolicy = const ReconnectPolicy(),
    this.defaultCompression = Compression.none,
    this.reconnectOnResume = true,
    super.key,
  })  : client = null,
        closeClientOnDispose = true;

  /// Uses a client you construct and control.
  ///
  /// Useful when the client outlives the widget tree, when it is owned by a
  /// state-management layer, and in widget tests, where injecting a client
  /// with a fake transport avoids real network I/O.
  ///
  /// The client is *not* closed on dispose unless [closeClientOnDispose] is
  /// set, since the caller owns it.
  const RosConnection.withClient({
    required Ros2Client this.client,
    required this.child,
    this.closeClientOnDispose = false,
    this.reconnectOnResume = true,
    super.key,
  })  : uri = null,
        reconnectPolicy = const ReconnectPolicy(),
        defaultCompression = Compression.none;

  /// Set when built with the default constructor.
  final Uri? uri;

  /// Set when built with [RosConnection.withClient].
  final Ros2Client? client;

  /// Whether dispose closes the client.
  final bool closeClientOnDispose;
  final Widget child;
  final ReconnectPolicy reconnectPolicy;
  final Compression defaultCompression;

  /// Reconnect when the app is resumed from the background.
  final bool reconnectOnResume;

  /// The nearest client above [context].
  ///
  /// Throws if there is no [RosConnection] ancestor — use [maybeOf] when that
  /// is a legitimate state.
  static Ros2Client of(BuildContext context) {
    final client = maybeOf(context);
    if (client == null) {
      throw FlutterError(
        'RosConnection.of() found no RosConnection ancestor.\n'
        'Wrap the widget tree above this point in a RosConnection.',
      );
    }
    return client;
  }

  static Ros2Client? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_RosScope>()
      ?.client;

  @override
  State<RosConnection> createState() => _RosConnectionState();
}

class _RosConnectionState extends State<RosConnection>
    with WidgetsBindingObserver {
  late Ros2Client _client;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _client = _build();
    _connect();
  }

  Ros2Client _build() =>
      widget.client ??
      Ros2Client(
        widget.uri!,
        reconnectPolicy: widget.reconnectPolicy,
        defaultCompression: widget.defaultCompression,
      );

  void _connect() {
    // Connection failures are already routed into the reconnect loop and the
    // states stream; swallowing here keeps them off the zone error handler.
    _client.connect().catchError((Object _) {});
  }

  @override
  void didUpdateWidget(RosConnection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri != widget.uri || oldWidget.client != widget.client) {
      final old = _client;
      _client = _build();
      _connect();
      if (oldWidget.client == null) old.close();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.reconnectOnResume) return;
    if (state == AppLifecycleState.resumed && !_client.isConnected) {
      _connect();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.client == null || widget.closeClientOnDispose) {
      _client.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _RosScope(client: _client, child: widget.child);
}

class _RosScope extends InheritedWidget {
  const _RosScope({required this.client, required super.child});

  final Ros2Client client;

  @override
  bool updateShouldNotify(_RosScope oldWidget) => oldWidget.client != client;
}

/// Rebuilds as the connection state changes.
///
/// ```dart
/// RosConnectionBuilder(
///   builder: (context, state) => switch (state) {
///     RosConnectionState.connected => const RobotView(),
///     RosConnectionState.reconnecting => const Text('Reconnecting…'),
///     _ => const Text('Offline'),
///   },
/// )
/// ```
class RosConnectionBuilder extends StatelessWidget {
  const RosConnectionBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, RosConnectionState state) builder;

  @override
  Widget build(BuildContext context) {
    final client = RosConnection.of(context);
    return StreamBuilder<RosConnectionState>(
      stream: client.states,
      initialData: client.state,
      builder: (context, snapshot) =>
          builder(context, snapshot.data ?? RosConnectionState.disconnected),
    );
  }
}
