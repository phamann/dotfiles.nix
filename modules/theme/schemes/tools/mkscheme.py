#!/usr/bin/env python3
"""Generate a base24 scheme from an OKLCh spec.

A scheme needs two files that must agree: a YAML palette that Stylix reads,
and a tinted-vim colorscheme that nvim reads (see docs/THEMING.md section 5).
Hand-maintaining 24 hex values across both is how they drift apart, so the
hex is generated and the *spec* is the thing under version control.

Colours are specified in OKLCh (perceptual lightness, chroma, hue) rather
than hex because the properties that decide whether a scheme is comfortable
-- "is every accent equally saturated", "do comments recede", "can these two
colours be told apart" -- are arithmetic in OKLCh and invisible in hex.

Usage:
    mkscheme.py specs/<slug>.py          # write the scheme files
    mkscheme.py specs/<slug>.py --check  # verify files match the spec

--check regenerates into memory and diffs against what is committed; it exits
non-zero on drift, so it is safe to wire into CI.

A spec module defines NAME, SLUG, AUTHOR, SPEC and HEADER -- see
specs/slate-frappe.py, which is commented as the worked example.
"""

from __future__ import annotations

import argparse
import importlib.util
import math
import sys
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
SCHEMES = TOOLS.parent
REPO = SCHEMES.parents[2]
TEMPLATE = TOOLS / "tinted-vim.template.vim"

# Integrated-terminal colours, in ANSI 0-15 order. The bright half comes from
# the base24 extension slots, which is the whole reason to prefer base24 over
# base16 for a terminal-centric setup.
ANSI = [
    "base00", "base08", "base0B", "base0A", "base0D", "base0E", "base0C", "base05",
    "base03", "base12", "base14", "base13", "base16", "base17", "base15", "base07",
]


# --- colour maths ----------------------------------------------------------
# OKLab/OKLCh per Björn Ottosson (https://bottosson.github.io/posts/oklab/).


def _srgb_from_oklab(lightness: float, a: float, b: float) -> tuple[float, float, float]:
    l_ = lightness + 0.3963377774 * a + 0.2158037573 * b
    m_ = lightness - 0.1055613458 * a - 0.0638541728 * b
    s_ = lightness - 0.0894841775 * a - 1.2914855480 * b
    l, m, s = l_**3, m_**3, s_**3
    return (
        4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
        -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
        -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
    )


def _encode(channel: float) -> float:
    """Linear light -> sRGB gamma."""
    if channel <= 0.0031308:
        return 12.92 * channel
    return 1.055 * (channel ** (1 / 2.4)) - 0.055


def _in_gamut(rgb: tuple[float, float, float], eps: float = 1e-4) -> bool:
    return all(-eps <= c <= 1 + eps for c in rgb)


def lch_to_hex(lightness: float, chroma: float, hue: float) -> tuple[str, float]:
    """OKLCh -> "#rrggbb", returning the chroma that sRGB could not carry.

    Lightness and hue are preserved exactly and chroma is reduced until the
    colour fits, because a shifted hue is far more visible than a slightly
    duller one. Saturated blues at high lightness clip hardest -- that is a
    property of sRGB, not a bug in the spec, so the loss is reported rather
    than silently absorbed.
    """
    radians = math.radians(hue)
    target = _srgb_from_oklab(lightness, chroma * math.cos(radians), chroma * math.sin(radians))
    if _in_gamut(target):
        fitted = chroma
    else:
        low, high = 0.0, chroma
        for _ in range(48):
            mid = (low + high) / 2
            probe = _srgb_from_oklab(lightness, mid * math.cos(radians), mid * math.sin(radians))
            if _in_gamut(probe):
                low = mid
            else:
                high = mid
        fitted = low
    rgb = _srgb_from_oklab(lightness, fitted * math.cos(radians), fitted * math.sin(radians))
    channels = (max(0, min(255, round(_encode(max(0.0, min(1.0, c))) * 255))) for c in rgb)
    return "#%02x%02x%02x" % tuple(channels), chroma - fitted


def hex_to_oklch(value: str) -> tuple[float, float, float]:
    def linear(channel: float) -> float:
        return channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4

    r, g, b = (linear(int(value[i : i + 2], 16) / 255) for i in (1, 3, 5))
    long = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    med = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    short = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
    l_, m_, s_ = long ** (1 / 3), med ** (1 / 3), short ** (1 / 3)
    lightness = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
    a = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
    b_ = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
    return lightness, math.hypot(a, b_), math.degrees(math.atan2(b_, a)) % 360


def relative_luminance(value: str) -> float:
    def channel(index: int) -> float:
        c = int(value[index : index + 2], 16) / 255
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4

    return 0.2126 * channel(1) + 0.7152 * channel(3) + 0.0722 * channel(5)


def contrast(fg: str, bg: str) -> float:
    """WCAG contrast ratio between two "#rrggbb" strings."""
    a, b = relative_luminance(fg), relative_luminance(bg)
    hi, lo = max(a, b), min(a, b)
    return (hi + 0.05) / (lo + 0.05)


