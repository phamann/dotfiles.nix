{ pkgs, ... }: {
  imports = [
    ../../modules/default.nix
    # TODO: Fix aliasApplications.nix for darwin.apple_sdk_11_0 removal
    # ../../scripts/aliasApplications.nix
  ];
  config = {
    home = {
      username = "phamann";
      homeDirectory =
        "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/phamann";
      stateVersion = "22.11";
    };

    programs.home-manager.enable = true;

    modules = {
      alacritty.enable = true;
      bat.enable = true;
      claude-code.enable = true;
      direnv.enable = true;
      fzf.enable = true;
      git.enable = true;
      gpg.enable = true;
      gui.enable = true;
      kitty.enable = false;
      nvim.enable = true;
      packages.enable = true;
      ssh.enable = true;
      starship.enable = true;
      tmux.enable = true;
      zed.enable = true;
      zellij.enable = true;
      zsh.enable = true;
      opencode.enable = true;

      packages.additional-packages = with pkgs; [
        colima
        kubectl
        kubernetes-helm
        graphviz
      ];
    };
  };
}
