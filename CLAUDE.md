# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Overview

Nix flake-based dotfiles. Composed via **flake-parts**, with **nix-darwin** for macOS system config, **home-manager** for the user environment, and a **profile layer** that bundles per-role module enables.

## Common commands

```bash
# Bump flake.lock
make update

# Rebuild for the current host
make x-wing       # macOS (aarch64-darwin)
make r2-d2        # macOS (aarch64-darwin)
make yoda         # Linux (x86_64-linux, standalone HM)

# Quality
make fmt          # nix fmt (treefmt + nixfmt-rfc-style)
make check        # nix flake check (eval-host + treefmt + pre-commit)
make help         # list all targets
nix develop       # dev shell: nixd, nixfmt-rfc-style, statix, deadnix
```

## Architecture

### Layers

```
flake.nix + flake/*.nix    ← composition (flake-parts mkFlake)
        │
        ▼
profiles/*.nix             ← role bundles: dev-laptop, work-laptop, headless-server
profiles/darwin/*.nix      ← system-level bundles: desktop, work
        │
        ▼
modules/<name>/            ← individual feature modules (HM)
        │
        ▼
hosts/<name>/              ← hostname + profile imports + deltas
```

Each layer has one job. Adding a host = ~10-line file importing the right profile.

### Flake-parts outputs

`flake.nix` is thin: declares inputs, calls `flake-parts.lib.mkFlake`, imports flake-modules from `flake/`:

- `flake/hosts.nix` — `flake.darwinConfigurations` + `flake.homeConfigurations`
- `flake/modules.nix` — `flake.homeManagerModules.<name>` outputs (external consumption)
- `flake/treefmt.nix` — `nix fmt` config (nixfmt-rfc-style)
- `flake/checks.nix` — `checks.<system>.eval-<host>` per host
- `flake/dev-shell.nix` — `devShells.default`
- `flake/git-hooks.nix` — pre-commit (statix + deadnix + treefmt) via `cachix/git-hooks.nix`

### Flake inputs

