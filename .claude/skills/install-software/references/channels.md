# Channel research details

Read the section for the channel you're weighing. `scripts/probe.py` covers
the common lookups; this is for when it doesn't settle the question.

## Contents

- [home-manager modules](#home-manager-modules)
- [nixpkgs: stable vs unstable](#nixpkgs-stable-vs-unstable)
- [Homebrew casks and formulae](#homebrew-casks-and-formulae)
- [Language ecosystems](#language-ecosystems)
- [Custom derivations](#custom-derivations)
- [New flake inputs](#new-flake-inputs)

## home-manager modules

The probe prints the module's source path in the pinned home-manager input.
Read it to find the option names (`settings`, `extraConfig`, `package`,
`enable*Integration`) and what it writes to disk:

```bash
less /nix/store/<hash>-source/modules/programs/<name>.nix
```

Module names don't always match the package (`zed-editor`, `gh` vs
`gh-dash`). The probe lists "similar" modules when there's no exact match.

Upstream projects sometimes ship their own HM module in their flake
(`homeManagerModules.default`). That's the rex/omp pattern; see
[New flake inputs](#new-flake-inputs).

What the HM module doesn't do still needs doing. Compare upstream's
"configuration" docs with what the module writes. Common gaps are extra files
under `~/.config/<tool>/`, a reload after config changes, shell integration,
and a theme file.

## nixpkgs: stable vs unstable

`pkgs.<x>` is stable (nixpkgs-26.05-darwin) and `pkgs.unstable.<x>` is
nixpkgs-unstable, via the overlay in `flake.nix`.

Use **unstable** when:
- stable doesn't have it at all, or
- stable's version lacks something Patrick wants or needs, or upstream
  calls it badly outdated, or
- stable's darwin build is broken.

Say which in a comment. Existing examples are `unstable.d2` in
`modules/packages/dev` and `package = pkgs.unstable.zellij`.

The reverse also happens: `colima` is pinned to *stable* in
`profiles/dev-laptop.nix` because unstable had no cached darwin build. If an
unstable build would compile from source for a long time, prefer stable and
say so.

To check darwin support before building, look at `meta.platforms` in the
package's source. Clues are the probe's description line and a search of
`pkgs/by-name/<2 letters>/<name>/package.nix` in the pinned nixpkgs. Or just
let `darwin-rebuild build` tell you.

Unfree packages are fine: `allowUnfree = true` is set for both package sets.

## Homebrew casks and formulae

Prefer casks for macOS GUI apps. Verify identity before adding one:

```bash
HOMEBREW_NO_AUTO_UPDATE=1 brew info --json=v2 --cask <token>   # name, homepage, .app, desc
HOMEBREW_NO_AUTO_UPDATE=1 brew search <word>                   # nearby tokens
```

Check that:
- the homepage is the vendor's real domain
- the `.app` artifact is the app Patrick means
- it's not `deprecated`/`disabled`
- for apps with editions (`@beta`, `@preview`, `-app` vs CLI), you picked
  the stable edition unless asked otherwise.

Known traps:
- `tailscale` vs `tailscale-app`: the GUI app is `tailscale-app`.
- `notion-calendar` doesn't show up when you search "notion calendar".
- nixpkgs names can collide with unrelated software (nixpkgs `zed` is a
  data lake).

When the vendor's site documents a Homebrew install, that's the strongest
evidence. Search the web for `<app> homebrew cask` when the probe is
ambiguous.

**Taps:** a cask or formula from a third-party tap needs the tap declared
with `trusted = true` in `profiles/darwin/homebrew.nix` (Homebrew requires tap
trust), and a fully qualified name (`owner/tap/name`). Follow the
`felipeelias/tap` entry.

**Formulae** are a last resort for CLI tools: only when nixpkgs lacks the
tool or its darwin build is broken. Work-only services like `postgresql@17`
are the precedent in `profiles/darwin/work.nix`.

**Mac App Store apps** (`masApps`) aren't used in this repo. If an app is
only on the App Store, say so and ask before adding `mas` support.

## Language ecosystems

Look in nixpkgs first. The probe accepts attribute paths, so pass them
directly:

| Ecosystem | Try |
|---|---|
| npm | top-level `<name>` (most CLI tools moved out of `nodePackages`), `nodePackages.<name>` |
| pip | top-level `<name>` (applications), `python3Packages.<name>` (libraries, and some CLIs) |
| cargo | top-level `<name>`, sometimes `<name>-cli` |
| go | top-level `<name>` |

For a Python *application*, add the top-level attr. Don't build a whole
`python3.withPackages` env unless the user wants a library for scripting.

If it's not in nixpkgs, write a derivation (next section). Don't fall back to
`npm i -g` / `pip install --user` / `cargo install`. That state lives outside
nix, and the next machine won't have it.

## Custom derivations

Lives in `modules/<name>/package.nix` and is wired up with
`pkgs.callPackage ./package.nix { }`. It either goes into `home.packages` or
becomes the `package` of an HM module.

**Prebuilt release binaries (preferred).** These need no compile and no
toolchain. Follow `modules/omp/package.nix`:

- a header comment covering why it isn't from nixpkgs, an upstream tracking
  issue if there is one, and exact bump instructions
- per-system asset + SRI hash, `stdenvNoCC.mkDerivation`, `fetchurl`, and
  `autoPatchelfHook` on Linux
- `meta.platforms` listing only the systems that have assets.

Get SRI hashes without `nix eval`:

```bash
nix store prefetch-file --json <url> | python3 -c 'import json,sys;print(json.load(sys.stdin)["hash"])'
# or convert a published sha256:
nix hash convert --hash-algo sha256 --to sri <hex>
```

**From source.** Use `buildGoModule` (`vendorHash`), `buildRustPackage`
(`cargoHash`), `buildNpmPackage` (`npmDepsHash`) or
`python3Packages.buildPythonApplication` (`pyproject = true`). Use
`fetchFromGitHub` for `src`. For dependency hashes, put `lib.fakeHash`, run
the build, and copy the hash from the error. A from-source build that takes
many minutes is a reason to stop and check with Patrick (see SKILL.md).

## New flake inputs

When upstream ships a flake, especially with `homeManagerModules`:

1. Add the input to `flake.nix` with a short comment saying what it's for.
   Add `inputs.nixpkgs.follows = "nixpkgs"` unless upstream needs its own
   nixpkgs.
2. Run `nix flake lock` to add just that input. **Don't** run `make update`,
   which bumps everything.
3. Import the module inside `modules/<name>/default.nix`:
   `imports = [ inputs.<name>.homeManagerModules.default ];` (`inputs`
   reaches modules via `extraSpecialArgs`; see `modules/rex`).
4. Note the extra input in `flake/modules.nix`'s header comment.

Check upstream's flake outputs first with `nix flake show <url>`, since some
only export packages. If upstream has a binary cache, mention it, but don't
add substituters without asking.
