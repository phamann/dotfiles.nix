{
  description = "Patrick Hamann's dotfile and home configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

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
  };

  outputs =
    { self
    , darwin
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , rust-overlay
    , claude-code-nix
    , ...
    }@inputs:
    let
      overlay-unstable = system: final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      # Disable checkPhase for packages whose upstream tests are currently
      # broken on aarch64-darwin in nixpkgs. The tests pass on cache builders;
      # we only hit them when forced to build locally on cache misses.
      overlay-skip-tests = final: prev: {
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
      };
      pkgsForSystem = system:
        import nixpkgs {
          overlays = [
            (overlay-unstable system)
            rust-overlay.overlays.default
            overlay-skip-tests
          ];
          inherit system;
          config.allowUnfree = true;
        };
      hostHomeWithSystem = host: system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsForSystem system;
          modules = [
            (./. + "/hosts/${host}/home.nix")
          ];
          extraSpecialArgs = { inherit inputs system; };
        };
      darwinHostWithSystem = host: system: user:
        darwin.lib.darwinSystem {
          pkgs = pkgsForSystem system;
          modules = [
            (./. + "/hosts/${host}/configuration.nix")
            {
              users.users."${user}" = {
                createHome = false;
                home = "/Users/${user}";
              };
            }
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-backup";
                users."${user}".imports = [
                  (./. + "/hosts/${host}/home.nix")
                ];
                extraSpecialArgs = { inherit inputs system; };
              };
            }
          ];
          specialArgs = { inherit inputs; };
        };

    in
    {
      homeConfigurations = {
        "phamann@yoda" = hostHomeWithSystem "yoda" "x86_64-linux";
      };

      darwinConfigurations = {
        "x-wing" = darwinHostWithSystem "x-wing" "aarch64-darwin" "phamann";
        "r2-d2" = darwinHostWithSystem "r2-d2" "aarch64-darwin" "phamann";
        "MVNX7235JF" = darwinHostWithSystem "r2-d2" "aarch64-darwin" "phamann";
      };
    };
}
