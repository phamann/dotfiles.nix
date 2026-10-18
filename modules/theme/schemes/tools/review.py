#!/usr/bin/env python3
"""Measure a base24/base16 scheme against the properties that make one usable.

Eyeballing a palette tells you whether you like it; it does not tell you that
bright yellow is indistinguishable from plain yellow in your terminal, or that
comments are louder than code, or that diff +/- collapses under the most
common form of colour blindness. Those are the failures this catches.

Usage:
    review.py base24/slate-frappe.yaml
    review.py base24/slate-frappe.yaml <other>.yaml ...   # compare side by side

Paths resolve against modules/theme/schemes/, so upstream schemes can be
reviewed too:
    review.py "$(nix eval --raw .#...)/base24/catppuccin-frappe.yaml"

Every threshold below is a judgement call, documented where it is used. They
are starting points for a conversation, not a passing grade.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from mkscheme import contrast, delta_e, hex_to_oklch  # noqa: E402

SCHEMES = Path(__file__).resolve().parent.parent
ACCENTS = ["base08", "base09", "base0A", "base0B", "base0C", "base0D", "base0E"]
# Slot -> conventional hue window in OKLCh degrees. Syntax highlighting assumes
# these: base08 is what an error or a deleted line is painted with, so a scheme
# that puts green there will render diffs backwards no matter how pretty it is.
SLOT_HUES = {
    "base08": (355, 40), "base09": (30, 80), "base0A": (70, 110), "base0B": (110, 175),
    "base0C": (170, 225), "base0D": (220, 290), "base0E": (285, 355),
}


def load(path: Path) -> tuple[str, dict[str, str]]:
    palette, name = {}, path.stem
    for line in path.read_text().splitlines():
        slot = re.match(r'\s*(base[0-9A-F]{2}):\s*"?(#?[0-9a-fA-F]{6})"?', line)
        if slot:
            palette[slot.group(1)] = "#" + slot.group(2).lstrip("#").lower()
        label = re.match(r'\s*name:\s*"?([^"\n]+)"?', line)
        if label:
            name = label.group(1).strip().strip('"')
    if len(palette) < 16:
        raise SystemExit(f"{path}: only found {len(palette)} slots")
    return name, palette


def simulate(value: str, kind: str) -> str:
    """Viénot et al. dichromat simulation. Approximate, but good enough to
    catch a pair that collapses entirely."""

    def linear(c: float) -> float:
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    def encode(c: float) -> float:
        return 12.92 * c if c <= 0.0031308 else 1.055 * (c ** (1 / 2.4)) - 0.055

    r, g, b = (linear(int(value[i : i + 2], 16) / 255) for i in (1, 3, 5))
    long = 17.8824 * r + 43.5161 * g + 4.11935 * b
    med = 3.45565 * r + 27.1554 * g + 3.86714 * b
    short = 0.0299566 * r + 0.184309 * g + 1.46709 * b
    if kind == "deuteranopia":
        long2, med2, short2 = long, 0.494207 * long + 1.24827 * short, short
    else:  # protanopia
        long2, med2, short2 = 2.02344 * med - 2.52581 * short, med, short
    out = (
        0.0809444479 * long2 - 0.130504409 * med2 + 0.116721066 * short2,
        -0.0102485335 * long2 + 0.0540193266 * med2 - 0.113614708 * short2,
        -0.000365296938 * long2 - 0.00412161469 * med2 + 0.693511405 * short2,
    )
    return "#%02x%02x%02x" % tuple(
        max(0, min(255, round(encode(max(0.0, min(1.0, c))) * 255))) for c in out
    )


def stdev(values: list[float]) -> float:
    mean = sum(values) / len(values)
    return (sum((v - mean) ** 2 for v in values) / len(values)) ** 0.5


def swatch(value: str) -> str:
    r, g, b = (int(value[i : i + 2], 16) for i in (1, 3, 5))
    return f"\033[48;2;{r};{g};{b}m   \033[0m"


def report(name: str, palette: dict[str, str]) -> None:
    bg = palette["base00"]
    bg_l, bg_c, bg_h = hex_to_oklch(bg)
    accent_l = [hex_to_oklch(palette[k])[0] for k in ACCENTS]
    accent_c = [hex_to_oklch(palette[k])[1] for k in ACCENTS]
    min_de = min(
        delta_e(palette[a], palette[b])
        for i, a in enumerate(ACCENTS)
        for b in ACCENTS[i + 1 :]
    )

    print(f"\n=== {name}")
    print("".join(swatch(palette[k]) for k in sorted(palette)))

    print("\n-- ground and text")
    note = "near-neutral" if bg_c < 0.015 else "tinted"
    print(f"   background          {bg} L={bg_l:.3f} C={bg_c:.3f} ({note}) H={bg_h:.0f}")
    # Comments below ~2.6:1 disappear; above ~4.3:1 they compete with code.
    print(f"   comments / bg       {contrast(palette['base03'], bg):5.2f}:1   (2.6-4.3 reads as secondary)")
    print(f"   body text / bg      {contrast(palette['base05'], bg):5.2f}:1")
    print(f"   selection / bg      dE {delta_e(palette['base02'], bg):5.1f}     (5-13 visible, not shouty)")
    print(f"   base01 / base00     dE {delta_e(palette['base01'], bg):5.1f}     (status bars, floats)")

    print("\n-- accents")
    print(f"   chroma     mean {sum(accent_c)/7:.3f}  sd {stdev(accent_c):.4f}   (low sd = no colour pops out)")
    print(f"   lightness  mean {sum(accent_l)/7:.3f}  sd {stdev(accent_l):.4f}")
    # If accents sit at the same lightness as body text, code stops standing
    # out from prose and differs only by hue.
    gap = hex_to_oklch(palette["base05"])[0] - sum(accent_l) / 7
    verdict = "FLAT - code will not stand out" if gap < 0.02 else "ok"
    print(f"   text-vs-syntax lightness gap {gap:+.3f}   ({verdict})")
    print(f"   min pairwise dE {min_de:5.2f}   (below ~8 and neighbouring accents blur)")

    print("\n-- slot conventions (syntax highlighting depends on these)")
    problems = []
    for slot, (low, high) in SLOT_HUES.items():
        _, chroma, hue = hex_to_oklch(palette[slot])
        inside = (low <= hue <= high) if low <= high else (hue >= low or hue <= high)
        if chroma < 0.02:
            problems.append(f"{slot} is greyed out")
        elif not inside:
            problems.append(f"{slot} at hue {hue:.0f} is outside {low}-{high}")
    print("   " + ("; ".join(problems) if problems else "all accents in their conventional hue windows"))

    print("\n-- colour vision (diff +/-, error vs ok rely on these)")
    pairs = [
        ("base08", "base0B", "red vs green"),
        ("base0A", "base0B", "yellow vs green"),
        ("base0C", "base0D", "cyan vs blue"),
        ("base08", "base09", "red vs orange"),
    ]
    print(f"   {'pair':<20}{'normal':>9}{'deuter':>9}{'protan':>9}")
    for a, b, label in pairs:
        d = delta_e(simulate(palette[a], "deuteranopia"), simulate(palette[b], "deuteranopia"))
        p = delta_e(simulate(palette[a], "protanopia"), simulate(palette[b], "protanopia"))
        flag = "  <-- weak" if min(d, p) < 4.0 else ""
        print(f"   {label:<20}{delta_e(palette[a], palette[b]):9.1f}{d:9.1f}{p:9.1f}{flag}")

    if "base12" in palette:
        print("\n-- ANSI bright vs normal (bold text in any TUI)")
        for normal, bright, label in [
            ("base08", "base12", "red"), ("base0A", "base13", "yellow"),
            ("base0B", "base14", "green"), ("base0C", "base15", "cyan"),
            ("base0D", "base16", "blue"), ("base0E", "base17", "magenta"),
        ]:
            d = delta_e(palette[normal], palette[bright])
            print(f"   {label:<9}{palette[normal]} -> {palette[bright]}  dE {d:5.1f}"
                  f"{'   <-- indistinguishable' if d < 6 else ''}")


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    for arg in sys.argv[1:]:
        path = Path(arg)
        if not path.exists():
            path = SCHEMES / arg
        report(*load(path))
    print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
