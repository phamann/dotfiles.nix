# `install-software` skill — design

## Intent

Patrick regularly installs new software on his machines. Doing it
declaratively in this repo means a run of judgement calls: which
distribution channel, whether a home-manager module exists, whether stable
nixpkgs is new enough, which cask name is really the app, which profile it
belongs on, and what config the upstream module doesn't write. The skill
encodes those calls so `/install-software <name>` goes from a name to a
switched, committed machine with the config written the way Patrick would
have written it.

Success: the result looks like a commit Patrick would have made by hand.
It is minimal, follows CLAUDE.md conventions, sits in the right
module/profile, passes `make check`, and is live on the current host.

## Goals

- Take one argument: a software name (free text, e.g. `rex`,
  `notion calendar`, `ripgrep`, `@scope/some-cli`).
- Research every candidate channel and pick the most declarative one that
  works.
- Infer which role/profile the software belongs on, and say what it chose
  and why.
- Write the minimal working config following repo conventions.
- `make fmt` → `make check` → switch the current host → conventional commit.

## Non-goals (confirmed by Patrick)

- Uninstalling or removing software (a separate, riskier flow because of
  `homebrew.onActivation.cleanup = "zap"`).
- Bumping existing flake inputs or `make update`.
- Pushing or opening PRs. It commits on the current branch only.
- Heavy customisation beyond "minimal working". Theming and integrations
  are added only where upstream needs them to work or the repo pattern is
  cheap (see below).

## Anti-goals

- Picking the wrong cask or package because the name looked close. A
  confident wrong install is worse than stopping to ask.
- Reintroducing anything in CLAUDE.md's "Foot-guns" list (`with lib;`,
  `pkgs.stdenv.isDarwin`, `modules/opencode`, catppuccin inputs, etc.).
- Editing the cask/brew lists other than appending, since `zap` uninstalls
  anything removed.
- Committing a change that hasn't built.

## Decision procedure

### 0. Already installed?

Grep `modules/`, `profiles/`, `hosts/` and `flake.nix` inputs for the name
and likely aliases. If it is already declared, report where and stop,
offering to change its version/source instead.

### 1. Research (in order, collecting evidence)

1. **home-manager module**: is there a `programs.<x>` / `services.<x>`
   option? (HM options search / `home-manager` docs; context7.)
2. **Upstream flake** with `homeManagerModules` (rex pattern) or packages.
3. **nixpkgs**: `nix search nixpkgs#…` against both the stable (26.05) and
   unstable inputs. Compare versions with upstream's latest release.
4. **Homebrew**: `brew search` + `brew info --cask --json=v2` /
   `brew info --json=v2`. Verify cask identity against the vendor
   homepage, the `.app` name and the publisher (web search when ambiguous;
   e.g. `tailscale-app` vs `tailscale`, `notion-calendar`).
5. **Language ecosystems** (npm, pip, cargo, go): first look for the
   package in nixpkgs (`nodePackages`, `python3Packages`, top-level
   attrs). Only then consider building it.
6. **Upstream release / source**: prebuilt release binaries, or source.

### 2. Choose the form (preference order, confirmed by Patrick)

1. **HM module**, as a dedicated `modules/<name>/default.nix` using the
   module pattern. If the HM module's package is stale, set
   `package = pkgs.unstable.<x>` (pi/zellij pattern). If the app itself
   comes from a cask, set `package = null` (ghostty/zed pattern) and add
   the cask.
2. **nixpkgs package** (stable; `unstable.<x>` when stable is missing,
   too old, or broken on darwin), added to the right
   `modules/packages/<bucket>` list. Promote it to a dedicated module only
   when it needs config files or options.
