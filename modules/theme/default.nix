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
    mapAttrs
    importJSON
    hasPrefix
    removePrefix
    ;
  cfg = config.modules.theme;

  isCatppuccinScheme = hasPrefix "catppuccin-" cfg.scheme;
  inferredFlavour = if isCatppuccinScheme then removePrefix "catppuccin-" cfg.scheme else "mocha";

  # Read a Catppuccin flavour palette from catppuccin/nix's bundled JSON
  # and return a `{ <colourName> = <hex>; }` attrset.
  paletteFor =
    flavour:
    mapAttrs (_: c: c.hex)
      (importJSON "${config.catppuccin.sources.palette}/palette.json").${flavour}.colors;
in
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    inputs.stylix.homeModules.stylix
  ];

  options.modules.theme = {
    enable = mkEnableOption "theme";

    scheme = mkOption {
      type = types.str;
      default = "catppuccin-mocha";
      description = ''
        Base24 scheme name (without `.yaml`) from `tinted-theming/schemes`'s
        `base24/` directory. Browse:
          ls ${inputs.tinted-schemes}/base24 | sed 's/\.yaml$//'
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
          c = config.lib.stylix.colors;
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
      defaultText = "role-named hex values derived from the active base24 scheme";
      description = "Role-named scheme-agnostic colour API for hand-templated apps.";
    };

    flavour = mkOption {
      type = types.str;
      default = inferredFlavour;
      defaultText = "Catppuccin flavour extracted from `scheme` (e.g. `catppuccin-mocha` → `mocha`).";
      description = "Catppuccin flavour. Defaults from `scheme`.";
    };

    lightFlavour = mkOption {
      type = types.enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = "latte";
      description = "Catppuccin flavour for apps with a light/dark split.";
    };

    accent = mkOption {
      type = types.enum [
        "rosewater"
        "flamingo"
        "pink"
        "mauve"
        "red"
        "maroon"
        "peach"
        "yellow"
        "green"
        "teal"
        "sky"
        "sapphire"
        "blue"
        "lavender"
      ];
      default = "mauve";
      description = "Catppuccin accent colour.";
    };

    palette = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      default = paletteFor cfg.flavour;
      defaultText = "Catppuccin palette for the active flavour, keyed by colour name.";
      description = "Hex values from the active Catppuccin flavour, keyed by colour name.";
    };
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme = "${inputs.tinted-schemes}/base24/${cfg.scheme}.yaml";
      polarity = cfg.polarity;
      autoEnable = false;
      fonts.monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
    };

    catppuccin = mkIf isCatppuccinScheme {
      flavor = inferredFlavour;
      inherit (cfg) accent;
    };
  };
}
