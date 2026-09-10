import '../messages/geometry_msgs.dart';
import '../messages/std_msgs.dart';
import 'transform_math.dart';

/// Thrown when a transform cannot be resolved.
final class TfException implements Exception {
  TfException(this.message);
  final String message;

  @override
  String toString() => 'TfException: $message';
}

/// One timestamped sample of a frame's transform relative to its parent.
final class _Sample {
  const _Sample(this.stampMicros, this.transform);

  /// Microseconds since epoch. Deliberately not nanoseconds: `sec * 1e9`
  /// exceeds 2^53 for real epoch times and would lose precision on the web,
  /// where Dart ints are doubles.
  final int stampMicros;
  final RosTransform transform;
}

/// History of one frame relative to its parent.
final class _FrameHistory {
  _FrameHistory(this.parent);

  String parent;

  /// Ascending by timestamp.
  final List<_Sample> samples = [];

  /// Set for `/tf_static`, which is latched and valid at any time.
  RosTransform? staticTransform;

  bool get isStatic => staticTransform != null;

  /// Consecutive samples rejected for being implausibly far ahead.
  int _futureRejects = 0;

  /// How many in a row before the jump is accepted as a real clock change.
  static const int _futureRejectLimit = 10;

  /// Adds a sample, returning false if it was rejected as a clock outlier.
  ///
  /// One sample from a node whose clock is a minute fast would otherwise
  /// anchor the trim window a minute into the future, dropping every good
  /// sample already held *and* every good sample that arrives afterwards —
  /// the buffer never recovers, and the UI silently stops updating with no
  /// diagnostic. Clock skew between a robot and a bridge is routine.
  ///
  /// So a sample more than [cacheTime] ahead of everything held is refused.
  /// If they keep coming, the clock really has moved and the buffer
  /// re-baselines onto it rather than rejecting good data forever.
  bool insert(_Sample sample, Duration cacheTime) {
    if (samples.isNotEmpty &&
        sample.stampMicros - samples.last.stampMicros >
            cacheTime.inMicroseconds) {
      if (++_futureRejects < _futureRejectLimit) return false;
      samples.clear();
    }
    _futureRejects = 0;

    // Usually append; a late-arriving sample needs an ordered insert.
    if (samples.isEmpty || sample.stampMicros >= samples.last.stampMicros) {
      samples.add(sample);
    } else {
      var i = samples.length - 1;
      while (i > 0 && samples[i - 1].stampMicros > sample.stampMicros) {
        i--;
      }
      samples.insert(i, sample);
    }

    final cutoff = samples.last.stampMicros - cacheTime.inMicroseconds;
    var drop = 0;
    while (drop < samples.length - 1 && samples[drop].stampMicros < cutoff) {
      drop++;
    }
    if (drop > 0) samples.removeRange(0, drop);
    return true;
  }

  /// The transform at [micros], interpolating between the bracketing samples.
  ///
  /// Returns `null` if the time lies outside the buffered window by more than
  /// [tolerance].
  RosTransform? at(int? micros, Duration tolerance) {
    final staticValue = staticTransform;
    // Dynamic samples win when there are any. A frame published on both /tf
    // and /tf_static is a robot-side mistake, but answering from the latched
    // value while live data sits unread in the buffer is the dangerous way to
    // resolve it: the marker stops moving and nothing says why.
    if (samples.isEmpty) return staticValue;
    final dynamicValue = _dynamicAt(micros, tolerance);
    return dynamicValue ?? staticValue;
  }

  RosTransform? _dynamicAt(int? micros, Duration tolerance) {
    if (samples.isEmpty) return null;

    // A null or zero stamp means "latest available", matching tf2.
    if (micros == null || micros == 0) return samples.last.transform;

    final toleranceMicros = tolerance.inMicroseconds;
    if (micros >= samples.last.stampMicros) {
      return micros - samples.last.stampMicros <= toleranceMicros
          ? samples.last.transform
          : null;
    }
    if (micros <= samples.first.stampMicros) {
      return samples.first.stampMicros - micros <= toleranceMicros
          ? samples.first.transform
          : null;
    }

    var low = 0;
    var high = samples.length - 1;
    while (high - low > 1) {
      final mid = (low + high) ~/ 2;
      if (samples[mid].stampMicros <= micros) {
        low = mid;
      } else {
        high = mid;
      }
    }

    final before = samples[low];
    final after = samples[high];
    final span = after.stampMicros - before.stampMicros;
    if (span <= 0) return before.transform;

    final t = (micros - before.stampMicros) / span;
    return before.transform.lerpTo(after.transform, t);
  }
}

