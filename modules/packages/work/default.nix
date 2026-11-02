{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.packages.work;
  pinned = pkgs.callPackage ../pinned.nix { };
in
{
  options.modules.packages.work.enable = mkEnableOption "incident.io infrastructure tooling";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      buildkite-cli
      caddy
      grafana-alloy
      # Grafana Cloud CLI. Stable is stuck on pre-1.0 (0.2.x); unstable tracks
      # the 1.x releases — drop back to `gcx` once stable catches up.
      unstable.gcx
      haproxy
      ngrok
      nsc
      opentofu
      spacectl

      # Pinned to the versions core's CI uses, not nixpkgs': see ../pinned.nix.
      pinned.golangci-lint
      pinned.pandoc
    ];
  };
}