3. **Homebrew cask** for macOS GUI apps (nixpkgs GUI apps on darwin are
   often unsigned/unupdated and won't sit in /Applications properly). A
   Homebrew formula only when nixpkgs doesn't have it or the darwin build
   is broken.
4. **Custom derivation** under `modules/<name>/package.nix`, called via
   `pkgs.callPackage`. Prefer upstream prebuilt binaries
   (`modules/omp/package.nix` is the template: per-system `fetchurl`, SRI
   hashes, header comment explaining why it exists and how to bump).
   Building from source with `buildGoModule`/`buildRustPackage`/
   `buildNpmPackage`/`buildPythonApplication` is a fallback.
5. **New flake input** when upstream ships a flake, and especially when
   it ships a HM module.

GUI app that is also in nixpkgs → cask on macOS. CLI tool in both brew and
nixpkgs → nixpkgs.

### 3. Placement (inferred, reported)

| Signal | Lands in |
|---|---|
| Universal CLI utility, useful on every host incl. yoda | `modules/packages/cli` (base) |
| Language toolchain / LSP / linter / build tool | `modules/packages/dev` |
| Kubernetes tooling | `modules/packages/k8s` |
| incident.io-specific CLI | `modules/packages/work` |
| Configurable tool with a HM module | new `modules/<name>`, imported + enabled in the narrowest profile that fits (`base` / `dev-laptop` / `headless-server` / `work-laptop`) |
| macOS GUI app, personal + work, or personal-only | cask in `profiles/darwin/homebrew.nix` (Patrick: personal apps are fine on the work Mac; no personal darwin profile) |
| macOS GUI app, work only | cask in `profiles/darwin/work.nix` |
| darwin-only CLI in a shared bucket | `optionals isDarwin [...]` |

Host-level placement (`hosts/<name>/home.nix`) only when it is really one
machine. Hosts: r2-d2 = work Mac, x-wing = personal Mac, yoda =
headless x86_64-linux (no GUI, must evaluate on Linux).

### Where the skill works (decided by Patrick)

The skill always edits, commits and switches from the main checkout
(`~/.config/nixpkgs`) on `main`. This keeps the live system and `main` in
step: a switch from a side branch would be silently undone by the next
`make <host>` from main, and `zap` would then uninstall the app, data
included.

- In the main checkout on `main`: work in place.
- In a worktree or on another branch: write and build there, commit, then
  bring that one commit onto `main` with `git -C ~/.config/nixpkgs merge
  --ff-only <sha>` or `cherry-pick <sha>`. Never a merge commit. Then
  switch from `~/.config/nixpkgs`.
- If `main` in the main checkout has uncommitted changes to files the
  skill touches, stop and ask rather than mixing them in.

Because the switch always runs from `~/.config/nixpkgs` on `main`,
`make <host>` is correct to use for the switch.

### 4. Write minimal config

- CLAUDE.md conventions: `inherit (lib) …`, `cfg = config.modules.<name>`,
  no unused lambda args (deadnix), `pkgs.stdenv.hostPlatform.isDarwin`,
  `settings = {}` over `extraConfig` strings.
- Read the upstream docs for required config. Write config files with
  `xdg.configFile` / `home.file` when the HM module doesn't (rex pattern).
- Theming: when a `stylix.targets.<x>` exists, enable it. Otherwise
  leave theming out and mention it as a follow-up.
- Comments explain *why* (pinning to unstable, `package = null`, why a
  custom derivation exists), matching the existing comment density.
- Package lists: insert under the right sub-heading comment, in
  alphabetical order.

### 5. Verify

1. `make fmt`
2. `make check`. On failure, diagnose (memory notes on darwin test
   failures and rustc `deny(warnings)` apply) and fix within reason.
3. Detect the current host from `scutil --get LocalHostName` / `hostname`.
   Build first without sudo:
   `darwin-rebuild build --flake .#<host>` (or
   `home-manager build --flake .#phamann@yoda`).
4. Commit once the build passes (see 6). That meets "never commit
   something that hasn't built".
5. Switch with `make <host>` (from `~/.config/nixpkgs` on `main`). If
   `sudo -n true` fails (no cached credentials), don't try to work around
   it. Hand Patrick `! make <host>` and report "built and committed, not
   yet switched". (Claude's call.)
6. Smoke test after the switch: `command -v <bin>` / `<bin> --version`,
   or check that `/Applications/<App>.app` exists for casks.

**When the placement doesn't cover the current host** (e.g. a work-only
cask added while on x-wing): still write, check, build the host that
*does* get it if that is possible locally, and commit. Skip the switch
and say which host to rebuild. (Claude's call.)

### 6. Commit

Conventional commit on `main`, e.g.
`feat(<name>): install <name> via home-manager`. Use the attribution
trailer per session instructions. No push.

### 7. Report

Report the form chosen and the runner-up, the evidence (versions, cask
identity), the files touched, the profile chosen and why, verification
results, and any follow-ups (theming, auth/login steps, manual app
settings).

## When to stop and ask

- No candidate can be verified as the right software (ambiguous name,
  conflicting casks).
- (Unfree is not a stop: `allowUnfree = true` is set in `flake.nix` and
  `profiles/darwin/system.nix`. Mention it in the report.)
- Shared `cli` bucket packages must support x86_64-linux for yoda (only
  CI evaluates yoda). Check `meta.platforms` and gate with
  `optionals isDarwin` where needed.
- The only route is a from-source build that would take a long time or
  needs a new flake input with heavy transitive inputs.
- A build fails and the fix would touch unrelated modules.

## Packaging of the skill

- Location: `.claude/skills/install-software/SKILL.md`, next to
  `theme-authoring`. It is project-scoped and committed.
- Long-form reference split into `references/` (channel research
  commands, placement table, templates for module / package-list /
  cask / custom derivation) to keep `SKILL.md` lean.
- Built with `anthropic-skills:skill-creator`, including a few eval
  prompts (e.g. a HM-module tool, an ambiguous cask, an npm-only CLI, an
  already-installed package).

## Left to the builder

- Exact wording/structure of SKILL.md and references.
- Which research commands to script vs leave as instructions.
- Eval set details.
