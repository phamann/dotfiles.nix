{
  description = "Patrick Hamann's dotfile and home configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , ...
    } @ inputs:
    let
      overlay-unstable = arch: final: prev: {
        unstable = import nixpkgs-unstable {
          inherit arch;
          inputs.nixpkgs.config.allowUnfree = true;
        };
      };
      hostWithArch = host: arch:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            overlays = [
                (overlay-unstable arch)
            ];
            inherit arch;
            config.allowUnfree = true;
          };
          modules = [
            (./. + "/hosts/${host}/home.nix")
          ];
        };
    in {
      defaultPackage = {
        x86_64-linux = home-manager.defaultPackage.x86_64-linux;
        x86_64-darwin = home-manager.defaultPackage.x86_64-darwin;
        aarch64-darwin = home-manager.defaultPackage.aarch64-darwin;
      };

      homeConfigurations = {
        "phamann@x-wing" = hostWithArch "x-wing" "aarch64-darwin";
        "phamann@yoda" = hostWithArch "yoda" "x86_64-linux";
      };
    };
}
