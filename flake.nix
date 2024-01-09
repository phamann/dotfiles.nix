{
  description = "Patrick Hamann's dotfile and home configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mkAlias = {
      url = "github:reckenrode/mkAlias";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay.url = "github:oxalica/rust-overlay";

    zjstatus = { url = "github:dj95/zjstatus"; };

  };

  outputs =
    { self
    , darwin
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , rust-overlay
    , zjstatus
    , ...
    } @ inputs:
    let
      overlay-unstable = system: final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          inputs.nixpkgs.config.allowUnfree = true;
        };
      };
      pkgsForSystem = system: import nixpkgs {
        overlays = [
          (overlay-unstable system)
          rust-overlay.overlays.default
          (final: prev: {
            zjstatus = zjstatus.packages.${prev.system}.default;
          })
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
        # "phamann@x-wing" = hostHomeWithSystem "x-wing" "aarch64-darwin";
        "phamann@yoda" = hostHomeWithSystem "yoda" "x86_64-linux";
      };

      darwinConfigurations = {
        "x-wing" = darwinHostWithSystem "x-wing" "aarch64-darwin" "phamann";
      };
    };
}
