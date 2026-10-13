#!/usr/bin/env bash
# Regenerates one distro's libraries, lib/src/<distro>, from a ROS 2 install.
#
# The output is committed, so this only needs running when a distro's
# definitions change or a package joins the set. Check the diff: a distro bump
# can change field types and message contents.
#
#   source /opt/ros/humble/setup.bash
#   ./tool/regenerate.sh
#
# For a distro that is not installed locally, ./tool/regenerate_in_docker.sh
# takes the definitions from the official ROS image and calls this.
set -euo pipefail

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

if [[ "${1:-}" == "--packages" ]]; then
  printf '%s\n' "${PACKAGES[@]}"
  exit 0
fi

if [[ -z "${ROS_DISTRO:-}" ]]; then
  echo "Source a ROS 2 install first: source /opt/ros/humble/setup.bash" >&2
  exit 1
fi

# Only the distro install, never a sourced workspace.
#
# The generator searches AMENT_PREFIX_PATH in order, and a workspace overlay
# comes first. On a developer machine with a robot workspace sourced, asking
# for a package that the overlay also provides would quietly bake that private
# fork into a package meant for pub.dev. Pinning the search root makes this
# script produce the same output on any machine, which is also what lets the
# committed result be diffed rather than trusted.
#
# ROS_DISTRO_ROOT exists for regenerate_in_docker.sh, which hands over an
# untouched copy of an official image's /opt/ros/<distro>.
distro_root="${ROS_DISTRO_ROOT:-/opt/ros/$ROS_DISTRO}"
if [[ ! -d "$distro_root/share" ]]; then
  echo "No $distro_root/share -- expected a system ROS install." >&2
  exit 1
fi
export AMENT_PREFIX_PATH="$distro_root"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$here/lib/src/$ROS_DISTRO"

echo "Regenerating from ROS $ROS_DISTRO ($distro_root) into $out"
mkdir -p "$out"
rm -f "$out"/*.dart
(cd "$here/../ros2_client" && dart run bin/generate.dart -o "$out" "${PACKAGES[@]}")
dart format "$out" > /dev/null

# One forwarding library per generated package, so users import
# `package:ros2_msgs_common/jazzy/nav2_msgs.dart` rather than reaching into
# src/. The distro directory is rebuilt, so a package a distro stops pulling
# in does not leave a stale library behind.
rm -rf "$here/lib/$ROS_DISTRO"
mkdir -p "$here/lib/$ROS_DISTRO"
for file in "$out"/*.dart; do
  name="$(basename "$file" .dart)"
  [[ "$name" == "generated" ]] && continue
  cat > "$here/lib/$ROS_DISTRO/$name.dart" <<EOF
/// Generated Dart classes for the ROS 2 \`$name\` package, as of ROS 2
/// ${ROS_DISTRO^}.
///
/// Import this library directly; \`ros2_msgs_common.dart\` deliberately
/// re-exports nothing, because ROS reuses type names across packages.
library;

export '../src/$ROS_DISTRO/$name.dart';
EOF
done

# Fail loudly rather than shipping something that came from elsewhere.
if grep -rlq "$HOME" "$out"/*.dart 2>/dev/null; then
  echo "A generated file references a path under \$HOME; refusing." >&2
  exit 1
fi

echo "Done. Review the diff before committing."
echo "Every package above should have resolved under $distro_root."
