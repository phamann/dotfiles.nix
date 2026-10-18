---
name: theme-authoring
description: Author, tune, review or choose a base16/base24 colour scheme in this dotfiles repo. Use when asked to change the theme, generate a new scheme, adjust colours ("too bright", "too saturated", "more pastel", "less blue"), pick a scheme from upstream, or diagnose a theming problem. Covers the OKLCh generator under modules/theme/schemes/tools/, the measured taste profile, and the repo-specific traps.
---

# Theme authoring

`docs/THEMING.md` explains how a scheme reaches each app. This covers the part
that isn't written down: how to *choose* colours, what Patrick actually likes,
and the traps that cost real time.

## Work in OKLCh, never hex

Every question worth asking about a palette is arithmetic in OKLCh (perceptual
lightness, chroma, hue) and invisible in hex. "Is one accent louder than the
rest" is the standard deviation of chroma. "Do comments recede" is a contrast
ratio. "Can these two be told apart" is ΔE. Pick numbers, generate the hex.

**The spec is the source of truth.** `modules/theme/schemes/specs/<slug>.py`
holds the OKLCh values; the YAML and `.vim` are build outputs with a
`GENERATED` header. Never hand-edit them — change the spec and regenerate.

```bash
# generate / regenerate
python3 modules/theme/schemes/tools/mkscheme.py modules/theme/schemes/specs/slate-frappe.py

# verify the committed files still match the spec (exits non-zero on drift)
python3 modules/theme/schemes/tools/mkscheme.py modules/theme/schemes/specs/slate-frappe.py --check

# measure a scheme — contrast, accent uniformity, slot conventions,
# colour-vision safety, ANSI bright separation. Takes several to compare.
python3 modules/theme/schemes/tools/review.py base24/slate-frappe.yaml
```

`specs/slate-frappe.py` is the worked example and is commented accordingly.
Copy it to start a new scheme.

## Patrick's taste, as measured

Established over a long iteration that landed on `base24-slate-frappe`.

| | preference |
|---|---|
| polarity | dark only |
| ground | slate/desaturated blue, hue ~262. **Not** Frappe's indigo 275 — at 272 it still read as "just Frappe" |
| ground lightness | ~0.26. 0.22 collapsed to flat black; 0.30 was too close to Frappe |
| ground chroma | ~0.014. 0.011 read dead; 0.023 read as Frappe |
| accents | pastel — chroma ~0.096, below Frappe's 0.101 |
| whites | muted; body text ~9.2:1, not 11–12:1 |
| comments | must recede but stay readable |

Daily driver before this was `catppuccin-frappe`; also liked
`cerulean-signal-dark` and `ayu-mirage` but neither quite landed. Those three
are the taste anchors — and each has a measurable flaw worth knowing, because
"I like X but something's off" usually means one of these:

| scheme | the flaw, measured |
|---|---|
| catppuccin-frappe | comments 1.72:1 (vanish); accents flat at chroma 0.101; non-monotonic greyscale ramp |
| cerulean-signal-dark | comments 6.73:1 (shout); `base0E` chroma 0.199 vs 0.135 mean — one colour visibly louder |
| ayu-mirage | fg hue 95 on bg hue 267, a 172° clash; lime `base0B` at L 0.944 glares |

## Target bands

Starting points, not a passing grade. Derived from those three anchors, so
departing from them deliberately is normal — `slate-frappe` sits below the
accent-chroma floor on purpose, because pastel was the brief.

| property | target | why |
|---|---|---|
| bg lightness | 0.20–0.28 | |
| fg/bg contrast | 9–14:1 | |
| comment/bg contrast | **2.6–4.3:1** | below vanishes, above competes with code |
| accent chroma sd | < 0.022 | high sd = one colour pops out |
| accent lightness sd | < 0.045 | |
| min pairwise accent ΔE | **> 8.5** | below ~8 neighbouring accents blur |
| text-vs-syntax lightness gap | **> 0.02** | at 0 code differs from prose by hue alone and reads flat |
| fg↔bg hue delta | < 45° | avoids the ayu-mirage clash |

