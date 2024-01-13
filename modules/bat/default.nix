{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.bat;
in
{
  options.modules.bat = { enable = mkEnableOption "bat"; };
  config =
    mkIf cfg.enable {
      programs.bat = {
        enable = true;
        config = {
          theme = "tokyonight";
        };
        themes = {
          tokyonight = {
            src = pkgs.fetchFromGitHub {
              owner = "folke";
              repo = "tokyonight.nvim";
              rev = "v2.9.0";
              hash = "sha256-NOKzXsY+DLNrykyy2Fr1eiSpYDiBIBNHL/7PPvbgbSo=";
            };
            file = "extras/sublime/tokyonight_storm.tmTheme";
          };
        };
      };
    };
}
