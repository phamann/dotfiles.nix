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

    # zellij status bar plugin (replaces the built-in compact-bar, whose
    # " Zellij " prefix and swap-layout indicator are hardcoded). Built from
    # source with crane — there's no binary cache, so the first build compiles
    # a wasm32-wasip1 Rust toolchain build.
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        rust-overlay.follows = "rust-overlay";
      };
    };

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

    # Rex terminal multiplexer (prebuilt, proprietary). On macOS the Rex app
    # bundles and runs the server; this input supplies the `rex` CLI, its
    # terminfo entry and ssh guard, and the HM module that writes init.lua.
    # `preview` is the channel the Rex Beta app's bundled server tracks
    # (`rex server status` commit == preview's sources.json commit), and
    # `stable` has no releases yet. Keep the CLI on the app's channel.
    rex = {
      url = "https://pkgs.superlogical.com/rex/nix/preview.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
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
