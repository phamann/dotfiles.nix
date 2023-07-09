{ pkgs, lib, inputs, ... }:
{

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  system.defaults.finder.AppleShowAllFiles = false;
}
