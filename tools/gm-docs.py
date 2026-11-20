#!/usr/bin/env python3
"""
Search local GameMaker Studio 2 manual/documentation.

Discovers locally installed RoboHelp keyword indexes and manual zip archives
(commonly installed with GameMaker via Steam/Proton) and provides:
  - keyword/topic search (fast, uses helpdocs_keywords.json / tags)
  - full-text search inside manual HTML files
  - page display with basic HTML-to-text rendering

Examples:
  python3 tools/gm-docs.py search draw_sprite
  python3 tools/gm-docs.py search "instance create"
  python3 tools/gm-docs.py show draw_sprite
  python3 tools/gm-docs.py show GameMaker_Language/GML_Reference/Drawing/Sprites_And_Tiles/draw_sprite.htm
  python3 tools/gm-docs.py sources
"""

from __future__ import annotations

import argparse
import html
import json
import os
import re
import sys
import textwrap
import zipfile
from dataclasses import dataclass, field
from html.parser import HTMLParser
from pathlib import Path
from typing import Iterable, Iterator


HOME = Path.home()
STEAM_COMMON_GM = HOME / ".local/share/Steam/steamapps/common/GameMaker Studio 2"
KNOWN_KEYWORD_JSON = [
    STEAM_COMMON_GM / "RoboHelp/helpdocs_keywords.json",
    STEAM_COMMON_GM / "RoboHelp/helpdocs_tags.json",  # tags map, different shape but useful
]
KNOWN_MANUAL_ZIPS = [
    HOME / ".local/share/Steam/steamapps/compatdata/1670460/pfx/drive_c/ProgramData/GameMakerStudio2-Beta/Manual/GMS2-Robohelp-en.zip",
    HOME / ".local/share/Steam/steamapps/compatdata/1670460/pfx/drive_c/ProgramData/GameMakerStudio2-LTS2026/Manual/GMS2-Robohelp-en.zip",
]
KNOWN_KEYWORD_SEARCH_DIRS = [
    STEAM_COMMON_GM / "RoboHelp",
    HOME / ".local/share/Steam/steamapps/compatdata/1670460/pfx/drive_c/Program Files/GameMaker-Beta/RoboHelp",
]
KNOWN_MANUAL_SEARCH_ROOTS = [
    HOME / ".local/share/Steam/steamapps/compatdata",
    HOME / ".local/share/GameMakerStudio2",
    HOME / ".config/GameMakerStudio2",
    HOME / "GameMakerStudio2",
]


@dataclass
class Sources:
    keyword_files: list[Path] = field(default_factory=list)
    tag_files: list[Path] = field(default_factory=list)
    manual_zips: list[Path] = field(default_factory=list)

    def keywords(self) -> dict[str, str]:
        merged: dict[str, str] = {}
        # later files override earlier? keep first-seen for stability except prefer installed IDE index
        for p in self.keyword_files:
            try:
                data = json.loads(p.read_text(encoding="utf-8", errors="replace"))
            except Exception:
                continue
            if isinstance(data, dict):
                for k, v in data.items():
                    if isinstance(k, str) and isinstance(v, str):
                        merged.setdefault(k, v)
        return merged

    def tags(self) -> dict[str, str]:
        merged: dict[str, str] = {}
        for p in self.tag_files:
            try:
                data = json.loads(p.read_text(encoding="utf-8", errors="replace"))
            except Exception:
                continue
            if isinstance(data, dict):
                for k, v in data.items():
                    if isinstance(k, str) and isinstance(v, str):
                        merged.setdefault(k, v)
        return merged


def _dedupe_paths(paths: Iterable[Path]) -> list[Path]:
    out: list[Path] = []
    seen: set[str] = set()
    for p in paths:
        try:
            rp = str(p.resolve())
        except Exception:
            rp = str(p)
        if rp in seen:
            continue
        if p.exists():
            seen.add(rp)
            out.append(p)
    return out


