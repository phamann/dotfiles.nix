{ pkgs, lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.modules.zellij;
in {
  options.modules.zellij = {
    enable = mkEnableOption "zellij";
    layout = mkOption {
      type = types.str;
      default = "compact-top";
    };
  };
  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      package = pkgs.unstable.zellij;
    };
    home.file = {
      ".config/zellij/layouts/compact-top.kdl".source = ./compact-top.kdl;
      ".config/zellij/layouts/compact-bottom.kdl".source = ./compact-bottom.kdl;
      ".config/zellij/config.kdl".source =
        pkgs.replaceVars ./config.kdl {
          layout = "${cfg.layout}";
          theme = "catppuccin-${config.modules.theme.flavour}";
        };
    };
  };
}
