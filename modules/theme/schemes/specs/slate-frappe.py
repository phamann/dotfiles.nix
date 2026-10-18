"""base24-slate-frappe — the worked example for mkscheme.py.

Catppuccin Frappe's pastel accents, run on a desaturated slate ground and
recalibrated. Derived from three schemes that were each almost right:

  catppuccin-frappe        the daily driver; comments vanish at 1.7:1 and the
                           accents are flat (chroma 0.101)
  cerulean-signal-dark     comments shout at 6.7:1, and base0E sits at chroma
                           0.199 against an accent mean of 0.135 — one colour
                           visibly louder than the rest
  ayu-mirage               warm fg (hue 95) on a cool bg (hue 267), a 172°
                           clash; lime base0B glares at L 0.944

Every number below is a decision, not a preference. `tools/review.py` checks
the ones that matter. See .claude/skills/theme-authoring/SKILL.md for the
method and the history of how this landed where it did.
"""

NAME = "Slate Frappe"
SLUG = "slate-frappe"
AUTHOR = "Patrick Hamann — Catppuccin Frappe's pastel accents on a slate ground"

# One hue for the whole greyscale ramp. 262 is blue rather than Frappe's 275
# indigo: at 272 the ground read as "just Frappe" however much darker it got,
# because hue identity survives large lightness changes.
BH = 262.0

# (slot, OKLCh lightness, chroma, hue, comment emitted into the YAML)
SPEC = [
    # Ground. Chroma 0.014 — identical to github-dark-dimmed — so it reads as
    # desaturated slate. Going lower (0.011) at a lower lightness (0.221) was
    # tried and collapsed to flat black: there is not enough luminance down
    # there for the eye to resolve a tint that weak.
    ("base00", 0.259, 0.014, BH, "Default Background"),
    ("base01", 0.320, 0.016, BH, "Lighter Background (status bars, line numbers)"),
    ("base02", 0.378, 0.018, BH, "Selection Background"),
    # Comments at ~3:1. Low enough to recede, high enough to read. This is
    # also what lets autocmds.lua leave @comment alone — see the skill.
    ("base03", 0.534, 0.014, BH, "Comments, Invisibles, Line Highlighting"),
    ("base04", 0.658, 0.009, BH, "Dark Foreground (status bars)"),
    # Body text. Chroma stays near zero and on the ground's hue, so fg and bg
    # never fight — the mistake ayu-mirage makes.
    ("base05", 0.830, 0.008, BH, "Default Foreground"),
    ("base06", 0.878, 0.006, BH, "Light Foreground"),
    # base07 is where autocmds.lua sends YAML/JSON/TOML keys, so it lands
    # brighter than body text on purpose, but not near-white.
    ("base07", 0.914, 0.005, BH, "Lightest Foreground"),
    # Accents: pastel, so chroma ~0.096 (below Frappe's 0.101) with lightness
    # ~0.80. Chroma is near-constant (sd 0.004) so no single colour pops out.
    #
    # Lightness is NOT constant, and the variation is load-bearing:
    #   - red sits lowest (0.725) to hold its distance from green under
    #     red-green colour blindness, where lightness is the only surviving
    #     channel. Darkening red also pulls the accent mean down, which keeps
    #     code distinct from body text.
    #   - yellow sits highest (0.868), giving base0A/base0B a 0.060 gap on top
    #     of their hue difference, for the same reason.
    # Desaturating shrinks perceptual distance, so hue gaps were widened to
    # roughly 40-50° to pay for what chroma no longer buys.
    ("base08", 0.725, 0.106, 14.0, "Variables, Diff Deleted (red)"),
    ("base09", 0.808, 0.094, 53.0, "Integers, Constants (orange)"),
    ("base0A", 0.868, 0.090, 100.0, "Classes, Search BG (yellow)"),
    ("base0B", 0.808, 0.098, 146.0, "Strings, Diff Inserted (green)"),
    ("base0C", 0.796, 0.094, 198.0, "Escape chars, Regex (cyan)"),
    ("base0D", 0.782, 0.098, 252.0, "Functions, Headings (blue)"),
    ("base0E", 0.792, 0.096, 320.0, "Keywords (magenta)"),
    # Dimmer and warmer than red, which it otherwise collides with.
    ("base0F", 0.690, 0.055, 42.0, "Deprecated, Embedded tags (brown)"),
    ("base10", 0.219, 0.013, BH, "Darker Background"),
    ("base11", 0.179, 0.012, BH, "Darkest Background"),
    # Bright ANSI. These need real distance from their base counterparts or
    # bold text in a TUI looks identical to plain — easy to get wrong once the
    # base accents have been lightened toward pastel.
    ("base12", 0.830, 0.128, 14.0, "Bright Red   (ANSI 9)"),
    ("base13", 0.940, 0.105, 100.0, "Bright Yellow (ANSI 11)"),
    ("base14", 0.890, 0.122, 146.0, "Bright Green (ANSI 10)"),
    ("base15", 0.882, 0.118, 198.0, "Bright Cyan  (ANSI 14)"),
    ("base16", 0.862, 0.122, 252.0, "Bright Blue  (ANSI 12)"),
    ("base17", 0.872, 0.120, 320.0, "Bright Magenta (ANSI 13)"),
]


def HEADER(stats):
    """Comment block for the generated YAML. Numbers come from the palette so
    they cannot drift away from the colours they describe."""
    return [
        "#",
        "# Pastel accents on a desaturated slate ground. Design rules:",
        f"#   base00-base03 : slate, chroma {stats['bg_chroma']:.3f} at hue 262 — blue rather",
        "#                   than Frappe's indigo 275, and much darker (L 0.259",
        "#                   vs its 0.329).",
        f"#   base03        : WCAG {stats['comment_contrast']:.2f} against base00 — comments recede",
        "#                   without vanishing (Frappe 1.7) or shouting",
        "#                   (Cerulean Signal 6.7).",
        f"#   base05        : WCAG {stats['fg_contrast']:.2f}, held a little below the accents'",
        "#                   reach so code still stands out from prose.",
        f"#   base08-base0E : pastel — chroma sd {stats['accent_chroma_sd']:.4f}, lightness sd",
        f"#                   {stats['accent_lightness_sd']:.4f}, min pairwise dE {stats['min_delta_e']:.2f}. The",
        "#                   lightness spread is deliberate: it is what keeps",
        "#                   red/green and yellow/green apart for red-green",
        "#                   colour blindness.",
        "#   base10-base17 : base24 extension, lifted clear of their base",
        "#                   counterparts so bright ANSI stays legible.",
    ]
