---
name: install-software
description: Install a piece of software on Patrick's machines declaratively through this nix-darwin / home-manager repo. Takes a software name, researches home-manager modules, nixpkgs (stable vs unstable), Homebrew casks/formulae and upstream, picks the most declarative channel, places it in the right module/profile, writes minimal config, runs make check, switches the current host and commits. Use whenever the user wants to install, add, set up, try out or "get" a CLI tool, macOS app, language package (npm/pip/cargo/go) or GitHub project on their machine, e.g. "/install-software btop", "can you install raycast", "add httpie", "I want to try out zellij", "get me the tailscale app", even if they don't mention nix, brew or home-manager.
---

# Install software

Turn "install X" into a commit Patrick would have written by hand. The result
should be minimal, follow the repo's conventions, sit in the right
module/profile, pass `make check`, be live on the current host, and be
committed on `main`.

The hard part is the judgement calls: which channel, which name is really the
app, which role it belongs to, and what config upstream needs that the module
doesn't write. Gather evidence first, then decide, then say what you decided
and why.

Read the repo's `CLAUDE.md` if it isn't already in context. Its module
conventions and "Foot-guns" list are binding.

## 1. Probe

```bash
python3 .claude/skills/install-software/scripts/probe.py <name> [alias ...]
```

Pass likely attribute paths and aliases as extra args, e.g.
`probe.py httpie python3Packages.httpie`, `probe.py prettier nodePackages.prettier`,
`probe.py zed zed-editor`, `probe.py tailscale tailscale-app`. Add `--search`
for a broad nixpkgs search when you don't know the attribute name (slow the
first time).

In one pass it reports, against the **pinned** flake inputs (so versions are
the ones a rebuild would install): matches already in the repo, home-manager
`programs.*`/`services.*` modules, stylix targets, stable and unstable nixpkgs
versions, and Homebrew cask/formula metadata.

**Already declared?** If the probe finds it in `modules/`, `profiles/`,
`hosts/` or as a flake input, say where and stop. Offer to change its
version or source instead of adding a duplicate.

**Names lie.** A name match isn't an identity match. nixpkgs `zed` is a data
lake (the editor is `zed-editor`), `tailscale` the cask is a different thing
from `tailscale-app`, and `notion-calendar` is only findable by its exact
token. Before choosing, confirm the candidate is the right software using its
description, homepage, `.app` name and publisher. When the probe leaves any
doubt, check upstream (web search / the vendor's install docs). If you still
can't confirm it, stop and show Patrick the candidates. A confident wrong
install is worse than a question.

Also read upstream's install and config docs for anything you'll write
config for. Use context7, or web fetch for READMEs. The home-manager module
often doesn't write everything the tool needs (see the rex example in
`references/templates.md`).

## 2. Choose the channel

Prefer the most declarative option that works. In order:

1. **home-manager module.** Use it when `programs.<x>` exists and the tool
   has config worth managing. Create a dedicated `modules/<name>/`. If stable
   is behind or broken, set `package = pkgs.unstable.<x>` with a comment
   saying why. If the app itself comes from a cask (GUI apps on macOS), set
   `package = null` and add the cask too. This is the ghostty/zed pattern.
2. **nixpkgs package.** Add it to a `modules/packages/<bucket>` list. Use
   `unstable.<x>` when stable is missing, too old for what Patrick wants, or
   broken on darwin, and comment why (see `unstable.d2`). A package only
   becomes a dedicated module when it needs config files or options.
3. **Homebrew cask** for macOS GUI apps, even when nixpkgs has them.
   nixpkgs GUI apps on darwin land outside /Applications, often lack
   signing, and don't self-update, so casks are the norm here. Use a
   **Homebrew formula** only when nixpkgs lacks it or the darwin build is
   broken. A CLI tool that's in both comes from nixpkgs.
4. **Custom derivation** in `modules/<name>/package.nix` via
   `pkgs.callPackage`, when nothing above has it. Prefer upstream's prebuilt
   release binaries (`modules/omp/package.nix` is the model). Fall back to
   `buildGoModule` / `buildRustPackage` / `buildNpmPackage` /
   `buildPythonApplication` from source.
5. **New flake input** when upstream ships a flake, especially one with
   `homeManagerModules` (rex is the model).

Language packages (npm, pip, cargo, go) aren't installed with their own
package managers. Look for them in nixpkgs first: top-level attrs,
`python3Packages.*`, `nodePackages.*` (shrinking; many tools are now
top-level). If they're missing, build them (option 4).

`references/channels.md` has the detail for each channel: cask verification,
language-ecosystem lookups, fetching hashes for custom derivations, adding a
flake input.

## 3. Place it

Infer the role and tell Patrick what you picked and why. Don't ask. Hosts:
**r2-d2** is the work Mac, **x-wing** the personal Mac, and **yoda** a
headless x86_64-linux box (no GUI; anything in a shared bucket must evaluate
there).

