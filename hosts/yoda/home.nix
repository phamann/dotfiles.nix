{ pkgs, ... }: {
  imports = [
    ../../modules/default.nix
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
      starship.enable = true;
      packages.enable = true;
      nvim.enable = true;
      git.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      gpg.enable = true;
      direnv.enable = true;
      zellij = {
        enable = true;
        layout = "compact-bottom";
      };
    };
  };
}
