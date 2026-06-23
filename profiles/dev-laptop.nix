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
  home.packages = [ pkgs.unstable.colima ];
}
