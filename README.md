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

## Before launch — one remaining replacement

**Contact address.** Replace `PLATEAU_CONTACT_EMAIL` with the published
address in all three pages.

This is reported as a `NOTE:` line by `tools/check.py` until resolved.

## Regenerating screenshots

    ./tools/capture-screenshots.sh

Requires a booted iOS simulator running the Plateau dev build. See the script
header for the full procedure.
