{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.bat;
in
{
  options.modules.bat = {
    enable = mkEnableOption "bat";
  };
  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      themes = {
        tokyonight = {
          src = pkgs.fetchFromGitHub {
            owner = "folke";
            repo = "tokyonight.nvim";
            rev = "v4.10.0";
            hash = "sha256-NOKzXsY+DLNrykyy2Fr1eiSpYDiBIBNHL/7PPvbgbSo=";
          };
          file = "extras/sublime/tokyonight_moon.tmTheme";
        };
      };
    };
    catppuccin.bat.enable = true;
  };
}
