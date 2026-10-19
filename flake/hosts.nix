{ inputs, withSystem, ... }:
let
  mkDarwin =
    {
      host,
      system,
      user,
    }:
    withSystem system (
      { pkgs, ... }:
      inputs.darwin.lib.darwinSystem {
        inherit pkgs;
        specialArgs = { inherit inputs; };
        modules = [
          (../hosts + "/${host}/configuration.nix")
          {
            users.users.${user} = {
              createHome = false;
              home = "/Users/${user}";
            };
          }
          inputs.stylix.darwinModules.stylix
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              users.${user}.imports = [ (../hosts + "/${host}/home.nix") ];
              extraSpecialArgs = { inherit inputs system; };
            };
          }
        ];
      }
    );

  # NixOS hosts. Deliberately NOT routed through `withSystem`: the
  # flake-parts perSystem pkgs are built from `inputs.nixpkgs` (the darwin
  # channel), and NixOS hosts must come from `inputs.nixpkgs-nixos`. nixpkgs
  # is configured inside the module set via `nixpkgs.hostPlatform` instead.
  mkNixos =
    {
      host,
      system,
      user,
    }:
    inputs.nixpkgs-nixos.lib.nixosSystem {
      specialArgs = { inherit inputs system; };
      modules = [
        (../hosts + "/${host}/configuration.nix")
        inputs.disko.nixosModules.disko
        # `determinate.enable` defaults to true — importing is enough. The
        # module sets `nix.package` itself and redirects the generated
        # nix.conf to /etc/nix/nix.custom.conf, so `nix.settings` keeps
        # working. There is no `nix.enable = false` on the NixOS side; that
        # option is nix-darwin/HM only.
        inputs.determinate.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        {
          nixpkgs = {
            hostPlatform = system;
            config.allowUnfree = true;
            overlays = import ../lib/overlays.nix {
              inherit inputs;
              inherit (inputs.nixpkgs-nixos) lib;
            } system;
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            users.${user}.imports = [ (../hosts + "/${host}/home.nix") ];
            extraSpecialArgs = { inherit inputs system; };
          };
        }
      ];
    };
in
{
  flake.darwinConfigurations = {
    x-wing = mkDarwin {
      host = "x-wing";
      system = "aarch64-darwin";
      user = "phamann";
    };
    r2-d2 = mkDarwin {
      host = "r2-d2";
      system = "aarch64-darwin";
      user = "phamann";
    };
  };

  flake.nixosConfigurations = {
    yoda = mkNixos {
      host = "yoda";
      system = "x86_64-linux";
      user = "phamann";
    };
  };
}
