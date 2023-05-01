{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.fzf;
in
{
  options.modules.fzf = { enable = mkEnableOption "fzf"; };
  config =
    mkIf cfg.enable {
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultOptions = [ "--height 40%" "--reverse" "--border" ];
      };
    };
}
