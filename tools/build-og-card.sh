#!/usr/bin/env bash
# Renders the OpenGraph/Twitter social card to assets/img/og.png at 1200x630.
# The card is what every shared link shows, so it must be regenerated whenever
# the headline or the availability line changes — nothing else checks it.
#
# Requires: a headless Chrome, or npx (falls back to a Playwright-managed
# Chromium). Fonts are read from assets/fonts/, so run this from a checkout
# with those files present.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
OUT="$ROOT/assets/img/og.png"
SRC="$(mktemp -t plateau-og-XXXXXX).html"
trap 'rm -f "$SRC"' EXIT

cat > "$SRC" <<HTML
<!doctype html><meta charset="utf-8">
<style>
  @font-face { font-family:'Poppins'; src:url('file://$ROOT/assets/fonts/poppins-700.woff2') format('woff2'); font-weight:700; }
  @font-face { font-family:'Poppins'; src:url('file://$ROOT/assets/fonts/poppins-400.woff2') format('woff2'); font-weight:400; }
  html,body{margin:0}
  body{width:1200px;height:630px;background:#0A0A0A;color:#fff;font-family:'Poppins';
       display:flex;flex-direction:column;justify-content:center;padding:0 88px;box-sizing:border-box;position:relative;overflow:hidden}
  body::before{content:'';position:absolute;inset:-30% 40% auto -15%;height:700px;
       background:radial-gradient(closest-side,rgba(66,133,244,.22),transparent)}
  h1{font-size:82px;font-weight:700;letter-spacing:-.02em;line-height:1.05;margin:0 0 24px;position:relative}
  p{font-size:30px;font-weight:400;color:rgba(255,255,255,.55);margin:0;max-width:820px;position:relative}
  .mark{position:relative;font-size:20px;font-weight:700;letter-spacing:.22em;color:#FFD600;margin-bottom:28px}
</style>
<div class="mark">PLATEAU</div>
<h1>Break through<br>the plateau.</h1>
<p>Unlimited workouts, unlimited history, no ads. Free on iPhone and Android.</p>
HTML

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

if [ -x "$CHROME" ]; then
  echo "rendering with Google Chrome"
  "$CHROME" --headless --disable-gpu --screenshot="$OUT" \
    --window-size=1200,630 --default-background-color=0 "file://$SRC"
elif command -v npx >/dev/null 2>&1; then
  echo "Chrome not found; rendering with a Playwright-managed Chromium"
  npx --yes playwright screenshot --viewport-size=1200,630 \
    --wait-for-timeout=400 "file://$SRC" "$OUT"
else
  echo "error: no renderer available. Install Chrome, or Node so npx can fetch Chromium." >&2
  exit 1
fi

# A stale card is worse than a missing one — og:image would keep serving the
# old wording indefinitely, and nothing else in the project would notice.
DIMS="$(sips -g pixelWidth -g pixelHeight "$OUT" | awk '/pixel/{printf "%s ", $2}')"
if [ "$DIMS" != "1200 630 " ]; then
  echo "error: expected 1200x630, got ${DIMS}— refusing to leave a bad card." >&2
  exit 1
fi

echo "wrote $OUT ($(du -h "$OUT" | cut -f1), ${DIMS%% *}x630)"
