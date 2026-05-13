# ❄️ My Nix dotfiles

My multi-host, multi-arch dotfiles, powered by [nix](https://nixos.org/), [nix-darwin](https://github.com/nix-darwin/nix-darwin), [home-manager](https://github.com/nix-community/home-manager), and [flake-parts](https://flake.parts).

## Architecture

Four layers, each with one job:

| Layer        | Lives in                            | Job                                                                                       |
| ------------ | ----------------------------------- | ----------------------------------------------------------------------------------------- |
| **Flake**    | `flake.nix`, `flake/*.nix`          | Inputs + outputs (configurations, checks, formatter, dev shell, pre-commit) via flake-parts |
| **Profiles** | `profiles/*.nix`, `profiles/darwin/*.nix` | Role bundles (`dev-laptop`, `work-laptop`, `headless-server`; system-level `desktop`, `work`) |
| **Modules**  | `modules/<name>/`                   | Individual features as home-manager modules with `modules.<name>.enable`                  |
| **Hosts**    | `hosts/<name>/`                     | Hostname + profile imports + per-host overrides                                            |

Adding a new host = a 5–20 line file importing the right profile.

## Documentation

- [New machine setup + dev workflow](docs/SETUP.md)
- [Theming](docs/THEMING.md)

## Hosts

| Host   | Arch           | Type              | Profile          |
| ------ | -------------- | ----------------- | ---------------- |
| x-wing | aarch64-darwin | nix-darwin + HM   | dev-laptop       |
| r2-d2  | aarch64-darwin | nix-darwin + HM   | work-laptop      |
| yoda   | x86_64-linux   | standalone HM     | headless-server  |

## Folder structure

- `flake.nix` + `flake/` — composition (flake-parts modules: hosts, checks, treefmt, dev-shell, git-hooks, module publishing)
- `profiles/` — role bundles imported by HM hosts
- `profiles/darwin/` — system-level role bundles imported by nix-darwin hosts
- `modules/<name>/` — individual home-manager modules (each exposes `modules.<name>.enable`)
- `hosts/<name>/` — thin per-host deltas (hostname + profile imports + overrides)
- `lib/` — plain Nix helpers (not modules)
- `docs/` — documentation
- `plans/` — design docs
- `.github/workflows/` — CI (runs `nix flake check` on macOS + Linux)

## Common commands

```zsh
# Apply config for the current host
make x-wing   # or: make r2-d2 / make yoda

# Quality + iteration
make help     # list all targets
make fmt      # treefmt with nixfmt-rfc-style (RFC 166)
make check    # nix flake check — eval all hosts + treefmt + pre-commit
make update   # bump flake.lock

# Project-local dev shell (nixd, nixfmt-rfc-style, statix, deadnix)
nix develop
```

See [docs/SETUP.md §9](docs/SETUP.md) for the full dev workflow including the pre-commit setup caveat.

## CI

GitHub Actions runs `nix flake check` on `macos-14` and `ubuntu-24.04` for every push to main and every PR. The Linux runner is the only place yoda's `homeConfiguration` evaluates fully end-to-end (catppuccin per-app modules use IFD that can't be substituted from aarch64-darwin).

A separate lockfile job runs `DeterminateSystems/flake-checker-action` in report-only mode.

## External consumers

Each home-manager module is published as a flake output:

```nix
imports = [ inputs.dotfiles.homeManagerModules.<name> ];
```

19 modules. Some need extra `extraSpecialArgs` (e.g. `theme` needs `inputs.catppuccin`, `claude-code` needs `inputs.claude-code-nix` and `system`). See `flake/modules.nix`.

## Inspiration

- [mccurdyc/nixos-config](https://github.com/mccurdyc/nixos-config)
- [hercules-ci/flake-parts](https://github.com/hercules-ci/flake-parts)
- [The dendritic pattern (Discourse)](https://discourse.nixos.org/t/the-dendritic-pattern/61271)
