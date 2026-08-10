#!/usr/bin/env bash
# Captures marketing screenshots from a booted simulator running the Plateau
# dev build, then converts them to WebP.
#
# Procedure: seed the database first (see tools/seed-db.sql), then run this and
# navigate to each screen when prompted.
# Requires: cwebp (brew install webp), xcrun simctl, and a booted simulator
# already running the Plateau dev build.
set -euo pipefail

DEVICE="${DEVICE:-38F5A1C0-1B28-4B7F-B5E0-1E0D8B8B415F}"   # iPhone 16 Plus, 1290x2796
HERE="$(cd "$(dirname "$0")" && pwd)"
RAW="$HERE/.screenshots-raw"
OUT="$HERE/../assets/img"

if ! command -v cwebp >/dev/null 2>&1; then
  echo "error: cwebp not found on PATH (install with: brew install webp)" >&2
  exit 1
fi

if ! xcrun simctl list devices | grep -q "($DEVICE) (Booted)"; then
  echo "error: simulator $DEVICE is not booted — boot it and launch the Plateau dev build first" >&2
  exit 1
fi

mkdir -p "$RAW" "$OUT"

capture() {
  local slug="$1" prompt="$2"
  read -r -p "Navigate to ${prompt}, then press Enter… "
  xcrun simctl io "$DEVICE" screenshot "$RAW/$slug.png"
  # -q 82 keeps text crisp; -resize halves the 3x capture to a sane 2x asset.
  cwebp -quiet -q 82 -resize 603 0 "$RAW/$slug.png" -o "$OUT/shot-$slug.webp"
  echo "  -> $OUT/shot-$slug.webp ($(du -h "$OUT/shot-$slug.webp" | cut -f1))"
}

capture workout   "an active workout with a few sets logged"
capture stats     "Bench Press -> Stats"
capture history   "the History tab, calendar visible"
capture library   "the Exercises tab"
capture templates "the Workout tab showing templates"

echo "Done. Raw PNGs kept in $RAW (git-ignored)."
