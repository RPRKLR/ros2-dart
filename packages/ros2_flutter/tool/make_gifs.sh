#!/usr/bin/env bash
# Stitches the frame sequences rendered by test/goldens/animation_test.dart
# into the animated GIFs used in the README.
#
#   flutter test --update-goldens test/goldens/animation_test.dart
#   ./tool/make_gifs.sh
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
frames="$here/test/goldens/frames"
out="$here/doc/images"

command -v ffmpeg >/dev/null || { echo "ffmpeg not found" >&2; exit 1; }
[[ -d "$frames" ]] || { echo "No frames; run the golden test first." >&2; exit 1; }
mkdir -p "$out"

# A shared palette per clip keeps the GIF small without banding the gradients.
gif() {
  local name="$1" pattern="$2" fps="$3" width="$4"
  local palette
  palette="$(mktemp -t "palette_${name}_XXXX.png")"
  ffmpeg -loglevel error -y -framerate "$fps" -i "$frames/$pattern" \
    -vf "scale=${width}:-1:flags=lanczos,palettegen=stats_mode=diff" "$palette"
  ffmpeg -loglevel error -y -framerate "$fps" -i "$frames/$pattern" -i "$palette" \
    -lavfi "scale=${width}:-1:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=3" \
    -loop 0 "$out/$name.gif"
  rm -f "$palette"
  echo "  $out/$name.gif  ($(du -h "$out/$name.gif" | cut -f1))"
}

echo "Building GIFs:"
gif laser_scan  'scan_%02d.png'  12 420
gif teleop      'stick_%02d.png' 12 300
