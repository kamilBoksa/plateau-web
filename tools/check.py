#!/usr/bin/env python3
"""Content guard for the Plateau marketing site.

Fails on false marketing claims, broken internal links, missing alt text,
and malformed page metadata. Standard library only — no dependencies.
"""
import re
import sys
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PAGES = ["index.html", "privacy.html", "terms.html"]

# Every file that can carry a placeholder token — a superset of PAGES.
# sitemap.xml and robots.txt are not HTML, so they must stay out of PAGES
# (PageParser would choke on them), but they still need the token scan below.
TOKEN_SCAN_FILES = PAGES + ["sitemap.xml", "robots.txt"]

# Claims that must never reach production.
FORBIDDEN = {
    "700+": "the library holds 72 exercises, not 700+",
    "example.com": "placeholder legal link",
    "lorem ipsum": "placeholder copy",
    "TODO": "unfinished content",
}

# Features that are not built yet. Each may appear only inside an element
# carrying data-status="coming".
UNSHIPPED = ["CSV Export"]

# Intentional placeholders, resolved at launch and documented in the README.
ALLOWED_TOKENS = ["PLATEAU_SITE_URL", "PLATEAU_CONTACT_EMAIL"]

# Void elements never produce an end tag, so they must not be pushed onto the
# nesting stack — doing so desynchronises it on the first <img> in a block.
VOID = {"area", "base", "br", "col", "embed", "hr", "img", "input",
        "link", "meta", "param", "source", "track", "wbr"}


class PageParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.h1_count = 0
        self.title_count = 0
        self.has_description = False
        self.images = []          # (src, alt)
        self.local_links = []     # href/src values pointing inside the repo
        self.coming_depth = 0
        self.coming_text = []
        self._in_title = False
        self._open_coming = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "h1":
            self.h1_count += 1
        if tag == "title":
            self.title_count += 1
            self._in_title = True
        if tag == "meta" and attrs.get("name") == "description":
            self.has_description = bool(attrs.get("content", "").strip())
        if tag == "img":
            self.images.append((attrs.get("src", ""), attrs.get("alt")))
        for key in ("href", "src"):
            value = attrs.get(key, "")
            if value and not value.startswith(("http://", "https://", "mailto:", "#", "data:")):
                self.local_links.append(value)
        if tag in VOID:
            return
        if attrs.get("data-status") == "coming":
            self.coming_depth += 1
            self._open_coming.append(tag)
        elif self.coming_depth:
            self._open_coming.append(None)

    def handle_endtag(self, tag):
        if tag == "title":
            self._in_title = False
        if self._open_coming:
            marker = self._open_coming.pop()
            if marker is not None:
                self.coming_depth -= 1

    def handle_data(self, data):
        if self.coming_depth:
            self.coming_text.append(data)


def check_page(name, failures):
    path = ROOT / name
    if not path.exists():
        failures.append(f"{name}: file is missing")
        return

    raw = path.read_text(encoding="utf-8")
    haystack = raw.lower()

    for needle, reason in FORBIDDEN.items():
        if needle.lower() in haystack:
            failures.append(f"{name}: contains {needle!r} — {reason}")

    parser = PageParser()
    parser.feed(raw)

    if parser.h1_count != 1:
        failures.append(f"{name}: expected exactly one <h1>, found {parser.h1_count}")
    if parser.title_count != 1:
        failures.append(f"{name}: expected exactly one <title>, found {parser.title_count}")
    if not parser.has_description:
        failures.append(f"{name}: missing a non-empty meta description")

    for src, alt in parser.images:
        if not (alt or "").strip():
            failures.append(f"{name}: <img src={src!r}> has no alt text")

    for link in parser.local_links:
        target = (ROOT / link.split("#")[0].split("?")[0]).resolve()
        if not target.exists():
            failures.append(f"{name}: link {link!r} does not resolve")

    coming_blob = " ".join(parser.coming_text)
    for feature in UNSHIPPED:
        occurrences = len(re.findall(re.escape(feature), raw))
        labelled = len(re.findall(re.escape(feature), coming_blob))
        if occurrences > labelled:
            failures.append(
                f'{name}: {feature!r} appears outside an element with '
                f'data-status="coming" — it is not built yet'
            )


def main():
    failures = []
    for name in PAGES:
        if (ROOT / name).exists() or name == "index.html":
            check_page(name, failures)

    for token in ALLOWED_TOKENS:
        hits = sum(
            1 for name in TOKEN_SCAN_FILES
            if (ROOT / name).exists() and token in (ROOT / name).read_text(encoding="utf-8")
        )
        if hits:
            print(f"NOTE: {token} still present in {hits} page(s) — replace before launch")

    for failure in failures:
        print(f"FAIL: {failure}")
    print(f"\n{len(failures)} failure(s)")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