def discover_sources(extra_manual: str | None = None) -> Sources:
    keyword_files: list[Path] = []
    tag_files: list[Path] = []
    manual_zips: list[Path] = []

    for d in KNOWN_KEYWORD_SEARCH_DIRS:
        if d.is_dir():
            k = d / "helpdocs_keywords.json"
            t = d / "helpdocs_tags.json"
            if k.exists():
                keyword_files.append(k)
            if t.exists():
                tag_files.append(t)

    # explicit known locations
    for p in KNOWN_KEYWORD_JSON:
        if p.name == "helpdocs_keywords.json":
            keyword_files.append(p)
        elif p.name == "helpdocs_tags.json":
            tag_files.append(p)

    manual_zips.extend(KNOWN_MANUAL_ZIPS)

    # targeted discovery for manual zips
    for root in KNOWN_MANUAL_SEARCH_ROOTS:
        if not root.exists():
            continue
        try:
            for p in root.rglob("GMS2-Robohelp*.zip"):
                # avoid huge unrelated trees where possible but these roots are specific enough
                if "Manual" in str(p) or "Robohelp" in p.name:
                    manual_zips.append(p)
        except Exception:
            pass

    if extra_manual:
        p = Path(extra_manual).expanduser()
        if p.is_dir():
            # look for zip inside
            manual_zips.extend(sorted(p.glob("*.zip")))
        else:
            manual_zips.insert(0, p)

    # prefer newer/larger beta-ish names? simple heuristic: sort by mtime desc
    manual_zips = _dedupe_paths(manual_zips)
    manual_zips.sort(key=lambda p: p.stat().st_mtime if p.exists() else 0, reverse=True)

    return Sources(
        keyword_files=_dedupe_paths(keyword_files),
        tag_files=_dedupe_paths(tag_files),
        manual_zips=manual_zips,
    )


def norm_doc_path(path: str) -> str:
    p = path.replace("\\", "/").lstrip("/")
    return p


def candidate_zip_names(doc_path: str) -> list[str]:
    p = norm_doc_path(doc_path)
    names = [p]
    if not p.lower().endswith(".htm") and not p.lower().endswith(".html"):
        names.append(p + ".htm")
        names.append(p + ".html")
    # also try case-insensitively by scanning later
    return names


def open_manual_zip(sources: Sources) -> zipfile.ZipFile | None:
    for p in sources.manual_zips:
        try:
            return zipfile.ZipFile(p)
        except Exception:
            continue
    return None


def find_in_zip(zf: zipfile.ZipFile, doc_path: str) -> str | None:
    wanted = [n.lower() for n in candidate_zip_names(doc_path)]
    names = zf.namelist()
    lower_map = {n.lower(): n for n in names}
    for w in wanted:
        if w in lower_map:
            return lower_map[w]
    # suffix match for bare names like draw_sprite
    base = Path(norm_doc_path(doc_path)).name.lower()
    if not base.endswith(".htm") and not base.endswith(".html"):
        base_htm = base + ".htm"
    else:
        base_htm = base
    suffix_matches = [n for n in names if n.lower().endswith("/" + base_htm) or n.lower() == base_htm]
    if suffix_matches:
        # prefer GML_Reference over DnD if ambiguous? keep deterministic
        suffix_matches.sort(key=lambda n: (0 if "GML_Reference" in n else 1, len(n), n))
        return suffix_matches[0]
    return None


