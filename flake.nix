{
  description = "Patrick Hamann's dotfiles and host configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      # Matches the nixpkgs release tier. useGlobalPkgs = true (flake/hosts.nix)
      # makes HM reuse the system nixpkgs, so HM's module code must track the
      # same release branch to avoid cross-tier assertion failures.
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-nix.url = "github:sadjow/claude-code-nix";

    omp.url = "github:can1357/oh-my-pi";

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tinted-theming canonical base16/base24 scheme repo. Consumed as a
    # source tree (not a flake) — we point stylix.base16Scheme at
    # `${inputs.tinted-schemes}/base24/<scheme>.yaml`.
    tinted-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      imports = [
        ./flake/hosts.nix
        ./flake/modules.nix
        ./flake/treefmt.nix
        ./flake/checks.nix
        ./flake/dev-shell.nix
        ./flake/git-hooks.nix
      ];

      perSystem =
        { system, ... }:
        let
          # viceroy carries `#![cfg_attr(not(debug_assertions), deny(warnings))]`,
          # so every warning is an error in a release build. The nixpkgs-unstable
          # rustc 1.98.1 -> 1.99.0 bump deprecated `std::u32::MAX`, which cranelift's
          # `entity_impl!` macro still expands to — breaking viceroy, and with it
          # `unstable.fastly`, which wraps viceroy on its PATH.
          #
          # Upstream fixed this the same way in NixOS/nixpkgs#576484, but the fix is
          # only on master; the nixpkgs-unstable channel has not advanced past it yet.
          #
          # DELETE THIS once the channel catches up. `--replace-fail` makes the build
          # fail loudly when the line is already gone, which is the signal to do so —
          # the override costs a full local wasmtime/cranelift build (no cache hit).
          overlay-viceroy-deny-warnings = _: prev: {
            viceroy = prev.viceroy.overrideAttrs (_: {
              postPatch = ''
                substituteInPlace src/lib.rs \
                  --replace-fail '#![cfg_attr(not(debug_assertions), deny(warnings))]' ""
              '';
            });
          };
        in
        {
          # Custom pkgs for every flake-module that consumes `{ pkgs, ... }`.
          # Same overlays as the pre-flake-parts pkgsForSystem helper:
          # `pkgs.unstable.*` for unstable channel access, rust-overlay for
          # toolchain pinning, and aarch64-darwin checkPhase skips.
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              (_: _: {
                unstable = import inputs.nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                  overlays = [ overlay-viceroy-deny-warnings ];
                };
              })
              inputs.rust-overlay.overlays.default
              (_: prev: {
                coredns = prev.coredns.overrideAttrs (_: {
                  doCheck = false;
                  doInstallCheck = false;
                });
                open-policy-agent = prev.open-policy-agent.overrideAttrs (_: {
                  doCheck = false;
                });
                direnv = prev.direnv.overrideAttrs (_: {
                  doCheck = false;
                });
              })
            ];
          };
        };
    };
}
