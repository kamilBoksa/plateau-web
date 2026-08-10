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

## Before launch — two replacements

1. **Domain.** Replace `https://PLATEAU_SITE_URL` with the real origin (no
   trailing slash) in `index.html`, `privacy.html`, `terms.html`, `sitemap.xml`.
2. **Contact address.** Replace `PLATEAU_CONTACT_EMAIL` with the published
   address in all three pages.

Both are reported as `NOTE:` lines by `tools/check.py` until resolved.

## Regenerating screenshots

    ./tools/capture-screenshots.sh

Requires a booted iOS simulator running the Plateau dev build. See the script
header for the full procedure.
