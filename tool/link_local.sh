#!/usr/bin/env bash
# Points ros2_flutter and ros2_msgs_common at the sibling ros2_client, so the
# three build against each other during development.
#
# These live in pubspec_overrides.yaml rather than a dependency_overrides block
# in pubspec.yaml, because an override in pubspec.yaml has to be removed before
# publishing — the step that is easiest to forget, and the one that would
# publish a package pinned to a path nobody else has.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for pkg in ros2_flutter ros2_msgs_common; do
  cat > "$here/packages/$pkg/pubspec_overrides.yaml" <<'YAML'
# Local development only; gitignored. See tool/link_local.sh
dependency_overrides:
  ros2_client:
    path: ../ros2_client
YAML
  echo "  linked packages/$pkg -> packages/ros2_client"
done
echo "Now run 'dart pub get' (or 'flutter pub get') in each package."
