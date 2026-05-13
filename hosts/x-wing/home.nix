{ pkgs, ... }:
{
  imports = [
    ../../modules/default.nix
    # TODO: Fix aliasApplications.nix for darwin.apple_sdk_11_0 removal
    # ../../scripts/aliasApplications.nix
  ];
  config = {
    home = {
      username = "phamann";
      homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/phamann";
      stateVersion = "22.11";
    };

    programs.home-manager.enable = true;

    modules = {
      alacritty.enable = true;
      bat.enable = true;
      claude-code.enable = true;
      direnv.enable = true;
      fzf.enable = true;
      ghostty.enable = true;
      git.enable = true;
      gpg.enable = true;
      gui.enable = true;
      kitty.enable = false;
      nvim = {
        enable = true;
        dev = true;
      };
      packages = {
        cli.enable = true;
        dev.enable = true;
        k8s.enable = true;
      };
      ssh.enable = true;
      starship.enable = true;
      theme = {
        enable = true;
        flavour = "frappe";
      };
      tmux.enable = true;
      zed.enable = true;
      zellij.enable = true;
      zsh.enable = true;
      opencode.enable = true;

      # kubectl/helm now come from packages.k8s; graphviz from packages.dev.
      # unstable.colima stays here pending platform-aware handling (Phase 3).
      packages.additional-packages = with pkgs; [
        unstable.colima
      ];
    };
  };
}
