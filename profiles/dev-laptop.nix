{ pkgs, ... }:
{
  # Laptop developer workstation: full GUI tooling, dev + k8s packages,
  # AI assistants, terminal multiplexer + ghostty as the daily terminal.
  imports = [
    ./base.nix
    ../modules/claude-code
    ../modules/ghostty
    ../modules/k9s
    ../modules/opencode
    ../modules/zed
    ../modules/zellij
  ];

  modules = {
    claude-code.enable = true;
    ghostty.enable = true;
    k9s.enable = true;
    opencode.enable = true;
    zed.enable = true;
    zellij.enable = true;

    # nvim is enabled by base; laptops opt into the live-edit symlink so
    # editing lua under modules/nvim/config takes effect on next launch.
    nvim.dev = true;

    packages = {
      dev.enable = true;
      k8s.enable = true;
    };
  };

  # Docker runtime on macOS dev laptops. Works on linux too, but this
  # profile is darwin-laptop-shaped in practice.
  #
  # Pinned to stable nixpkgs: the unstable colima (0.10.3 → lima-full 2.1.4)
  # has no cached darwin build and fails to compile from source (cctools ld
  # crashes linking lima's CGO). Stable's 0.10.1 substitutes from the cache.
  # Move back to `pkgs.unstable.colima` once that upstream build is fixed.
  home.packages = [ pkgs.colima ];
}
