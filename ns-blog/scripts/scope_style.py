#!/usr/bin/env python3
"""Prefix a design stylesheet so it applies only under html[data-style="…"].

@font-face and @keyframes stay global. Font urls are rewritten into
/fonts/<style>/ so each design can ship its own files. Other urls are left
alone.
"""

from __future__ import annotations

import argparse
import sys

import tinycss2


RULE_BLOCKS = {"media", "supports", "layer", "container", "document"}
KEYFRAMES = {"keyframes", "-webkit-keyframes"}


def split_selectors(selector: str) -> list[str]:
    parts: list[str] = []
    buf: list[str] = []
    depth = 0
    for ch in selector:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == "," and depth == 0:
            parts.append("".join(buf))
            buf = []
        else:
            buf.append(ch)
    parts.append("".join(buf))
    return parts


def prefix_one(selector: str, scope: str) -> str:
    s = selector.strip()
    if not s:
        return s
    if s.startswith(":root"):
        return scope + s[len(":root") :]
    if s == "html" or (s.startswith("html") and s[4] in ":.[# >+~"):
        return scope + s[4:]
    return f"{scope} {s}"


def prefix_selector(selector: str, scope: str) -> str:
    return ", ".join(prefix_one(part, scope) for part in split_selectors(selector))


def serialize_tokens(tokens) -> str:
    return "".join(token.serialize() for token in tokens)


def render(nodes, scope: str, keyframes: bool = False) -> str:
    out: list[str] = []
    for node in nodes:
        if node.type == "whitespace":
            out.append(node.value)
            continue
        if node.type == "comment":
            out.append(f"/*{node.value}*/")
            continue
        if node.type == "error":
            raise SystemExit(f"css parse error: {node.message}")
        if node.type == "qualified-rule":
            selector = serialize_tokens(node.prelude).strip()
            if not keyframes:
                selector = prefix_selector(selector, scope)
            body = serialize_tokens(node.content)
            out.append(f"{selector}{{{body}}}")
            continue
        if node.type != "at-rule":
            raise SystemExit(f"unexpected css node {node.type}")
        keyword = node.at_keyword.lower()
        prelude = serialize_tokens(node.prelude)
        if node.content is None:
            out.append(f"@{node.at_keyword}{prelude};")
            continue
        if keyword in KEYFRAMES:
            inner = render(
                tinycss2.parse_rule_list(node.content, skip_whitespace=False),
                scope,
                keyframes=True,
            )
            out.append(f"@{node.at_keyword}{prelude}{{{inner}}}")
            continue
        if keyword in RULE_BLOCKS:
            inner = render(
                tinycss2.parse_rule_list(node.content, skip_whitespace=False),
                scope,
            )
            out.append(f"@{node.at_keyword}{prelude}{{{inner}}}")
            continue
        body = serialize_tokens(node.content)
        out.append(f"@{node.at_keyword}{prelude}{{{body}}}")
    return "".join(out)


def rewrite_font_urls(css: str, style: str) -> str:
    for quote in ('"', "'"):
        css = css.replace(
            f"url({quote}/fonts/", f"url({quote}/fonts/{style}/"
        )
        css = css.replace(
            f"url({quote}fonts/", f"url({quote}/fonts/{style}/"
        )
    css = css.replace("url(/fonts/", f"url(/fonts/{style}/")
    css = css.replace("url(fonts/", f"url(/fonts/{style}/")
    return css


def scope_css(css: str, style: str) -> str:
    scope = f'html[data-style="{style}"]'
    nodes = tinycss2.parse_stylesheet(
        css, skip_comments=False, skip_whitespace=False
    )
    return rewrite_font_urls(render(nodes, scope), style)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("style")
    parser.add_argument("source")
    parser.add_argument("dest")
    args = parser.parse_args()
    with open(args.source, encoding="utf-8") as handle:
        css = handle.read()
    scoped = scope_css(css, args.style)
    with open(args.dest, "w", encoding="utf-8") as handle:
        handle.write(scoped)
        if not scoped.endswith("\n"):
            handle.write("\n")


if __name__ == "__main__":
    main()
