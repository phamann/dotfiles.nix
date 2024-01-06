{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.zellij;
in
{
  options.modules.zellij = { enable = mkEnableOption "zellij"; };
  config =
    mkIf cfg.enable {
      programs.zellij = {
        enable = true;
        enableZshIntegration = true;
      };
      home.file.".config/zellij/config.kdl".source = ./config.kdl;
    };
}
