#!/usr/bin/env python3
"""Print a scheme's background next to progressively lighter versions of it.

For judging whether a display is rendering the theme correctly. Open it on a
known-good display, note how A looks, then drag the window to the display under
test: if A now looks too dark but C matches what A looked like, the display is
under-driving shadows by about two steps.

Each step is +0.010 in OKLab lightness. Useful because "is this too dark" is
impossible to answer from memory across two rooms and two panels, but "which
of these five matches" is easy.

Usage:
    swatch.py                       # the active scheme (base24/slate-frappe)
    swatch.py base24/<slug>.yaml
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from mkscheme import contrast, hex_to_oklch, lch_to_hex  # noqa: E402

SCHEMES = Path(__file__).resolve().parent.parent
DEFAULT = "base24/slate-frappe.yaml"
STEPS = [0.0, 0.010, 0.020, 0.030, 0.040]
WIDTH = 11


def load(path: Path) -> dict[str, str]:
    palette = {}
    for line in path.read_text().splitlines():
        m = re.match(r'\s*(base[0-9A-F]{2}):\s*"(#[0-9a-f]{6})"', line)
        if m:
            palette[m.group(1)] = m.group(2)
    if not palette:
        raise SystemExit(f"no palette found in {path}")
    return palette


def block(value: str, width: int = WIDTH) -> str:
    r, g, b = (int(value[i : i + 2], 16) for i in (1, 3, 5))
    return f"\033[48;2;{r};{g};{b}m{' ' * width}\033[0m"


def main() -> int:
    arg = sys.argv[1] if len(sys.argv) > 1 else DEFAULT
    path = Path(arg)
    if not path.exists():
        path = SCHEMES / arg
    palette = load(path)
    bg = palette["base00"]
    lightness, chroma, hue = hex_to_oklch(bg)

    swatches, labels, values = [], [], []
    for i, step in enumerate(STEPS):
        value, _ = lch_to_hex(lightness + step, chroma, hue)
        swatches.append(block(value))
        labels.append(f"{'ABCDE'[i]:^{WIDTH}}")
        values.append(f"{value:^{WIDTH}}")

    print(f"\n  {path.stem} — background, lifted in steps of 0.010 OKLab lightness\n")
    print("  " + "".join(labels))
    for _ in range(3):
        print("  " + "".join(swatches))
    print("  " + "".join(values))
    print(f"\n  A = the real background ({bg}, L={lightness:.3f})\n")

    ramp = ["base00", "base01", "base02", "base03", "base04"]
    print("  Dark ramp — all five must stay separable, or line-number and")
    print("  status-bar backgrounds stop reading as distinct from the editor:\n")
    print("  " + "".join(block(palette[k]) for k in ramp))
    print("  " + "".join(f"{k[-2:]:^{WIDTH}}" for k in ramp))
    print("  " + "".join(f"{palette[k]:^{WIDTH}}" for k in ramp))
    print(
        f"\n  comments/bg {contrast(palette['base03'], bg):.2f}:1   "
        f"text/bg {contrast(palette['base05'], bg):.2f}:1\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
