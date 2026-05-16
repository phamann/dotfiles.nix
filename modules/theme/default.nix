{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.modules.theme;
in
{
  imports = [ inputs.stylix.homeModules.stylix ];

  options.modules.theme = {
    enable = mkEnableOption "theme";

    scheme = mkOption {
      type = types.str;
      default = "catppuccin-mocha";
      description = ''
        Base24 scheme name (without `.yaml`) from `tinted-theming/schemes`'s
        `base24/` directory. Browse available schemes:
          ls ${inputs.tinted-schemes}/base24 | sed 's/\.yaml$//'
        Or in the browser: https://tinted-theming.github.io/base16-gallery
      '';
    };

    polarity = mkOption {
      type = types.enum [
        "dark"
        "light"
        "either"
      ];
      default = "dark";
      description = "Polarity passed to Stylix.";
    };

    # Role-named colour API derived from the active base24 scheme. Apps
    # consume `config.modules.theme.semantic.<role>` instead of palette
    # names or base24 slot indices.
    semantic = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      default =
        let
          c = config.lib.stylix.colors.withHashtag;
        in
        {
          bg = c.base00;
          fg = c.base05;
          bgAlt = c.base01;
          fgAlt = c.base04;

          primary = c.base0D;
          success = c.base0B;
          warning = c.base0A;
          error = c.base08;
          info = c.base0C;

          accent = c.base0E;
          accentAlt = c.base07;
          accentBright = c.base17;
        };
      defaultText = "role-named `#rrggbb` hex strings derived from the active base24 scheme";
      description = "Role-named scheme-agnostic colour API for hand-templated apps.";
    };
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme = "${inputs.tinted-schemes}/base24/${cfg.scheme}.yaml";
      inherit (cfg) polarity;
      autoEnable = false;
      fonts.monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
    };
  };
}
