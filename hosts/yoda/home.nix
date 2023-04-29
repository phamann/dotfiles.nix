{ pkgs, ... }: {
  home.username = "phamann";
  home.homeDirectory =
    "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/phamann";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  imports = [
    ../../modules/default.nix
  ];
  config.modules = {
    zsh.enable = true;
    packages.enable = true;
  };
}
