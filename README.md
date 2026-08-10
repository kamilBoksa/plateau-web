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

## Deploying

The site publishes from `main` via GitHub Actions
(`.github/workflows/pages.yml`) to
[`https://kamilboksa.github.io/plateau-web/`](https://kamilboksa.github.io/plateau-web/).
Every push to `main` runs `tools/check.py` as a gate before the deploy job
runs, so a push that would publish a false claim fails before it reaches
Pages.

## Before launch — remaining items

**Contact address.** Replace `PLATEAU_CONTACT_EMAIL` with the published
address in all three pages.

This is reported as a `NOTE:` line by `tools/check.py` until resolved.

**Prices.** Two places hard-code the $4.99 / $29.99 Pro prices and both are
wrapped in `<!-- PRICES: reconcile with the RevenueCat products before
launch. -->` fence comments so they're easy to find: the visible pricing
cards in `index.html`'s `#pricing` section, and the `offers` array in the
JSON-LD block in `index.html`'s `<head>`. Reconcile both against the live
RevenueCat products before publishing.

## Regenerating screenshots

    ./tools/capture-screenshots.sh

Requires a booted iOS simulator running the Plateau dev build. See the script
header for the full procedure.
