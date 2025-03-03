{
  description = "Patrick Hamann's dotfile and home configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/nix-darwin-24.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
  };

  outputs =
    { self
    , darwin
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , rust-overlay
    , ...
    } @ inputs:
    let
      overlay-unstable = system: final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          inputs.nixpkgs.config.allowUnfree = true;
        };
      };
      overlay-elevation-fluxcd = final: prev:
        {
          fluxcd = prev.fluxcd.overrideAttrs (oldAttrs: rec {
            name = "fluxcd";
            src = prev.fetchzip {
              url = "https://github.com/fluxcd/flux2/releases/download/v2.1.2/flux_2.1.2_darwin_arm64.tar.gz";
              hash = "sha256-ymXlpd2/UP1kPdjAq4Ba6cvqvWeBTaaPqSJcruFmbgI=";
            };
            phases = [ "installPhase" "patchPhase" ];
            installPhase = ''
              mkdir -p $out/bin
              cp -r $src/* $out/bin/
              chmod +x $out/bin/flux
            '';
          });
        };
      pkgsForSystem = system: import nixpkgs {
        overlays = [
          (overlay-unstable system)
          rust-overlay.overlays.default
          overlay-elevation-fluxcd
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
          extraSpecialArgs = {
            inherit inputs system;
          };
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
                users."${user}".imports = [
                  (./. + "/hosts/${host}/home.nix")
                ];
                extraSpecialArgs = {
                  inherit inputs system;
                };
              };
            }
          ];
          specialArgs = { inherit inputs; };
        };

    in
    {
      defaultPackage = {
        x86_64-linux = home-manager.defaultPackage.x86_64-linux;
        x86_64-darwin = home-manager.defaultPackage.x86_64-darwin;
        aarch64-darwin = home-manager.defaultPackage.aarch64-darwin;
      };

      homeConfigurations = {
        "phamann@yoda" = hostHomeWithSystem "yoda" "x86_64-linux";
      };

      darwinConfigurations = {
        "x-wing" = darwinHostWithSystem "x-wing" "aarch64-darwin" "phamann";
        "r2-d2" = darwinHostWithSystem "r2-d2" "aarch64-darwin" "phamann";
      };
    };
}
