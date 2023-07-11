{
  description = "Patrick Hamann's dotfile and home configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mkAlias = {
      url = "github:reckenrode/mkAlias";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , darwin
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
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
      darwinHostWithSystem = host: system:
        darwin.lib.darwinSystem {
          pkgs = pkgsForSystem system;
          modules = [
            (./. + "/hosts/${host}/configuration.nix")
          ];
          specialArgs = { inherit inputs; };
        };

    in {
      defaultPackage = {
        x86_64-linux = home-manager.defaultPackage.x86_64-linux;
        x86_64-darwin = home-manager.defaultPackage.x86_64-darwin;
        aarch64-darwin = home-manager.defaultPackage.aarch64-darwin;
      };

      homeConfigurations = {
        "phamann@x-wing" = hostHomeWithSystem "x-wing" "aarch64-darwin";
        "phamann@yoda" = hostHomeWithSystem "yoda" "x86_64-linux";
      };

      darwinConfigurations = {
        "x-wing" = darwinHostWithSystem "x-wing" "aarch64-darwin";
      };
    };
}
