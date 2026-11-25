// Sending a Nav2 goal picked on the map, and showing how it went.
import 'dart:async';

// Deprecated in Flutter 3.50 for package:material_ui, a separate copy whose
// widgets lose the theme and Material of apps still on this import.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:ros2_flutter/ros2_flutter.dart';
// One distro per app: match your robot's. The goal is the same on Humble,
// Jazzy and Lyrical, but only Jazzy and later say why a navigation failed,
// and Lyrical's costmap services take a `plugins` list the others refuse.
// Register the same distro in main().
import 'package:ros2_msgs_common/lyrical/nav2_msgs.dart' as nav2;

enum NavigationPhase { idle, navigating, succeeded, failed }

/// One robot's navigation: the goal it was sent, its progress, and how it
/// ended.
///
/// Owned above the app's tabs, so switching tabs does not forget a goal the
/// robot is still driving to. Disposing it cancels that goal: a session is
/// disposed when the app moves to another robot, and nothing would be left
/// to show the old robot's progress or stop it.
class NavigationSession extends ChangeNotifier {
  NavigationSession(this.client, {this.action = '/navigate_to_pose'});

  final Ros2Client client;
  final String action;

  NavigationPhase phase = NavigationPhase.idle;

  /// The goal being driven to, shown on the map until it is reached.
  PoseStamped? goal;
  nav2.NavigateToPoseFeedback? feedback;

  /// Why the last goal failed, worded for the operator.
  String? failure;

  GoalHandle<nav2.NavigateToPoseFeedback, nav2.NavigateToPoseResult>? _handle;
  StreamSubscription<nav2.NavigateToPoseFeedback>? _feedback;

  void navigateTo(PoseStamped pose) {
    // No cancel first: Nav2 preempts a running goal with a new one, and the
    // old handle's result is ignored below because it is no longer current.
    final handle = client.sendGoal<nav2.NavigateToPoseGoal,
        nav2.NavigateToPoseFeedback, nav2.NavigateToPoseResult>(
      action,
      nav2.NavigateToPoseGoal(pose: pose),
    );
    _handle = handle;
    goal = pose;
    phase = NavigationPhase.navigating;
    feedback = null;
    failure = null;
    notifyListeners();

    unawaited(_feedback?.cancel());
    _feedback = handle.feedback.listen((f) {
      if (!identical(_handle, handle)) return;
      feedback = f;
      notifyListeners();
    });
    handle.result.then((_) {
      if (!identical(_handle, handle)) return;
      phase = NavigationPhase.succeeded;
      goal = null;
      notifyListeners();
    }, onError: (Object e) {
      if (!identical(_handle, handle)) return;
      phase = NavigationPhase.failed;
      failure = describeFailure(e);
      // A lost link does not stop the robot, so keep showing where it is
      // going.
      if (e is! ActionFailedException || e.status != GoalStatus.unknown) {
        goal = null;
      }
      notifyListeners();
    });
  }

  void cancel() => _handle?.cancel();

  /// Clears both of Nav2's costmaps, the usual first step when the robot is
  /// stuck behind an obstacle that has gone. Returns a line for the operator.
  Future<String> clearCostmaps() async {
    const services = {
      'global': '/global_costmap/clear_entirely_global_costmap',
      'local': '/local_costmap/clear_entirely_local_costmap',
    };
    final outcomes = await Future.wait([
      for (final MapEntry(key: name, value: service) in services.entries)
        client
            .callService<nav2.ClearEntireCostmapRequest,
                nav2.ClearEntireCostmapResponse>(
              service,
              // No plugins named: every layer.
              nav2.ClearEntireCostmapRequest(),
              timeout: const Duration(seconds: 5),
            )
            .then((r) => r.success ? null : '$name refused',
                onError: (Object e) => '$name failed: $e'),
    ]);
    final problems = outcomes.whereType<String>().toList();
    return problems.isEmpty ? 'Costmaps cleared' : problems.join('; ');
  }

  @override
  void dispose() {
    // Forgotten before it is cancelled, so the result the cancel provokes is
    // no longer current and does not notify a disposed session.
    final handle = _handle;
    _handle = null;
    handle?.cancel();
    unawaited(_feedback?.cancel());
    super.dispose();
  }
}

/// Words an [ActionFailedException] from `NavigateToPose` for the operator.
String describeFailure(Object error) {
  if (error is! ActionFailedException) return '$error';
  final result = error.result;
  return switch (error.status) {
    GoalStatus.canceled => 'Cancelled',
    // Nav2 on Jazzy and later reports the reason in the aborted result.
    GoalStatus.aborted
        when result is nav2.NavigateToPoseResult &&
            (result.errorCode != 0 || result.errorMsg.isNotEmpty) =>
      'Nav2 gave up: '
          '${result.errorMsg.isEmpty ? 'no message' : result.errorMsg} '
          '(error ${result.errorCode})',
    GoalStatus.aborted => 'Nav2 gave up, without saying why',
    // Not a verdict from the robot: the app lost track of the goal.
    GoalStatus.unknown => '${error.message}. The robot may still be driving '
        'to the goal.',
    _ => '${error.status.name}: ${error.message}',
  };
}

/// The map, a long press to send the robot somewhere, and its progress.
class NavigatePage extends StatelessWidget {
  const NavigatePage({required this.session, super.key});

  final NavigationSession session;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) => Column(
        children: [
          Expanded(
            child: RosMapView(
              goal: session.goal,
              onGoal: session.navigateTo,
            ),
          ),
          _Progress(session: session),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.session});

  final NavigationSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedback = session.feedback;
    final (icon, text) = switch (session.phase) {
      NavigationPhase.idle => (
          Icons.touch_app,
          'Long-press the map to send the robot there. Drag before letting '
              'go to set the heading.'
        ),
      NavigationPhase.navigating => (
          Icons.navigation,
          feedback == null
              ? 'Goal sent…'
              : '${feedback.distanceRemaining.toStringAsFixed(1)} m to go, '
                  'about ${feedback.estimatedTimeRemaining.sec} s'
                  '${feedback.numberOfRecoveries > 0 ? ', ${feedback.numberOfRecoveries} recoveries' : ''}'
        ),
      NavigationPhase.succeeded => (Icons.flag, 'Arrived'),
      NavigationPhase.failed => (Icons.error_outline, session.failure ?? ''),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Icon(icon,
              color: session.phase == NavigationPhase.failed
                  ? theme.colorScheme.error
                  : null),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          if (session.phase == NavigationPhase.navigating)
            TextButton(onPressed: session.cancel, child: const Text('Cancel')),
          IconButton(
            tooltip: 'Clear costmaps',
            icon: const Icon(Icons.layers_clear),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final outcome = await session.clearCostmaps();
              messenger.showSnackBar(SnackBar(content: Text(outcome)));
            },
          ),
        ],
      ),
    );
  }
}