class _TextExtractor(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.parts: list[str] = []
        self._skip = 0
        self._in_pre = 0

    def handle_starttag(self, tag: str, attrs):
        t = tag.lower()
        if t in ("script", "style", "head"):
            self._skip += 1
        if t in ("br",):
            self.parts.append("\n")
        if t in ("p", "div", "section", "article", "tr", "li", "h1", "h2", "h3", "h4", "h5", "h6", "table", "ul", "ol", "pre", "blockquote"):
            self.parts.append("\n")
        if t == "li":
            self.parts.append("- ")
        if t in ("td", "th"):
            self.parts.append("\t")
        if t == "pre":
            self._in_pre += 1

    def handle_endtag(self, tag: str):
        t = tag.lower()
        if t in ("script", "style", "head") and self._skip:
            self._skip -= 1
        if t in ("p", "div", "section", "article", "tr", "h1", "h2", "h3", "h4", "h5", "h6", "table", "ul", "ol", "pre", "blockquote"):
            self.parts.append("\n")
        if t == "pre" and self._in_pre:
            self._in_pre -= 1

    def handle_data(self, data: str):
        if self._skip:
            return
        if self._in_pre:
            self.parts.append(data)
        else:
            self.parts.append(data)

    def get_text(self) -> str:
        text = html.unescape("".join(self.parts))
        text = text.replace("\r\n", "\n").replace("\r", "\n")
        # collapse excessive blank lines and spaces
        text = re.sub(r"[ \t\f\v]+", " ", text)
        text = re.sub(r" *\n *", "\n", text)
        text = re.sub(r"\n{3,}", "\n\n", text)
        return text.strip()


def html_to_text(raw: str) -> str:
    parser = _TextExtractor()
    try:
        parser.feed(raw)
        parser.close()
        return parser.get_text()
    except Exception:
        # fallback: crude strip
        txt = re.sub(r"<script\b.*?</script>", "", raw, flags=re.I | re.S)
        txt = re.sub(r"<style\b.*?</style>", "", txt, flags=re.I | re.S)
        txt = re.sub(r"<[^>]+>", " ", txt)
        txt = html.unescape(txt)
        return re.sub(r"\s+", " ", txt).strip()


def extract_title(raw_html: str) -> str | None:
    m = re.search(r"<title>(.*?)</title>", raw_html, flags=re.I | re.S)
    if m:
        t = html.unescape(re.sub(r"\s+", " ", m.group(1))).strip()
        return t or None
    m = re.search(r"<h1[^>]*>(.*?)</h1>", raw_html, flags=re.I | re.S)
    if m:
        t = html.unescape(re.sub(r"<[^>]+>", " ", m.group(1)))
        t = re.sub(r"\s+", " ", t).strip()
        return t or None
    return None


def cmd_sources(args: argparse.Namespace) -> int:
    sources = discover_sources(args.manual)
    print("Keyword index files:")
    for p in sources.keyword_files:
        print(f"  - {p}")
    if not sources.keyword_files:
        print("  (none found)")
    print("Tag files:")
    for p in sources.tag_files:
        print(f"  - {p}")
    if not sources.tag_files:
        print("  (none found)")
    print("Manual archives:")
    for p in sources.manual_zips:
        try:
            size = p.stat().st_size
            print(f"  - {p} ({size} bytes)")
        except Exception:
            print(f"  - {p}")
    if not sources.manual_zips:
        print("  (none found)")
    return 0


def score_keyword_match(key: str, value: str, terms: list[str]) -> int:
    kl = key.lower()
    vl = value.lower()
    score = 0
    for t in terms:
        tl = t.lower()
        if kl == tl:
            score += 100
        elif kl.startswith(tl):
            score += 40
        elif tl in kl:
            score += 20
        if vl == tl:
            score += 30
        elif tl in vl:
            score += 10
    return score


def cmd_search(args: argparse.Namespace) -> int:
    query = " ".join(args.query).strip()
    terms = [t for t in re.split(r"\s+", query) if t]
    if not terms:
        print("No query provided.", file=sys.stderr)
        return 2
    sources = discover_sources(args.manual)
    keywords = sources.keywords()
    tags = sources.tags()

    results: list[tuple[int, str, str, str]] = []  # score, kind, name, target
    ql = query.lower()

    for k, v in keywords.items():
        s = score_keyword_match(k, v, terms)
        if s > 0:
            results.append((s, "keyword", k, v))

    # tag/path search
    for path, tagstr in tags.items():
        hay = (path + " " + tagstr).lower()
        if all(t.lower() in hay for t in terms):
            # score by basename match
            base = Path(path).stem.lower()
            s = 5
            for t in terms:
                tl = t.lower()
                if base == tl:
                    s += 50
                elif tl in base:
                    s += 15
                elif tl in tagstr.lower():
                    s += 8
                elif tl in path.lower():
                    s += 4
            results.append((s, "tag", path, tagstr))

    # dedupe by (kind,name,target)
    seen = set()
    uniq = []
    for r in sorted(results, key=lambda x: (-x[0], x[1], x[2].lower())):
        key = (r[1], r[2], r[3])
        if key in seen:
            continue
        seen.add(key)
        uniq.append(r)

    limit = args.limit
    shown = uniq[:limit]
    if shown:
        print(f"Index matches for {query!r} ({len(uniq)} found, showing {len(shown)}):")
        for score, kind, name, target in shown:
            if kind == "keyword":
                print(f"  - [{kind}] {name} -> {target}")
            else:
                print(f"  - [{kind}] {name} (tags: {target})")
    else:
        print(f"No index matches for {query!r}.")

    if args.text:
        # full-text search in manual zips
        zf = open_manual_zip(sources)
        if not zf:
            print("\nNo manual zip available for full-text search.", file=sys.stderr)
            return 1 if not shown else 0
        print(f"\nFull-text search in: {zf.filename}")
        tlimit = args.text_limit
        found = 0
        terms_l = [t.lower() for t in terms]
        for name in zf.namelist():
            nl = name.lower()
            if not (nl.endswith('.htm') or nl.endswith('.html')):
                continue
            try:
                raw = zf.read(name).decode('utf-8', errors='replace')
            except Exception:
                continue
            text = html_to_text(raw)
            hay = (name + "\n" + (extract_title(raw) or "") + "\n" + text).lower()
            if not all(t in hay for t in terms_l):
                continue
            title = extract_title(raw) or Path(name).stem
            # snippet around first term
            pos = hay.find(terms_l[0])
            snippet = ""
            if pos >= 0:
                start = max(0, pos - 80)
                end = min(len(text), pos + 160)
                snippet = re.sub(r"\s+", " ", text[start:end]).strip()
            print(f"  - {name}")
            print(f"    title: {title}")
            if snippet:
                print(f"    snippet: {snippet}")
            found += 1
            if found >= tlimit:
                print(f"  (stopped at {tlimit} text matches)")
                break
        if found == 0:
            print("  No full-text matches.")
    return 0


def cmd_show(args: argparse.Namespace) -> int:
    name = " ".join(args.name).strip()
    sources = discover_sources(args.manual)
    keywords = sources.keywords()
    zf = open_manual_zip(sources)
    if not zf:
        print("No manual archive found. Run `sources` to see discovery results.", file=sys.stderr)
        return 1

    # resolve keyword to path if exact/ci match
    doc_path = name
    resolved_from = None
    if name in keywords:
        doc_path = keywords[name]
        resolved_from = f"keyword:{name}"
    else:
        # case-insensitive keyword lookup
        ci = {k.lower(): (k, v) for k, v in keywords.items()}
        if name.lower() in ci:
            k, v = ci[name.lower()]
            doc_path = v
            resolved_from = f"keyword:{k}"

    member = find_in_zip(zf, doc_path)
    if not member and resolved_from is None:
        # try direct as keyword-like name not in index but maybe file exists
        member = find_in_zip(zf, name)

    if not member:
        print(f"Could not find page for {name!r} in {zf.filename}", file=sys.stderr)
        # suggest close keyword matches
        terms = [t for t in re.split(r"\s+", name) if t]
        if terms and keywords:
            sugg = []
            for k, v in keywords.items():
                s = score_keyword_match(k, v, terms)
                if s:
                    sugg.append((s, k, v))
            sugg.sort(key=lambda x: -x[0])
            if sugg:
                print("Did you mean:", file=sys.stderr)
                for _, k, v in sugg[:10]:
                    print(f"  - {k} -> {v}", file=sys.stderr)
        return 1

    raw = zf.read(member).decode("utf-8", errors="replace")
    title = extract_title(raw) or Path(member).stem
    text = html_to_text(raw)
    print(f"Source archive: {zf.filename}")
    if resolved_from:
        print(f"Resolved from:  {resolved_from}")
    print(f"Page:           {member}")
    print(f"Title:          {title}")
    print("=" * 80)
    # print with reasonable width but keep code-like lines intact enough
    print(text)
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="Search local GameMaker manual/docs.")
    p.add_argument("--manual", help="Path to manual zip file or directory containing it.")
    sub = p.add_subparsers(dest="cmd", required=True)

    sp = sub.add_parser("sources", help="Show discovered documentation sources.")
    sp.set_defaults(func=cmd_sources)

    ss = sub.add_parser("search", help="Search keywords/tags and optionally full text.")
    ss.add_argument("query", nargs="+", help="Search terms.")
    ss.add_argument("--limit", type=int, default=30, help="Max index results to show (default: 30).")
    ss.add_argument("--text", action="store_true", help="Also perform full-text search inside manual HTML.")
    ss.add_argument("--text-limit", type=int, default=20, help="Max full-text results (default: 20).")
    ss.set_defaults(func=cmd_search)

    sh = sub.add_parser("show", help="Show a manual page by keyword/name/path.")
    sh.add_argument("name", nargs="+", help="Keyword, function name, or doc path.")
    sh.set_defaults(func=cmd_show)

    return p


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
