# Changelog

## 0.4.0

Requires `ros2_client` 0.4.0.

**New: a goal picker on `RosMapView`.** Give it `onGoal` and a long press
places a goal on the map; dragging before letting go aims it, as RViz's
"2D Goal Pose" does. It is a long press because a plain drag already pans.
The view sends nothing itself: `onGoal` receives a `PoseStamped` in the map
frame, stamped zero so tf2 and Nav2 read it as "latest", and the app decides
what to do with it. `goal` draws one, typically the last pick, while the robot
drives there. A press with no drag faces away from the robot, as if it drove
straight there. Picking works on a panned and zoomed map, the goal stays
where it was pressed if the map is republished mid-press (as SLAM does), the
preview shows the heading that will be sent, and a press off the map picks
nothing.

**New: `RosDiagnosticsPanel`**, the robot's health from `/diagnostics`, worst
first. Each node publishes only its own statuses there, so the panel keeps
every component it has heard from, replaces each as it reports again, and
marks one stale once it has been silent for `staleAfter` (5 s): a dead node
otherwise looks like its last, healthy report. It takes a plain model,
`RosDiagnosticEntry` and `RosDiagnosticLevel`, so this package still depends
on `ros2_client` alone; with `ros2_msgs_common` the adapter from
`DiagnosticArray` is one expression, shown in its documentation. They carry a
`Ros` prefix because Flutter's foundation library already exports a
`DiagnosticLevel`.

**The example** now has Navigate and Health tabs: a long press on the map
sends a Nav2 `NavigateToPose` goal, with progress, cancel, the reason Nav2
gives when it aborts, and a costmap reset; and the diagnostics panel.

* The pubspec description now mentions `RosMapView`.
* Still built on `package:flutter/material.dart`, which Flutter 3.50
  deprecates for `package:material_ui`. The two are separate copies: a
  `material_ui` widget in an app on `flutter/material.dart` ignores the app's
  theme and throws "No Material widget found", and the reverse holds too. Most
  apps are still on `flutter/material.dart`, so this package stays there until
  they move; the deprecation is silenced import by import, and nothing else
  is.

## 0.3.0

Requires `ros2_client` 0.3.0.

**New: `RosMapView`** — a `nav_msgs/OccupancyGrid` with pan and zoom, and
the robot placed on it from tf. The grid becomes an image once per map
message, so panning a large map costs a textured quad per frame rather than
a walk over every cell. It subscribes `transient_local`, so a view opened
after `map_server` published still gets the map; verified against rosbridge
2.0.8 with `ros2_client`'s `example/real_map_check.dart`.

**Fixed**

* Swapping `RosConnection` to another robot mid-drive left the old one
  moving and drove the new one. The old client was closed before the teleop
  widgets could send it a stop, and their repeat timer carried the held
  command over. The old client now closes after its dependants rebind, and a
  teleop widget stops and waits for a fresh press when its robot changes.
* `TeleopJoystick` and `TeleopPad` kept publishing a held command while the
  app was in the background, unless the platform happened to cancel the
  pointer. Both now stop when the app leaves the foreground.
* `TeleopPad` stopped the robot when any finger lifted, even with another
  button still held. The most recent press now drives, and the robot stops
  when no button is held.
* `RosTopicBuilder` kept showing the old topic's last message after its topic
  or client changed, as if it were current. So did the camera and lidar views
  built on it.
* `RosRawImageView` ignored `step`, so an image with padded rows drew skewed.
  It now also shows `bgra8`, `mono16`, `16UC1` and `32FC1` (depth stretched to
  grey), and says why it cannot show a frame instead of spinning forever.
* `RosLaserScanView` plotted readings outside the scan's own `range_min` and
  `range_max`, which the message defines as invalid; below `range_min` they
  drew a ring of junk around the robot.
* A `publishRate` changed while the joystick or pad was held took effect
  only after release.
* The battery snippet in the README, tutorial and example threw on a robot
  that reports its charge as NaN, which many do when they cannot measure it.

## 0.2.0

Requires `ros2_client` 0.2.0.

**New: `RosConnectionStatus`** — a status dot and label that counts down to
the next reconnect attempt. Every robot UI grows one of these, and the part
worth sharing is the countdown: the backoff doubles, so a bare "Reconnecting…"
leaves an operator unable to tell a retry a second away from one half a minute
away. Its ticker runs only while a retry is pending, and counts down by ticks
rather than by wall clock, so a device picking up NTP does not make the robot
look further away. The example app's hand-rolled connection chip is now this
widget.

The example app also has platform directories again, so `flutter run` works on
a fresh clone without `flutter create .` first.

**A runaway-robot fix, and the reason for the minor bump.** The teleop widgets
buffered motion commands while the link was down and replayed them on
reconnect — so a stalled link meant the robot was handed seconds of stale
motion *after* the operator had let go, with the stop command dropped because
the buffer was full. They now advertise `perishable: true`, which discards
instead of queueing.

They also never rebound: swapping `topic` kept driving the old robot while the
UI named the new one, and swapping the client left the stick publishing into a
closed one, which drops silently. Both rebind now, and the robot being left
behind gets a stop.

`RosTopicBuilder` defaults to `Backpressure.latest`: a widget draws the newest
value and nothing else, so messages arriving faster than it rebuilds are
dropped *before* being decoded. Pass `Backpressure.buffer` if you are
accumulating rather than displaying.

`RosCameraView` no longer fills the global `ImageCache` with video frames — at
10 fps of 640x480 the 100 MB budget was gone in about eight seconds, evicting
every other image the app had cached. `RosRawImageView` no longer re-decodes
the same retained frame every vsync. `RosConnection` honours
`closeClientOnDispose` when swapping clients. `RosTopicBuilder` reacts to a
changed `compression`, and no longer calls `onError` during build.

New: `TfFrameBuilder`, which resolves a tf transform for the widget's lifetime
and shares one listener across the whole tree.


## 0.1.0

Initial release.

- `RosConnection` / `RosConnection.withClient` with app-resume reconnection
- `RosConnectionBuilder` and `RosTopicBuilder<T>` with lifecycle-scoped
  subscriptions
- `RosCameraView` and `RosRawImageView` (rgb8/bgr8/mono8/rgba8)
- `RosLaserScanView` lidar plot
- `TeleopJoystick` and `TeleopPad`, both fail-safe on release and dispose
