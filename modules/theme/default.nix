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
        Scheme name (without `.yaml`) from `tinted-theming/schemes`. The
        `system` option resolves which subdirectory the file lives in
        (`base24/` preferred over `base16/`). Browse available schemes:
          ls ${inputs.tinted-schemes}/base24 | sed 's/\.yaml$//'
          ls ${inputs.tinted-schemes}/base16 | sed 's/\.yaml$//'
        Or in the browser: https://tinted-theming.github.io/tinted-gallery
      '';
    };

    system = mkOption {
      type = types.enum [
        "base16"
        "base24"
      ];
      readOnly = true;
      default =
        if builtins.pathExists "${inputs.tinted-schemes}/base24/${cfg.scheme}.yaml" then
          "base24"
        else if builtins.pathExists "${inputs.tinted-schemes}/base16/${cfg.scheme}.yaml" then
          "base16"
        else
          throw "modules.theme.scheme: '${cfg.scheme}' not found in tinted-theming/schemes (looked in base24/ and base16/)";
      defaultText = "Inferred from `scheme` — `base24` preferred, falls back to `base16`.";
      description = ''
        Resolved scheme system. Inferred from which subdirectory of
        `tinted-theming/schemes` contains the scheme file. Read-only.
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
          # base24-only slot. base16 schemes fall back to base0E (the
          # non-bright magenta/mauve).
          accentBright = c.base17 or c.base0E;
        };
      defaultText = "role-named `#rrggbb` hex strings derived from the active base24 scheme";
      description = "Role-named scheme-agnostic colour API for hand-templated apps.";
    };
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme = "${inputs.tinted-schemes}/${cfg.system}/${cfg.scheme}.yaml";
      inherit (cfg) polarity;
      autoEnable = false;
      fonts.monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
    };
  };
}
