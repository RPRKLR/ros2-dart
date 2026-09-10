# Changelog

## 0.1.0

Initial release.

- `RosConnection` / `RosConnection.withClient` with app-resume reconnection
- `RosConnectionBuilder` and `RosTopicBuilder<T>` with lifecycle-scoped
  subscriptions
- `RosCameraView` and `RosRawImageView` (rgb8/bgr8/mono8/rgba8)
- `RosLaserScanView` lidar plot
- `TeleopJoystick` and `TeleopPad`, both fail-safe on release and dispose