/// A tf2 transform buffer: stores the frame tree and answers lookups.
///
/// This is the pure-Dart core with no ROS coupling, so it can be unit tested
/// and driven from a bag file as easily as from a live robot. Use `TfListener`
/// to feed it from `/tf` and `/tf_static`.
final class TfBuffer {
  TfBuffer({
    this.cacheTime = const Duration(seconds: 10),
    this.tolerance = const Duration(milliseconds: 100),
  });

  /// How much history to retain per frame.
  final Duration cacheTime;

  /// How far outside the buffered window a lookup may reach before failing.
  final Duration tolerance;

  final Map<String, _FrameHistory> _frames = {};

  /// Records a transform. [isStatic] marks it as latched, valid at any time.
  void setTransform(RosTransformStamped stamped, {bool isStatic = false}) {
    final child = _strip(stamped.childFrameId);
    final parent = _strip(stamped.header.frameId);
    if (child.isEmpty || parent.isEmpty || child == parent) return;

    final history = _frames.putIfAbsent(child, () => _FrameHistory(parent));
    // A frame can be re-parented at runtime; the old history no longer applies.
    if (history.parent != parent) {
      history.parent = parent;
      history.samples.clear();
      history.staticTransform = null;
    }

    if (isStatic) {
      history.staticTransform = stamped.transform;
      return;
    }
    history.insert(
      _Sample(
          stamped.header.stamp.sinceEpoch.inMicroseconds, stamped.transform),
      cacheTime,
    );
  }

  /// The transform mapping points from [sourceFrame] into [targetFrame], or
  /// `null` if it cannot be resolved.
  ///
  /// [time] defaults to the latest available. Prefer [lookupOrThrow] when you
  /// want to know *why* a lookup failed.
  RosTransform? lookup(String targetFrame, String sourceFrame,
      {RosTime? time}) {
    try {
      return lookupOrThrow(targetFrame, sourceFrame, time: time);
    } on TfException {
      return null;
    }
  }

  /// As [lookup], but throws [TfException] describing the failure.
  RosTransform lookupOrThrow(String targetFrame, String sourceFrame,
      {RosTime? time}) {
    final target = _strip(targetFrame);
    final source = _strip(sourceFrame);
    final micros = time?.sinceEpoch.inMicroseconds;

    if (target == source) return TransformMath.identity;

    final sourceChain = _ancestry(source);
    final targetChain = _ancestry(target);

    if (sourceChain.length == 1 &&
        !_frames.containsKey(source) &&
        !_isKnownParent(source)) {
      throw TfException('Frame "$source" does not exist in the tf tree. '
          'Known frames: ${frames.join(', ')}');
    }
    if (targetChain.length == 1 &&
        !_frames.containsKey(target) &&
        !_isKnownParent(target)) {
      throw TfException('Frame "$target" does not exist in the tf tree. '
          'Known frames: ${frames.join(', ')}');
    }

    final targetIndex = <String, int>{
      for (var i = 0; i < targetChain.length; i++) targetChain[i]: i,
    };

    var lcaInSource = -1;
    var lcaInTarget = -1;
    for (var i = 0; i < sourceChain.length; i++) {
      final index = targetIndex[sourceChain[i]];
      if (index != null) {
        lcaInSource = i;
        lcaInTarget = index;
        break;
      }
    }

    if (lcaInSource < 0) {
      throw TfException('"$source" and "$target" are in disconnected tf trees '
          '(roots "${sourceChain.last}" and "${targetChain.last}")');
    }

    final lcaToSource = _composeDown(sourceChain, lcaInSource, micros);
    final lcaToTarget = _composeDown(targetChain, lcaInTarget, micros);
    return lcaToTarget.inverse.compose(lcaToSource);
  }

