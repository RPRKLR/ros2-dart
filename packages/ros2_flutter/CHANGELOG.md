# Changelog

## 0.2.0 (unreleased)

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
