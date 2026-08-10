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

# Words naming features that are not built yet. Matched case-insensitively,
# as whole words, against the page's rendered text (markup stripped) — not
# against raw HTML, so inline tags splitting a phrase (e.g. "CSV <b>Export</b>")
# can't slip past. Each may appear only inside an element carrying
# data-status="coming".
UNSHIPPED_WORDS = ["csv", "export"]

# Intentional placeholders, resolved at launch and documented in the README.
ALLOWED_TOKENS = ["PLATEAU_CONTACT_EMAIL"]

# Void elements never produce an end tag, so they must not be pushed onto the
# nesting stack — doing so desynchronises it on the first <img> in a block.
VOID = {"area", "base", "br", "col", "embed", "hr", "img", "input",
        "link", "meta", "param", "source", "track", "wbr"}


class PageParser(HTMLParser):
    """Extracts structural facts plus a text-only view of the page.

    Every open element tracks two inherited booleans on parallel stacks:
    whether it (or an ancestor) carries data-status="coming", and whether
    it (or an ancestor) is a <script>/<style> element whose contents are
    not prose. Text nodes are recorded together with the "coming" flag in
    effect at that point, so unshipped-feature matching can run against
    rendered text — immune to markup splitting a phrase apart — while
    still respecting the data-status="coming" allowance exactly.
    """

    def __init__(self):
        super().__init__()
        self.h1_count = 0
        self.title_count = 0
        self.has_description = False
        self.images = []          # (src, alt)
        self.local_links = []     # href/src values pointing inside the repo
        self.text_chunks = []     # (text, in_coming) for every text node
        self._in_title = False
        self._coming_stack = []
        self._skip_stack = []

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
        parent_coming = self._coming_stack[-1] if self._coming_stack else False
        parent_skip = self._skip_stack[-1] if self._skip_stack else False
        self._coming_stack.append(parent_coming or attrs.get("data-status") == "coming")
        self._skip_stack.append(parent_skip or tag in ("script", "style"))

    def handle_endtag(self, tag):
        if tag == "title":
            self._in_title = False
        if tag in VOID:
            return
        if self._coming_stack:
            self._coming_stack.pop()
        if self._skip_stack:
            self._skip_stack.pop()

    def handle_data(self, data):
        if self._skip_stack and self._skip_stack[-1]:
            return
        in_coming = bool(self._coming_stack and self._coming_stack[-1])
        self.text_chunks.append((data, in_coming))


def resolves_case_sensitively(root, relative_path):
    """Resolve relative_path under root, requiring every path segment to
    match the on-disk name byte-for-byte.

    Path.exists() defers to the host filesystem, which is case-insensitive
    on macOS — a link to LOGO.webp would resolve locally even though the
    real file is logo.webp. GitHub Pages serves from Linux, where that same
    link 404s. Comparing against an exact directory listing (not just
    asking the OS to look the name up) catches the mismatch on any host.
    """
    current = root
    segments = [part for part in relative_path.split("/") if part not in ("", ".")]
    for segment in segments:
        if segment == "..":
            current = current.parent
            continue
        if not current.is_dir():
            return False
        try:
            names = {entry.name for entry in current.iterdir()}
        except OSError:
            return False
        if segment not in names:
            return False
        current = current / segment
    return current.exists()


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
        relative = link.split("#")[0].split("?")[0]
        if not relative:
            continue
        if not resolves_case_sensitively(ROOT, relative):
            failures.append(f"{name}: link {link!r} does not resolve")

    full_text = " ".join(text for text, _ in parser.text_chunks)
    coming_text = " ".join(text for text, in_coming in parser.text_chunks if in_coming)
    for word in UNSHIPPED_WORDS:
        pattern = re.compile(r"\b" + re.escape(word) + r"\b", re.IGNORECASE)
        occurrences = len(pattern.findall(full_text))
        labelled = len(pattern.findall(coming_text))
        if occurrences > labelled:
            failures.append(
                f'{name}: {word!r} appears outside an element with '
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
