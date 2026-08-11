# Plateau — marketing site

Static site for the Plateau strength tracker. No build step: open `index.html`,
or serve the folder.

## Local preview

    python3 -m http.server 8000
    open http://localhost:8000

## Checks

    python3 tools/check.py

Guards against false marketing claims, broken internal links, missing alt text,
and malformed page metadata. CI runs it on every push.

Rules worth knowing before you edit copy:

- **Pre-launch wording fails the build.** `coming soon`, `notify me`,
  `at launch`, `waitlist` and `pre-launch` are matched against the page's
  rendered text, so splitting one across tags (`Coming <b>soon</b>`) does not
  get past it. Whole phrases are matched deliberately: the heading "See the
  plateau coming." and the "Coming to Pro" group label are product copy and
  must keep working.
- **The store links are required.** `index.html` must link to both
  `apps.apple.com` and `play.google.com`. Removing the download path fails the
  build rather than shipping a page with nowhere to go.
- **Unbuilt features must be labelled.** Anything matching `csv` or `export`
  may appear only inside an element carrying `data-status="coming"`. CSV Export
  is still on the roadmap; when it ships, drop both the attribute and the
  `UNSHIPPED_WORDS` entry.

## Deploying

The site publishes from `main` via GitHub Actions
(`.github/workflows/pages.yml`) to
[`https://getplateau.app/`](https://getplateau.app/).
Every push to `main` runs `tools/check.py` as a gate before the deploy job
runs, so a push that would publish a false claim fails before it reaches
Pages.

## Maintenance

**Prices.** Two places hard-code the $4.99 / $29.99 Pro prices, both wrapped in
`<!-- PRICES … -->` fence comments so they are easy to find: the visible cards
in `index.html`'s `#pricing` section, and the `offers` array in the JSON-LD
block in the `<head>`. They are still a market assumption — reconcile them
against the live RevenueCat products.

**Store badges.** `assets/img/badge-app-store.svg` and
`assets/img/badge-google-play.png` are the official artwork from Apple and
Google, committed unmodified as both vendors' guidelines require. Google's PNG
bakes its mandated clear space into the canvas, which is why the two are given
different CSS heights — a 1.4881 ratio — so the visible badges match. The
trademark attribution in the footer is a Google requirement; do not drop it.

**Social card.**

    ./tools/build-og-card.sh

Rebuilds `assets/img/og.png` at 1200×630. Run it whenever the headline or the
availability line changes — `og:image` is what every shared link shows, and
nothing else in the project notices a stale card. The script refuses to leave
a wrongly sized file behind.

**Screenshots.**

    ./tools/capture-screenshots.sh

Requires a booted iOS simulator running the Plateau dev build. See the script
header for the full procedure. Replacements must stay 603×1307 or the
`width`/`height` attributes in `index.html` have to change with them.
