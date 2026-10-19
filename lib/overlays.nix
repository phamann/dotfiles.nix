{ inputs, lib }:
let
  inherit (lib) hasSuffix optionals;
in
# The overlay list applied to every host's nixpkgs. Takes the target system
# because `unstable` has to be instantiated for it — aarch64-darwin for the
# Macs, x86_64-linux for yoda.
#
# Consumed twice: by `perSystem._module.args.pkgs` in flake.nix (dev shell,
# checks, treefmt) and by `mkNixos` in flake/hosts.nix, which can't reuse the
# perSystem pkgs because yoda builds from `nixpkgs-nixos`, not `nixpkgs`.
system:
[
  # `pkgs.unstable.<name>` for packages ahead of the release channel.
  (_: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  })

  inputs.rust-overlay.overlays.default
]
# checkPhase skips for packages whose test suites fail on aarch64-darwin.
# Darwin-specific breakage — applying these on linux would disable suites
# that pass there AND force local rebuilds of packages that would otherwise
# substitute straight from cache.nixos.org.
++ optionals (hasSuffix "-darwin" system) [
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
]
