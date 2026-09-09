/// ROS 2 QoS history policy.
///
/// Wire names come from rosbridge's `HistoryPoliciesMapping`; there is no
/// `system_default` mapping, so [systemDefault] is omitted from the wire and
/// the bridge falls back to its own default.
enum History {
  systemDefault(null),
  keepLast('keep_last'),
  keepAll('keep_all');

  const History(this.wireName);
  final String? wireName;
}

/// ROS 2 QoS reliability policy.
enum Reliability {
  systemDefault(null),

  /// Guaranteed delivery, retried until acknowledged. Use for commands.
  reliable('reliable'),

  /// Fire and forget. Use for high-rate sensor streams.
  bestEffort('best_effort');

  const Reliability(this.wireName);
  final String? wireName;
}

/// ROS 2 QoS durability policy.
enum Durability {
  systemDefault(null),

  /// Late-joining subscribers receive the last published message.
  transientLocal('transient_local'),

  /// Only messages published after subscribing are received.
  volatile('volatile');

  const Durability(this.wireName);
  final String? wireName;
}

/// ROS 2 QoS liveliness policy.
/// ROS 2 QoS liveliness policy.
///
/// Note: `rosbridge_suite` 2.0.x ignores liveliness entirely — it is not read
/// by the bridge's QoS extractor. It is sent anyway (unknown keys are safely
/// ignored) so newer bridges can honour it.
enum Liveliness {
  systemDefault(null),
  automatic('automatic'),
  manualByTopic('manual_by_topic');

  const Liveliness(this.wireName);
  final String? wireName;
}

/// A ROS 2 Quality of Service profile.
///
/// QoS is the single most common cause of "my topic works in `ros2 topic echo`
/// but not in my app": a [Reliability.reliable] subscriber will never match a
/// [Reliability.bestEffort] publisher. Prefer the named constructors, which
/// mirror the profiles in `rmw_qos_profiles.h`.
final class QosProfile {
  const QosProfile({
    this.history = History.keepLast,
    this.depth = 10,
    this.reliability = Reliability.reliable,
    this.durability = Durability.volatile,
    this.deadline = Duration.zero,
    this.lifespan = Duration.zero,
    this.liveliness = Liveliness.systemDefault,
    this.livelinessLeaseDuration = Duration.zero,
  });

  /// The rmw default: reliable, volatile, keep-last-10.
  static const QosProfile default_ = QosProfile();

  /// Matches `rclcpp::SensorDataQoS` — best-effort, keep-last-5.
  ///
  /// Required to receive most camera, lidar and IMU topics.
  static const QosProfile sensorData = QosProfile(
    depth: 5,
    reliability: Reliability.bestEffort,
  );

  /// Matches `rclcpp::SystemDefaultsQoS`.
  static const QosProfile systemDefault = QosProfile(
    history: History.systemDefault,
    reliability: Reliability.systemDefault,
    durability: Durability.systemDefault,
  );

  /// Latched: late joiners get the last value. Used by `/robot_description`,
  /// `/map`, and most `*_static` topics.
  static const QosProfile transientLocal = QosProfile(
    depth: 1,
    durability: Durability.transientLocal,
  );

  /// Matches `rclcpp::ServicesQoS`.
  static const QosProfile services = QosProfile();

  final History history;
  final int depth;
  final Reliability reliability;
  final Durability durability;
  final Duration deadline;
  final Duration lifespan;
  final Liveliness liveliness;
  final Duration livelinessLeaseDuration;

  QosProfile copyWith({
    History? history,
    int? depth,
    Reliability? reliability,
    Durability? durability,
    Duration? deadline,
    Duration? lifespan,
    Liveliness? liveliness,
    Duration? livelinessLeaseDuration,
  }) {
    return QosProfile(
      history: history ?? this.history,
      depth: depth ?? this.depth,
      reliability: reliability ?? this.reliability,
      durability: durability ?? this.durability,
      deadline: deadline ?? this.deadline,
      lifespan: lifespan ?? this.lifespan,
      liveliness: liveliness ?? this.liveliness,
      livelinessLeaseDuration:
          livelinessLeaseDuration ?? this.livelinessLeaseDuration,
    );
  }

  /// Serialises to rosbridge's QoS representation.
  ///
  /// The format is fussier than the protocol document suggests, and getting it
  /// wrong fails *silently* — rosbridge accepts the subscribe, delivers
  /// nothing, and reports no error. Verified against rosbridge_suite 2.0.7:
  ///
  ///  * policies are lowercase strings (`"best_effort"`), never enum integers;
  ///  * there is no `system_default` policy name, so those are omitted and the
  ///    bridge applies its own default;
  ///  * durations use `secs`/`nsecs`, not `sec`/`nsec`, and are omitted when
  ///    zero, which means "unset" rather than "zero seconds".
  Map<String, Object?> toWire() {
    final wire = <String, Object?>{'depth': depth};

    final historyName = history.wireName;
    if (historyName != null) wire['history'] = historyName;

    final reliabilityName = reliability.wireName;
    if (reliabilityName != null) wire['reliability'] = reliabilityName;

    final durabilityName = durability.wireName;
    if (durabilityName != null) wire['durability'] = durabilityName;

    final livelinessName = liveliness.wireName;
    if (livelinessName != null) wire['liveliness'] = livelinessName;

    if (deadline > Duration.zero) wire['deadline'] = _duration(deadline);
    if (lifespan > Duration.zero) wire['lifespan'] = _duration(lifespan);
    if (livelinessLeaseDuration > Duration.zero) {
      wire['liveliness_lease_duration'] = _duration(livelinessLeaseDuration);
    }

    return wire;
  }

  static Map<String, Object?> _duration(Duration d) => {
        'secs': d.inSeconds,
        'nsecs': (d.inMicroseconds % Duration.microsecondsPerSecond) * 1000,
      };

  @override
  String toString() => 'QosProfile(${reliability.name}, ${durability.name}, '
      '${history.name}/$depth)';
}