  /// Whether [lookup] would succeed.
  bool canTransform(String targetFrame, String sourceFrame, {RosTime? time}) =>
      lookup(targetFrame, sourceFrame, time: time) != null;

  /// Maps a point from [sourceFrame] into [targetFrame].
  Point? transformPoint(Point point, String targetFrame, String sourceFrame,
          {RosTime? time}) =>
      lookup(targetFrame, sourceFrame, time: time)?.transformPoint(point);

  /// Maps a pose from [sourceFrame] into [targetFrame].
  Pose? transformPose(Pose pose, String targetFrame, String sourceFrame,
          {RosTime? time}) =>
      lookup(targetFrame, sourceFrame, time: time)?.transformPose(pose);

  /// Every frame the buffer knows about, parents included.
  Set<String> get frames => {
        for (final entry in _frames.entries) ...[entry.key, entry.value.parent],
      };

  /// The parent of [frame], or `null` if it is a root or unknown.
  String? parentOf(String frame) => _frames[_strip(frame)]?.parent;

  /// Roots of the tf forest — frames that are never a child.
  Set<String> get rootFrames =>
      frames.where((f) => !_frames.containsKey(f)).toSet();

  /// A readable rendering of the frame tree, for diagnostics.
  String describe() {
    final buffer = StringBuffer();
    for (final root in rootFrames) {
      buffer.writeln(root);
      _describeChildren(buffer, root, '  ');
    }
    return buffer.toString();
  }

  void _describeChildren(StringBuffer out, String parent, String indent) {
    for (final entry in _frames.entries) {
      if (entry.value.parent != parent) continue;
      final kind = entry.value.isStatic
          ? 'static'
          : '${entry.value.samples.length} samples';
      out.writeln('$indent${entry.key}  ($kind)');
      _describeChildren(out, entry.key, '$indent  ');
    }
  }

  void clear() => _frames.clear();

  bool _isKnownParent(String frame) =>
      _frames.values.any((h) => h.parent == frame);

  /// [frame, parent, ..., root].
  ///
  /// Throws [TfException] on a cycle. Truncating at the repeat instead would
  /// let each direction resolve through a different edge, so `lookup(a, b)`
  /// and `lookup(b, a)` disagree and a round trip does not return to where it
  /// started — a marker placed confidently in the wrong spot. A cycle means
  /// the tf tree is broken; saying so is the only honest answer.
  List<String> _ancestry(String frame) {
    final chain = <String>[frame];
    final seen = <String>{frame};
    var current = frame;
    while (true) {
      final history = _frames[current];
      if (history == null) break;
      final parent = history.parent;
      if (!seen.add(parent)) {
        throw TfException(
            'The tf tree contains a cycle: ${[...chain, parent].join(' -> ')}. '
            'Two publishers are probably claiming the same child frame.');
      }
      chain.add(parent);
      current = parent;
    }
    return chain;
  }

  /// Composes from `chain[lcaIndex]` down to `chain[0]`.
  RosTransform _composeDown(List<String> chain, int lcaIndex, int? micros) {
    var result = TransformMath.identity;
    for (var i = lcaIndex - 1; i >= 0; i--) {
      final frame = chain[i];
      final history = _frames[frame]!;
      final transform = history.at(micros, tolerance);
      if (transform == null) {
        throw TfException(
            'No transform for "$frame" at the requested time; buffer holds '
            '${history.samples.length} samples over '
            '${_windowDescription(history)}');
      }
      result = result.compose(transform);
    }
    return result;
  }

  static String _windowDescription(_FrameHistory history) {
    if (history.isStatic) return 'a static transform';
    if (history.samples.isEmpty) return 'no samples';
    final span =
        history.samples.last.stampMicros - history.samples.first.stampMicros;
    return '${(span / 1e6).toStringAsFixed(2)} s';
  }

  /// tf2 treats "/odom" and "odom" as the same frame.
  ///
  /// Public because everything comparing frame names has to agree with the
  /// buffer, and a helper that only the buffer could reach is how `TfListener`
  /// ended up with a name check the buffer disagreed with.
  static String normaliseFrame(String frame) =>
      frame.startsWith('/') ? frame.substring(1) : frame;

  static String _strip(String frame) => normaliseFrame(frame);
}
