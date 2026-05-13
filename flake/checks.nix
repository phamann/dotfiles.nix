{ self, lib, ... }:
{
  # Per-host evaluation checks. `nix flake check` will build the toplevel
  # derivation for each host whose system matches the runner's, so eval
  # breakage on hosts you're not currently on (yoda when rebuilding on
  # r2-d2, x-wing when on r2-d2) is caught BEFORE you push.
  #
  # Building only triggers if all dependencies substitute or build — these
  # aren't smoke tests of runtime behaviour, just of evaluation + build
  # graph correctness.
  perSystem =
    { system, ... }:
    {
      checks =
        lib.optionalAttrs (system == "aarch64-darwin") {
          eval-r2-d2 = self.darwinConfigurations.r2-d2.config.system.build.toplevel;
          eval-x-wing = self.darwinConfigurations.x-wing.config.system.build.toplevel;
        }
        // lib.optionalAttrs (system == "x86_64-linux") {
          eval-yoda = self.homeConfigurations."phamann@yoda".activationPackage;
        };
    };
}
