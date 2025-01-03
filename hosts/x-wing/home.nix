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
      alacritty.enable = true;
      bat.enable = true;
      direnv.enable = true;
      fzf.enable = true;
      ghostty.enable = true;
      git.enable = true;
      gpg.enable = true;
      gui.enable = true;
      kitty.enable = true;
      nvim.enable = true;
      packages.enable = true;
      ssh.enable = true;
      starship.enable = true;
      tmux.enable = true;
      zellij.enable = true;
      zsh.enable = true;

      packages.additional-packages = with pkgs; [
        colima
        infra
        kubectl
        kubernetes-helm
        fluxcd
        graphviz
      ];
    };
  };
}
