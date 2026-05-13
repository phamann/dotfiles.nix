{ pkgs, lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.strings) toUpper;
  cfg = config.modules.ghostty;
  themeCfg = config.modules.theme;
  # Ghostty ships built-in Catppuccin themes named like "Catppuccin Frappe".
  ghosttyTheme = flavour: "Catppuccin ${toUpper (builtins.substring 0 1 flavour)}${builtins.substring 1 (-1) flavour}";
in {
  options.modules.ghostty = { enable = mkEnableOption "ghostty"; };
  config = mkIf cfg.enable {
    home.file.".config/ghostty/config".source =
      pkgs.replaceVars ./config {
        theme = ghosttyTheme themeCfg.flavour;
        lightTheme = ghosttyTheme themeCfg.lightFlavour;
      };
  };
}
