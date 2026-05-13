{ inputs, withSystem, ... }:
let
  mkDarwin = { host, system, user }:
    withSystem system ({ pkgs, ... }:
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
      });

  mkHomeManager = { host, system }:
    withSystem system ({ pkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ (../hosts + "/${host}/home.nix") ];
        extraSpecialArgs = { inherit inputs system; };
      });
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

  flake.homeConfigurations = {
    "phamann@yoda" = mkHomeManager {
      host = "yoda";
      system = "x86_64-linux";
    };
  };
}
