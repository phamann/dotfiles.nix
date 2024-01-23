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
          theme = "github_dark_dimmed";
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
          github-dark-dimmed = {
            src = ./themes/github;
            file = "github_dark_dimmed.tmTheme";
          };
          /* github-dark-dimmed = {
            src = pkgs.fetchFromGitHub {
              owner = "mauroreisvieira";
              repo = "github-sublime-theme";
              rev = "4070-2.6.0";
              hash = "sha256-8flLM05vkeiRPwJLvOYUxO/qvDeypAFdntfH08BsFto=";
            };
            file = "GitHub%20Dimmed.sublime-theme";
          }; */
        };
      };
    };
}
