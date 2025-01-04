{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.ghostty;
in {
  options.modules.ghostty = { enable = mkEnableOption "ghostty"; };
  config = mkIf cfg.enable {
    programs.zellij = { enable = true; };
    home.file = { ".config/ghostty/config".source = ./config; };
  };
}
