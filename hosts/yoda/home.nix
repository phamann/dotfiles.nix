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
      bat.enable = true;
      direnv.enable = true;
      fzf.enable = true;
      git.enable = true;
      gpg.enable = true;
      nvim.enable = true;
      packages.enable = true;
      ssh.enable = true;
      starship.enable = true;
      tmux.enable = true;
      zsh.enable = true;
      zellij = {
        enable = false;
        layout = "compact-bottom";
      };
    };
  };
}
