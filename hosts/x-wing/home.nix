{ pkgs, ... }: {
  imports = [
    ../../modules/default.nix
    ../../scripts/aliasApplications.nix
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
      zsh.enable = true;
      fzf.enable = true;
      alacritty.enable = true;
      kitty.enable = true;
      starship.enable = true;
      packages.enable = true;
      nvim.enable = true;
      git.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      gpg.enable = true;
      direnv.enable = true;
      gui.enable = true;
      zellij.enable = true;

      packages.additional-packages = with pkgs; [
        colima
        infra
        kubectl
        kubernetes-helm
        fluxcd
      ];
    };
  };
}