- `nixpkgs` (25.11-darwin) + `nixpkgs-unstable` (accessible as `pkgs.unstable.*` via overlay)
- `flake-parts` — output composition
- `darwin` (`github:nix-darwin/nix-darwin`), `home-manager`
- `treefmt-nix`, `git-hooks` (cachix/git-hooks.nix)
- `stylix` + `tinted-schemes` — theming (see [Theming](#theming))
- `claude-code-nix`, `rust-overlay`, `mkAlias`

### Profile pattern

A profile is a home-manager module that:

1. Imports the individual modules it needs (the modules' option declarations land in scope).
2. Sets `modules.<name>.enable = true` for the ones to activate.
3. Optionally adds `home.packages` / `home.sessionVariables` / `home.sessionPath` directly.

Inheritance via `imports`:

```
profiles/base.nix
  ↓
profiles/dev-laptop.nix
  ↓
profiles/work-laptop.nix
```

```
profiles/darwin/desktop.nix
  ↓
profiles/darwin/work.nix
```

### Module pattern

```nix
{ pkgs, lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.<name>;
in {
  options.modules.<name> = {
    enable = mkEnableOption "<name>";
  };

  config = mkIf cfg.enable {
    programs.<name>.enable = true;
    # ...
  };
}
```

Rules:

- **No `with lib;`** — use `inherit (lib) ...;` explicitly.
- **`cfg = config.modules.<name>`** is the canonical alias. statix's `manual_inherit` (W04) is disabled repo-wide via `.statix.toml` to allow this idiom.
- **Platform-aware** modules use `mkMerge [ shared (mkIf isDarwin {...}) (mkIf (!isDarwin) {...}) ]`.
- **`inherit (pkgs.stdenv.hostPlatform) isDarwin;`** — NOT the deprecated `pkgs.stdenv.isDarwin` alias.
- **deadnix is strict** — unused lambda params (`pkgs` etc.) will fail the pre-commit check. Drop them.
- **`programs.<x>.settings = { ... }`** is preferred over the older `extraConfig = "..."` strings where the HM module supports it.

### Host pattern

Hosts are now thin deltas. Example (`hosts/r2-d2/home.nix`):

```nix
_: {
  imports = [ ../../profiles/work-laptop.nix ];
  modules.theme.scheme = "catppuccin-mocha";
}
```

Darwin hosts also have `hosts/<name>/configuration.nix` (system-level) that imports a `profiles/darwin/*.nix`.

### Key directories

- `flake.nix` + `flake/` — composition (flake-parts)
- `profiles/` — HM role bundles
- `profiles/darwin/` — nix-darwin system role bundles
- `modules/<name>/` — individual HM feature modules
- `hosts/<name>/` — hostname + profile imports
- `lib/` — plain Nix helpers (not modules)
- `docs/` — documentation
- `plans/` — design docs
- `.github/workflows/` — CI

## Working in this repo

- Always `nix fmt` (or commit and let pre-commit catch it).
- `nix flake check` is the gate — it must pass before pushing.
- Pre-commit is wired but NOT auto-installed because `core.hooksPath = ~/.git-hooks` is set globally; a naive `pre-commit install` would pollute every repo on the machine. To enable per-commit enforcement locally: `git config --local --unset core.hooksPath && pre-commit install` inside `nix develop`.
- CI on GitHub Actions runs `nix flake check` on macos-14 + ubuntu-24.04 for every PR.

## Theming

A single base24 colour scheme drives every themed app. Detailed reference in [`docs/THEMING.md`](./docs/THEMING.md); summary:

- **Entry point**: `modules.theme.scheme` (a base24 scheme name from `tinted-theming/schemes/base24/`, e.g. `"catppuccin-macchiato"`) + `modules.theme.polarity` (`"dark"` / `"light"`). Set per-host in `hosts/<host>/home.nix`.
- **Consumption patterns**:
  1. **Stylix targets**: `stylix.targets.<x>.enable = true;` inside a module. Stylix handles the app from there. Used for bat, fzf, starship, zed, ghostty, zellij, opencode, neovim, delta (via bat's tmTheme).
  2. **Hand-templated configs**: `pkgs.replaceVars` with `config.modules.theme.semantic.<role>`. `semantic` exposes role-named `#rrggbb` strings (`primary`, `success`, `accent`, `warning`, `accentAlt`, `bg`, `fg`, …). Used for claude-statusline. See `modules/claude-code/default.nix`.
  3. **nvim lua overrides**: `vim.g.stylix_palette` is the full base24 palette (`base00`–`base17`) templated into `init.lua` at build time. Reference slots directly via `p.base0X` in `nvim_set_hl` calls. Used in `modules/nvim/config/lua/autocmds.lua` (`UIHighlights` augroup) and per-plugin specs.

### Theming gotchas

- **Stylix's neovim plugin needs a lazy.nvim spec with `lazy = false, priority = 1000`** (see `modules/nvim/config/lua/plugins/base16.lua`). Lazy's default `performance.rtp.reset = true` clears nvim's packpath at `lazy.setup()`, so Stylix's appended `require('base16-colorscheme').setup({...})` would fail without lazy also installing the plugin into its own runtime path.
- **base16-nvim is spec-faithful, not aesthetic.** We deliberately deviate from the base16 spec for several treesitter captures so the rendered code matches what most polished themes (catppuccin, tokyonight) actually do: `@variable` / `@lsp.type.variable` recessed to `base05`, `@punctuation.{delimiter,special}` recessed to `base05`. Barbecue's LSP context kinds are aligned to base16-nvim's *treesitter* mappings (which themselves deviate from spec for `@namespace`), not the spec table. These overrides live in `modules/nvim/config/lua/autocmds.lua` and `modules/nvim/config/lua/plugins/barbecue.lua`. Add to those when you find another spec-vs-aesthetic mismatch.
- **Highlight group naming inconsistency**: most plugins use `PluginNameFoo` (PascalCase) but barbecue uses `plugin_name_foo` (lowercase). Always `grep` for `nvim_set_hl` in the plugin's source before writing overrides — `nvim_set_hl` succeeds for non-existent group names without complaint, so a typo or case mismatch silently does nothing.

## Foot-guns and "things that changed"

These have all been deprecated/removed in earlier refactor phases — do NOT introduce them again:

- ~~`modules/default.nix`~~ — deleted. Profiles aggregate modules explicitly.
- ~~`modules.packages.additional-packages`~~ — removed. Append packages via `home.packages` in a profile or host directly.
- ~~`modules.gui`~~ — deleted. obsidian comes from the homebrew cask only.
- ~~`modules.zsh.work`~~ — removed. Work env vars live in `profiles/work-laptop.nix`.
- ~~`with lib;`~~ — replaced with `inherit (lib) ...;` across all modules.
- ~~`nixfmt-classic`, `nixpkgs-fmt`~~ — replaced by `nixfmt-rfc-style`.
- ~~`pkgs.stdenv.isDarwin`~~ — use `pkgs.stdenv.hostPlatform.isDarwin`.
- ~~`inputs.catppuccin`~~ — removed. Theming is Stylix + `tinted-theming/schemes` (`inputs.stylix` + `inputs.tinted-schemes`).
- ~~`modules.theme.flavour` / `lightFlavour` / `accent` / `palette`~~ — removed. Use `modules.theme.scheme` (base24 scheme name) and `modules.theme.semantic.<role>` (role-named hex API).
- ~~`catppuccin.<app>.enable`~~ — removed. Use `stylix.targets.<app>.enable` instead.
- ~~`home.sessionVariables.CATPPUCCIN_*`~~ — removed. nvim reads `vim.g.stylix_palette` (templated into init.lua at build time), not env vars.
- ~~`modules/alacritty`, `modules/kitty`, `modules/tmux`~~ — deleted. zellij + ghostty cover the workflow.

## Cross-platform eval limitation

yoda's `homeConfiguration` cannot fully evaluate from aarch64-darwin locally — some derivations Stylix and other inputs pull in are x86_64-linux-only and can't be substituted on darwin. The Linux CI job (`.github/workflows/check.yml`) closes this gap. Locally, `make r2-d2` / `make x-wing` cover the Macs.