| What it is | Where it goes |
|---|---|
| Universal CLI utility, useful on every host incl. yoda | `modules/packages/cli` (enabled by `profiles/base.nix`) |
| Language toolchain, LSP, linter, formatter, build tool | `modules/packages/dev` |
| Kubernetes tooling | `modules/packages/k8s` |
| incident.io-specific tooling | `modules/packages/work` |
| Configurable tool with an HM module | new `modules/<name>/`, imported and enabled in the narrowest profile that fits: `base.nix` (everywhere), `dev-laptop.nix` (both Macs), `headless-server.nix` (yoda), `work-laptop.nix` (r2-d2 only) |
| macOS GUI app, personal or shared | cask in `profiles/darwin/homebrew.nix`. Personal apps are fine on the work Mac; there's no personal darwin profile. |
| macOS GUI app, work only | cask in `profiles/darwin/work.nix` |
| darwin-only CLI in a shared bucket | `++ optionals isDarwin [ ... ]` (see `modules/packages/cli`) |

Use `hosts/<host>/home.nix` only when it's really one machine.

## 4. Write the minimal config

Templates for each shape are in `references/templates.md`. Ground rules:

- Follow the repo's module pattern: `inherit (lib) ...;` (never `with lib;`),
  `cfg = config.modules.<name>;`, and `pkgs.stdenv.hostPlatform.isDarwin`.
  Don't take lambda args you don't use, because deadnix fails the check.
  Prefer `settings = { ... }` over `extraConfig` strings.
- **Minimal means working, not bare.** Write what upstream needs to
  function: required config files (`xdg.configFile`), integration the
  module skips, `package = null` when a cask supplies the app. Leave out
  personal preferences Patrick didn't ask for.
- **Theming:** if the probe lists a stylix target, enable
  `stylix.targets.<x>.enable = true`. Otherwise don't invent theming; list
  it as a follow-up.
- **Lists:** casks and package lists are append-only in spirit. Insert in
  alphabetical order under the right sub-heading comment, and never remove
  or reorder other entries. `homebrew.onActivation.cleanup = "zap"`
  uninstalls *and deletes the data of* anything that drops off the cask
  list.
- **Comments** explain why, at the density of the surrounding code: why
  unstable, why `package = null`, why a custom derivation exists and how to
  bump it.
- **New files must be tracked.** Flakes only see git-tracked files, so
  `git add` any new `modules/<name>/` before `make check`. Otherwise
  evaluation fails with a confusing "path does not exist".
- New modules that should be consumable externally also get a line in
  `flake/modules.nix`. Look at what's there and follow suit.

## 5. Verify, commit, switch

Work happens on `main` in the main checkout (`~/.config/nixpkgs`). That's
where `make <host>` builds from. A switch from a side branch would be undone
by the next ordinary `make <host>`, and `zap` would then delete the app and
its data.

- **In the main checkout on `main`:** work in place.
- **In a worktree or on another branch:** do the edits and checks there,
  commit, then land that one commit on `main` with
  `git -C ~/.config/nixpkgs merge --ff-only <sha>` (or `cherry-pick <sha>`
  if `main` has moved). Never a merge commit. If the main checkout has
  uncommitted changes to the files you touched, stop and ask.

Then:

1. `make fmt`
2. `make check`. Fix failures you caused. For upstream build breakage
   (darwin test failures, rustc `deny(warnings)`), check Patrick's memory
   notes, and stop if the fix would reach into unrelated modules.
3. Build the current host without sudo:
   `darwin-rebuild build --flake .#<host>` (Macs) or
   `home-manager build --flake .#phamann@yoda`. Use `hostname -s`; it
   matches the flake's host names (`scutil --get LocalHostName` doesn't).
   Delete the `result` symlink afterwards.
4. **Commit** once the build passes. Use a conventional commit naming the
   tool and channel, e.g. `feat(btop): install btop via home-manager` or
   `feat(homebrew): add raycast cask`. Explain non-obvious choices (unstable
   pin, custom derivation) in the body, and add the session's attribution
   trailer. Don't push.
5. **Switch** with `make <host>` from `~/.config/nixpkgs`. It runs
   `sudo darwin-rebuild switch`. If `sudo -n true` fails (no cached
   credentials), don't try to work around it. Report "built and committed,
   not yet switched" and give Patrick `! make <host>`.
6. **Smoke test** after the switch: `command -v <bin> && <bin> --version`,
   `ls -d "/Applications/<App>.app"` for casks, and the config file landed
   where upstream expects it.

**If the placement doesn't include the current host** (e.g. a work-only cask
added from x-wing): still write it, check it, build the host that gets it if
that's possible locally, and commit. Skip the switch and say which host to
rebuild.

## 6. Report

Keep it short:

- **What and how:** the channel chosen and the runner-up it beat, with the
  deciding evidence (versions, cask identity, module availability).
- **Where:** files touched, and the profile/role chosen and why.
- **Status:** check / build / switch / smoke-test results, plus the commit
  sha. If not switched, the exact command to run.
- **Follow-ups:** login/auth steps, licence keys, macOS permissions,
  theming that wasn't automatic, manual app settings.

## Out of scope

Uninstalling (it needs its own zap-aware flow), bumping existing flake inputs
or `make update`, and pushing or opening PRs. If asked for one of these
alongside an install, do the install and say the rest is a separate job.
