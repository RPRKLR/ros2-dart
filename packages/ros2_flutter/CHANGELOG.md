# Changelog

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
