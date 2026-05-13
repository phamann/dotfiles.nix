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
- `catppuccin`, `claude-code-nix`, `rust-overlay`, `mkAlias`

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
  modules.theme.flavour = "mocha";
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

## Foot-guns and "things that changed"

These have all been deprecated/removed in earlier refactor phases — do NOT introduce them again:

- ~~`modules/default.nix`~~ — deleted. Profiles aggregate modules explicitly.
- ~~`modules.packages.additional-packages`~~ — removed. Append packages via `home.packages` in a profile or host directly.
- ~~`modules.gui`~~ — deleted. obsidian comes from the homebrew cask only.
- ~~`modules.zsh.work`~~ — removed. Work env vars live in `profiles/work-laptop.nix`.
- ~~`with lib;`~~ — replaced with `inherit (lib) ...;` across all modules.
- ~~`nixfmt-classic`, `nixpkgs-fmt`~~ — replaced by `nixfmt-rfc-style`.
- ~~`pkgs.stdenv.isDarwin`~~ — use `pkgs.stdenv.hostPlatform.isDarwin`.

## Cross-platform eval limitation

yoda's `homeConfiguration` cannot fully evaluate from aarch64-darwin locally — catppuccin per-app modules import TOML/JSON from x86_64-linux derivations that aarch64-darwin can't substitute. The Linux CI job is the real validation. Locally, `make r2-d2` / `make x-wing` cover the Macs.