## Things that will bite you

**Flakes only read git-tracked files.** A new scheme must be `git add`ed before
nix can see it, or you get `error: opening file '<store>/base24/<slug>.yaml':
No such file or directory` — which looks like the override mechanism is broken
when it is just an untracked file.

**Desaturating shrinks separation.** ΔE between two hues is proportional to
chroma, so going pastel pulls neighbouring accents together. Every chroma
reduction needs hue and/or lightness gaps widened to compensate. Red/orange/
yellow are crowded into ~85° and break first.

**Lightness is the only channel that survives colour blindness.** Red/green
and yellow/green distinctions collapse to lightness under deuteranopia and
protanopia. If `review.py` flags a weak pair, fix it by separating lightness,
not hue. Rotating green toward cyan to help yellow/green will break
green/cyan — check the whole set after any hue move.

**Pastel fights hierarchy.** Raising accent lightness (pastel) while lowering
body-text lightness (muted whites) converges them. If the gap reaches ~0,
code stops standing out from prose. Darkening red is usually the cheapest fix:
it pulls the accent mean down *and* helps red/green colour-vision safety.

**sRGB cannot carry saturated light blues.** `mkscheme.py` reduces chroma and
preserves hue, reporting what it clipped. Expect `base12`/`base16`/`base17`
to clip; that is sRGB, not a bug. Watch for a slot whose *effective* chroma
rises when you lower a neighbour — it may simply have stopped clipping.

**`autocmds.lua` only lifts comments when the scheme needs it.** It blends
`base04`/`base05` for `@comment` *only* if `base03` is below 2.6:1 against
`base00` (catppuccin, ayu). A scheme that places `base03` deliberately is left
alone — without that gate, a well-calibrated `base03` gets dragged to ~8.5:1.
If comments look wrong, check that gate before touching the scheme.

**`base07` is where YAML/JSON/TOML keys land.** `autocmds.lua` promotes
`@property.<lang>` to `base07`, so it is deliberately brighter than body text.
Keep it clear of near-white or every data file glares — this repo is mostly
nix and YAML.

**`vim.cmd.colorscheme` gets the full scheme id.** `modules/nvim/default.nix`
passes `base24-<slug>`, including the prefix, so `g:colors_name` in the `.vim`
must match exactly. The template handles this; a hand-copied file will not.
(CLAUDE.md's claim that it uses `base16-<scheme>` is stale.)

**Both files or neither.** A YAML without its `.vim` breaks nvim's
`colorscheme` call; a `.vim` without its YAML leaves the rest of the system
unthemed. The generator always writes both.

## Choosing from upstream instead

571 schemes ship in `inputs.tinted-schemes`:

```bash
nix eval --impure --raw --expr \
  '(builtins.getFlake "git+file:///Users/phamann/.config/nixpkgs").inputs.tinted-schemes.outPath'
ls <that path>/base24 | sed 's/\.yaml$//'
```

Point `review.py` at any of them to measure before adopting. When this was
done exhaustively, only 8 of 430 dark schemes matched the taste profile *and*
fixed all three anchor flaws — and half of those were the GitHub Dark family.
Expect to generate rather than find.

**Score hue conformance, not just harmony.** `review.py` checks that `base08`
is actually red, `base0B` actually green, and so on. The best-scoring scheme
on pure perceptual metrics (`base16-blueish`) has a *bright green* in the red
slot, which renders every diff and error backwards.

## Workflow

1. Edit or copy a spec under `modules/theme/schemes/specs/`.
2. `mkscheme.py specs/<slug>.py`
3. `review.py base24/<slug>.yaml` — fix what it flags.
4. `git add` both generated files.
5. Set `modules.theme.scheme` in `hosts/<host>/home.nix`.
6. `make fmt && nix flake check`
7. `make <host>`, then `Cmd+Shift+,` in Ghostty to reload without restarting.

Iterate on the spec, not the output. When tuning against feedback like "too
bright", isolate the variable: change the ground alone, or the accents alone,
and render a side-by-side before committing to it.
