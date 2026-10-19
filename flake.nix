{
  description = "Patrick Hamann's dotfiles and host configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # NixOS hosts (yoda) track the nixos-<release> channel, NOT the darwin
    # one above. `nixpkgs-26.05-darwin` only advances when the darwin Hydra
    # jobset is green; it is never gated on the NixOS installer / systemd /
    # kernel tests. Same release tier, different gate.
    nixpkgs-nixos.url = "github:nixos/nixpkgs/nixos-26.05";

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

    # Declarative disk partitioning for yoda. Also consumed by
    # nixos-anywhere at install time (see plans/nixos-yoda.md).
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };

    # Per-model hardware quirks. No NUC10 module exists upstream, so yoda
    # uses the generic Intel microcode + SSD fstrim modules.
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Determinate Nix on yoda, matching the Macs (which install it via the
    # .pkg and set `nix.enable = false` in profiles/darwin/system.nix so
    # nix-darwin leaves the daemon alone).
    #
    # DELIBERATELY NOT `inputs.nixpkgs.follows`, unlike every other input
    # here: upstream warns that following nixpkgs causes FlakeHub Cache
    # misses, which means rebuilding Nix itself from source.
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

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
        {
          # Custom pkgs for every flake-module that consumes `{ pkgs, ... }`.
          # The overlay list lives in lib/overlays.nix because mkNixos
          # (flake/hosts.nix) needs the same one and can't reuse these pkgs
          # — yoda builds from `nixpkgs-nixos`, not `nixpkgs`.
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = import ./lib/overlays.nix {
              inherit inputs;
              inherit (inputs.nixpkgs) lib;
            } system;
          };
        };
    };
}
