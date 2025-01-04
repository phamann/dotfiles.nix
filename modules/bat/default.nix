{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.bat;
in {
  options.modules.bat = { enable = mkEnableOption "bat"; };
  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = { theme = "catppuccin"; };
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
        catppuccin = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "699f60fc8ec434574ca7451b444b880430319941";
            hash = "sha256-6fWoCH90IGumAMc4buLRWL0N61op+AuMNN9CAR9/OdI=";
          };
          file = "themes/Catppuccin Frappe.tmTheme";
        };
      };
    };
  };
}
