#!/usr/bin/env bash
# Regenerates one distro's libraries from the official ROS 2 Docker image, so a
# distro does not have to be installed on this machine.
#
#   ./tool/regenerate_in_docker.sh jazzy
#
# Only the definitions come from the image: its /opt/ros/<distro> is copied out
# untouched and handed to regenerate.sh, which runs the generator here.
set -euo pipefail

distro="${1:?usage: $0 <distro>, e.g. humble or jazzy}"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v docker >/dev/null || { echo "docker not found" >&2; exit 1; }

packages="$("$here/tool/regenerate.sh" --packages)"
apt_packages=()
for pkg in $packages; do
  apt_packages+=("ros-$distro-${pkg//_/-}")
done
[[ ${#apt_packages[@]} -gt 0 ]] || { echo "No packages listed" >&2; exit 1; }

work="$(mktemp -d)"
trap 'rm -rf "$work"; docker rm -f "ros2-msgs-$distro" >/dev/null 2>&1 || true' EXIT

cat > "$work/Dockerfile" <<EOF
FROM ros:$distro-ros-base
RUN apt-get update \\
 && apt-get install -y --no-install-recommends ${apt_packages[*]} \\
 && rm -rf /var/lib/apt/lists/*
EOF
echo "Building ros:$distro-ros-base with ${apt_packages[*]}"
docker build -q -t "ros2-msgs-$distro" "$work" > /dev/null

docker create --name "ros2-msgs-$distro" "ros2-msgs-$distro" > /dev/null
mkdir -p "$work/root"
docker cp -q "ros2-msgs-$distro:/opt/ros/$distro/share" "$work/root/"

ROS_DISTRO="$distro" ROS_DISTRO_ROOT="$work/root" "$here/tool/regenerate.sh"
