{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.opencode;
in
{
  options.modules.opencode = { enable = mkEnableOption "opencode"; };
  config =
    mkIf cfg.enable {
      xdg.configFile = {
        "opencode/config.json" = {
          source =
            config.lib.file.mkOutOfStoreSymlink
              "${config.home.homeDirectory}/.config/nixpkgs/modules/opencode/config.json";
        };
      };
    };
}