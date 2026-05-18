{ pkgs, ... }:
{
  # Modules every host gets: shell + editor + version control + theming.
  imports = [
    ../modules/bat
    ../modules/direnv
    ../modules/fzf
    ../modules/git
    ../modules/gpg
    ../modules/nvim
    ../modules/packages
    ../modules/ssh
    ../modules/starship
    ../modules/theme
    ../modules/zsh
  ];

  home = {
    username = "phamann";
    homeDirectory = "/${if pkgs.stdenv.hostPlatform.isDarwin then "Users" else "home"}/phamann";
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
    packages.cli.enable = true;
    ssh.enable = true;
    starship.enable = true;
    theme.enable = true; # flavour set by the host
    zsh.enable = true;
  };
}
