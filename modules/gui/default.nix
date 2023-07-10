{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.gui;
in
{
  options.modules.gui = {
    enable = mkEnableOption "gui";
    additional-packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        _1password-gui
        obsidian
        slack
        spotify
        zoom-us
      ]
      ++ cfg.additional-packages;
  };
}
