#!/usr/bin/env bash
# Captures marketing screenshots from a booted simulator running the Plateau
# dev build, then converts them to WebP.
#
# Procedure: seed the database first (see tools/seed-db.sql), then run this and
# navigate to each screen when prompted.
set -euo pipefail

DEVICE="${DEVICE:-A3D42C81-74DE-4705-8B10-D2A2E60F24E2}"   # iPhone 17 Pro
HERE="$(cd "$(dirname "$0")" && pwd)"
RAW="$HERE/.screenshots-raw"
OUT="$HERE/../assets/img"

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
