{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.modules.omp;
in
{
  imports = [ inputs.omp.homeManagerModules.default ];

  options.modules.omp = {
    enable = mkEnableOption "Oh My Pi";

    useBinary = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Install OMP from upstream's prebuilt release asset instead of the
        in-tree flake's source derivation, which compiles ~780 crates plus a
        `bun --compile` bundle (~12 minutes), is published to no binary cache,
        and breaks on its own schedule. See `./package.nix` for the full
        rationale and the upstream tracking issue.

        Set to `false` to fall back to `inputs.omp.packages.<system>.default`.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.omp = {
      enable = true;

      package = mkIf cfg.useBinary (pkgs.callPackage ./package.nix { });

      settings.startup.quiet = true;
    };
  };
}
