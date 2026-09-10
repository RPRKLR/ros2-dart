#!/usr/bin/env bash
# Regenerates every library in lib/src/msgs from a sourced ROS 2 install.
#
# The output is committed, so this only needs running when targeting a new ROS
# distro or adding a package to the set. Check the diff: a distro bump can
# change field types and message contents.
#
#   source /opt/ros/humble/setup.bash
#   ./tool/regenerate.sh
set -euo pipefail

if [[ -z "${ROS_DISTRO:-}" ]]; then
  echo "Source a ROS 2 install first: source /opt/ros/humble/setup.bash" >&2
  exit 1
fi

# Requested explicitly. Transitive dependencies (unique_identifier_msgs,
# trajectory_msgs, and the parts of geometry_msgs and std_msgs that ros2_client
# does not already bundle) are pulled in automatically.
PACKAGES=(
  action_msgs
  control_msgs
  diagnostic_msgs
  lifecycle_msgs
  nav2_msgs
  shape_msgs
  tf2_msgs
  visualization_msgs
)

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$here/lib/src/msgs"

echo "Regenerating from ROS $ROS_DISTRO into $out"
rm -f "$out"/*.dart
(cd "$here/../ros2_client" && dart run bin/generate.dart -o "$out" "${PACKAGES[@]}")
dart format "$out" > /dev/null

# One forwarding library per generated package, so users import
# `package:ros2_msgs_common/nav2_msgs.dart` rather than reaching into src/.
for file in "$out"/*.dart; do
  name="$(basename "$file" .dart)"
  [[ "$name" == "generated" ]] && continue
  cat > "$here/lib/$name.dart" <<EOF
/// Generated Dart classes for the ROS 2 \`$name\` package.
///
/// Import this library directly; \`ros2_msgs_common.dart\` deliberately
/// re-exports nothing, because ROS reuses type names across packages.
library;

export 'src/msgs/$name.dart';
EOF
done

echo "Done. Review the diff before committing."
