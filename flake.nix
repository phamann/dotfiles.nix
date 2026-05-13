{
  description = "Patrick Hamann's dotfiles and host configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
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
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    mkAlias = {
      url = "github:reckenrode/mkAlias";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-nix.url = "github:sadjow/claude-code-nix";

    catppuccin.url = "github:catppuccin/nix/release-25.11";
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
