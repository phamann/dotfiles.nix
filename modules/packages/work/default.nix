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
      coredns
      grafana-alloy
      # Grafana Cloud CLI. Stable is stuck on pre-1.0 (0.2.x); unstable tracks
      # the 1.x releases — drop back to `gcx` once stable catches up.
      unstable.gcx
      haproxy
      ngrok
      nsc
      opentofu
      spacectl
      # pandoc's PDF engine for core's post-mortem export. core pins 0.15.1
      # (mise.toml + Dockerfile); stable is 0.14.x, unstable matches.
      unstable.typst

      # core's CI image pins golangci-lint (.buildkite/docker/Dockerfile.tools)
      # and builds it from source, because a golangci-lint binary can only
      # typecheck modules up to the Go version it was compiled with. Upstream
      # release binaries lag core's go.mod, so build the pinned version with
      # nixpkgs' derivation, which uses the same Go as `go_1_27` in the dev
      # bucket.
      #
      # To bump: copy `hash` and `vendorHash` from the nixpkgs commit that
      # packaged that version (pkgs/by-name/go/golangci-lint/package.nix).
      # Matching nixpkgs' vendorHash lets the module vendor output come from
      # cache.nixos.org. A fresh vendor fetch fails on this Mac, because the
      # depthfirst firewall intercepts proxy.golang.org and nix builders
      # don't trust its CA.
      (unstable.golangci-lint.overrideAttrs (
        finalAttrs: _: {
          version = "2.14.0";
          src = fetchFromGitHub {
            owner = "golangci";
            repo = "golangci-lint";
            tag = "v${finalAttrs.version}";
            hash = "sha256-HATA7JKHwEouM+8jYZbQrkX7p4gut4IpyTvcBexu/4o=";
          };
          vendorHash = "sha256-ekP/zDhYMpMG+tYAyYHNfLOCt/JkxrXUw1jHUEfsM8k=";
        }
      ))

      # Pinned to the versions core's CI uses, not nixpkgs': see ../pinned.nix.
      pinned.pandoc
      # hiPrio: overrides the shared cli bucket's nixpkgs yq-go on this host only.
      (lib.hiPrio pinned.yq)
    ];
  };
}
