# Templates

Copy the shape, not the comments. Write comments that explain *this*
install. All of these follow `CLAUDE.md`'s module rules. Only take lambda
args you use (deadnix fails the check otherwise).

## Contents

- [Package in a bucket](#package-in-a-bucket)
- [Dedicated HM module](#dedicated-hm-module)
- [HM module + cask (`package = null`)](#hm-module--cask-package--null)
- [HM module pinned to unstable](#hm-module-pinned-to-unstable)
- [Config the HM module doesn't write](#config-the-hm-module-doesnt-write)
- [Enabling a new module in a profile](#enabling-a-new-module-in-a-profile)
- [Cask / formula](#cask--formula)
- [Custom derivation wired into a module](#custom-derivation-wired-into-a-module)

## Package in a bucket

Insert alphabetically under the matching sub-heading in
`modules/packages/<bucket>/default.nix`:

```nix
      # core CLI utilities
      coreutils
      dig
      dust          # <- new
      fd
```

With unstable, give the reason:

```nix
      # 0.9.0 adds <thing Patrick needs>; stable is still 0.7.1.
      # Drop back to `<name>` once stable catches up.
      unstable.<name>
```

## Dedicated HM module

`modules/<name>/default.nix`, the k9s shape:

```nix
{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.<name>;
in
{
  options.modules.<name> = {
    enable = mkEnableOption "<name>";
  };
  config = mkIf cfg.enable {
    programs.<name> = {
      enable = true;
      settings = {
        # only what upstream needs to work, or what Patrick asked for
      };
    };
    stylix.targets.<name>.enable = true; # only if the probe found a target
  };
}
```

Then:
- `git add modules/<name>`
- import and enable it in the profile (below)
- add `<name> = ../modules/<name>;` to `flake/modules.nix`, in
  alphabetical order.

## HM module + cask (`package = null`)

For GUI apps where the `.app` comes from Homebrew but HM manages the config
(ghostty, zed):

```nix
    programs.<hm-name> = {
      enable = true;
      # The app comes from the `<cask>` cask (profiles/darwin/homebrew.nix);
      # HM only manages the config directory.
      package = null;
      settings = { ... };
    };
```

Add the cask as well. Both edits go in the same commit.

## HM module pinned to unstable

```nix
    programs.<name> = {
      enable = true;
      # Stable ships <old>; <new> fixes <reason>. Back to the default once
      # stable catches up.
      package = pkgs.unstable.<name>;
    };
```

Add `pkgs` to the lambda args when you use it.

## Config the HM module doesn't write

This is the rex lesson: read upstream's docs for files the tool expects that
the HM module doesn't create.

```nix
    # <tool> reads themes from ~/.config/<tool>/themes; the HM module only
    # writes config.toml.
    xdg.configFile."<tool>/themes/stylix.toml".text = ''
      ...
    '';
```

If the tool doesn't watch its config, add a reload that can't fail the
switch:

```nix
    home.activation.<name>Reload = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      if ${lib.getExe config.programs.<name>.package} status >/dev/null 2>&1; then
        run ${lib.getExe config.programs.<name>.package} reload || warnEcho "<name> reload failed"
      fi
    '';
```

When the tool ships a Claude Code integration (MCP server, skill, hooks),
wire it under `mkIf config.programs.claude-code.enable { ... }` as
`modules/rex` does, but only if Patrick wants it. Otherwise list it as a
follow-up.

## Enabling a new module in a profile

```nix
  imports = [
    ./base.nix
    ../modules/claude-code
    ../modules/<name>     # <- alphabetical
    ...
  ];

  modules = {
    claude-code.enable = true;
    <name>.enable = true; # <- alphabetical
    ...
  };
```

## Cask / formula

`profiles/darwin/homebrew.nix` (shared) or `profiles/darwin/work.nix`
(work only). Insert alphabetically and never remove entries, because
`cleanup = "zap"` uninstalls them:

```nix
    casks = [
      "1password"
      "bartender"
      "betterdisplay"   # <- new
      "claude"
```

Third-party tap:

```nix
    taps = [
      { name = "owner/tap"; trusted = true; }
    ];
    brews = [
      { name = "owner/tap/tool"; }
    ];
```

## Custom derivation wired into a module

`modules/<name>/package.nix` follows `modules/omp/package.nix` (header
comment with why and how to bump, per-system assets, SRI hashes). Plain
install:

```nix
{ pkgs, lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.<name>;
in
{
  options.modules.<name>.enable = mkEnableOption "<name>";

  config = mkIf cfg.enable {
    home.packages = [ (pkgs.callPackage ./package.nix { }) ];
  };
}
```

Or as an HM module's `package = pkgs.callPackage ./package.nix { };`.
