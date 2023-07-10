{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.kitty;
in
{
  options.modules.kitty = { enable = mkEnableOption "kitty"; };
  config =
    mkIf cfg.enable {
      programs.kitty = {
        enable = true;
        extraConfig = builtins.readFile ./kitty.conf;
      };
      xdg.configFile = {
        "kitty/kitty.app.icns" = {
          source =
            config.lib.file.mkOutOfStoreSymlink
              "${config.home.homeDirectory}/.config/nixpkgs/modules/kitty/kitty.app.icns";
        };
      };
    };
}
