#!/usr/bin/env bash
# Subsets the app's Poppins TTFs to Latin and converts them to WOFF2.
# Run once; the output is committed. Requires: python3 -m pip install --user fonttools brotli
set -euo pipefail

SRC="/Users/kamilboksa/Projects/GymNotes/node_modules/@expo-google-fonts/poppins"
OUT="$(cd "$(dirname "$0")/.." && pwd)/assets/fonts"
UNICODES="U+0000-00FF,U+2018,U+2019,U+201C,U+201D,U+2013,U+2014,U+2026,U+00D7"

mkdir -p "$OUT"

subset() {
  local dir="$1" weight="$2"
  python3 -m fontTools.subset "$SRC/$dir/Poppins_$dir.ttf" \
    --unicodes="$UNICODES" \
    --layout-features='kern,liga' \
    --flavor=woff2 \
    --output-file="$OUT/poppins-$weight.woff2"
  echo "wrote $OUT/poppins-$weight.woff2 ($(du -h "$OUT/poppins-$weight.woff2" | cut -f1))"
}

subset 400Regular 400
subset 600SemiBold 600
subset 700Bold 700
