{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.ghostty;
in
{
  options.modules.ghostty = { enable = mkEnableOption "ghostty"; };
  config =
    mkIf cfg.enable {
      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          font-family = "JetBrainsMono Nerd Font Mono";
        };
      };
    };
}
