{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf optionalAttrs;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  cfg = config.modules.kitty;
in
{
  options.modules.kitty = {
    enable = mkEnableOption "kitty";
  };
  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      extraConfig = builtins.readFile ./kitty.conf;
    };
    # The .icns file is the macOS app icon; meaningless on Linux.
    xdg.configFile = optionalAttrs isDarwin {
      "kitty/kitty.app.icns" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixpkgs/modules/kitty/kitty.app.icns";
      };
    };
  };
}