def delta_e(a: str, b: str) -> float:
    """Perceptual distance, OKLab euclidean x100. Below ~8 reads as 'same colour'."""

    def oklab(value: str) -> tuple[float, float, float]:
        lightness, chroma, hue = hex_to_oklch(value)
        radians = math.radians(hue)
        return lightness, chroma * math.cos(radians), chroma * math.sin(radians)

    return 100 * math.dist(oklab(a), oklab(b))


# --- rendering -------------------------------------------------------------


def load_spec(path: Path):
    spec = importlib.util.spec_from_file_location(path.stem.replace("-", "_"), path)
    if spec is None or spec.loader is None:
        raise SystemExit(f"cannot load spec: {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def build(module) -> tuple[dict[str, str], dict[str, str], list[tuple[str, float]]]:
    palette: dict[str, str] = {}
    notes: dict[str, str] = {}
    clipped: list[tuple[str, float]] = []
    for slot, lightness, chroma, hue, note in module.SPEC:
        value, lost = lch_to_hex(lightness, chroma, hue)
        palette[slot], notes[slot] = value, note
        if lost > 0.002:
            clipped.append((slot, round(lost, 4)))
    return palette, notes, clipped


def summarise(palette: dict[str, str]) -> dict[str, float]:
    """The handful of numbers the spec header quotes, so it cannot go stale."""
    accents = ["base08", "base09", "base0A", "base0B", "base0C", "base0D", "base0E"]

    def stdev(values: list[float]) -> float:
        mean = sum(values) / len(values)
        return (sum((v - mean) ** 2 for v in values) / len(values)) ** 0.5

    return {
        "bg_chroma": hex_to_oklch(palette["base00"])[1],
        "comment_contrast": contrast(palette["base03"], palette["base00"]),
        "fg_contrast": contrast(palette["base05"], palette["base00"]),
        "accent_chroma_sd": stdev([hex_to_oklch(palette[k])[1] for k in accents]),
        "accent_lightness_sd": stdev([hex_to_oklch(palette[k])[0] for k in accents]),
        "min_delta_e": min(
            delta_e(palette[a], palette[b])
            for i, a in enumerate(accents)
            for b in accents[i + 1 :]
        ),
    }


def render_yaml(module, palette, notes, stats) -> str:
    lines = [
        'system: "base24"',
        f'name: "{module.NAME}"',
        f'slug: "{module.SLUG}"',
        f'author: "{module.AUTHOR}"',
        'variant: "dark"',
        "# GENERATED by modules/theme/schemes/tools/mkscheme.py -- do not edit.",
        f"# Source of truth: modules/theme/schemes/specs/{module.SLUG}.py",
    ]
    lines += module.HEADER(stats)
    lines.append("palette:")
    for slot, *_rest in module.SPEC:
        lines.append(f'  {slot}: "{palette[slot]}"  # {notes[slot]}')
    return "\n".join(lines) + "\n"


def render_vim(module, palette) -> str:
    text = TEMPLATE.read_text()
    text = text.replace("@name@", module.NAME)
    text = text.replace("@author@", module.AUTHOR)
    text = text.replace("@slug@", module.SLUG)
    for slot, value in palette.items():
        text = text.replace(f"@{slot}@", value[1:])
    if "@" in "".join(line for line in text.splitlines() if "@" in line and "base" in line):
        unfilled = [line for line in text.splitlines() if "@base" in line]
        if unfilled:
            raise SystemExit(f"template tokens left unfilled: {unfilled[:3]}")
    return text


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("spec", type=Path, help="path to a spec module")
    parser.add_argument(
        "--check",
        action="store_true",
        help="verify the committed files match the spec instead of writing them",
    )
    args = parser.parse_args()

    module = load_spec(args.spec)
    palette, notes, clipped = build(module)
    stats = summarise(palette)

    targets = {
        SCHEMES / "base24" / f"{module.SLUG}.yaml": render_yaml(module, palette, notes, stats),
        SCHEMES / "colors" / f"base24-{module.SLUG}.vim": render_vim(module, palette),
    }

    if args.check:
        drift = [p for p, body in targets.items() if not p.exists() or p.read_text() != body]
        for path in drift:
            print(f"DRIFT: {path.relative_to(REPO)}", file=sys.stderr)
        if drift:
            print(f"re-run: {Path(__file__).name} {args.spec}", file=sys.stderr)
            return 1
        print(f"{module.SLUG}: files match the spec")
        return 0

    for path, body in targets.items():
        path.write_text(body)
        print(f"wrote {path.relative_to(REPO)}")

    print(
        f"  bg chroma {stats['bg_chroma']:.3f} | fg {stats['fg_contrast']:.2f}:1 | "
        f"comments {stats['comment_contrast']:.2f}:1 | accent chroma sd "
        f"{stats['accent_chroma_sd']:.4f} | min dE {stats['min_delta_e']:.2f}"
    )
    if clipped:
        print(f"  gamut-clipped (chroma sRGB could not carry): {clipped}")
    print("  review with: tools/review.py base24/<slug>.yaml")
    print("  NOTE: new files must be `git add`ed before nix can see them (flakes")
    print("        only read git-tracked files).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
