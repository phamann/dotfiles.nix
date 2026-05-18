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

  # Extract `<system>` and `<bare>` from cfg.scheme. The regex shape is
  # validated by `types.strMatching` on the option itself (below), so by
  # the time we reach this binding `parts` is guaranteed non-null.
  parts = builtins.match "(base16|base24)-([a-z0-9._-]+)" cfg.scheme;
  system = builtins.elemAt parts 0;
  bareScheme = builtins.elemAt parts 1;

  # Resolve the scheme YAML: prefer a local override in
  # `modules/theme/schemes/<system>/<bare>.yaml` over the upstream input.
  # Lets custom themes (e.g. base24-ocean as base16-ocean extended) live
  # in-repo alongside their corresponding `colors/<system>-<bare>.vim`
  # for tinted-vim.
  localYaml = ./schemes + "/${system}/${bareScheme}.yaml";
  schemeYaml =
    if builtins.pathExists localYaml then
      localYaml
    else
      "${inputs.tinted-schemes}/${system}/${bareScheme}.yaml";
in
{
  imports = [ inputs.stylix.homeModules.stylix ];

  options.modules.theme = {
    enable = mkEnableOption "theme";

    scheme = mkOption {
      type = types.strMatching "(base16|base24)-[a-z0-9._-]+";
      default = "base24-catppuccin-mocha";
      example = "base16-default-dark";
      description = ''
        tinted-theming scheme ID — the value matches scheme IDs in the
        gallery and tinted-vim's colorscheme filenames exactly. Format:
        `<system>-<name>` where `<system>` is `base16` or `base24`.

        Browse available schemes:
          ls ${inputs.tinted-schemes}/base24 | sed 's/\.yaml$//'
          ls ${inputs.tinted-schemes}/base16 | sed 's/\.yaml$//'
        Or in the browser: https://tinted-theming.github.io/tinted-gallery

        base24 schemes get a richer 24-slot palette (extended bright
        accents at base10-base17); base16 schemes are 16-slot and the
        extended slots fall back to their base counterparts.
      '';
    };

    system = mkOption {
      type = types.enum [
        "base16"
        "base24"
      ];
      readOnly = true;
      default = system;
      defaultText = "Parsed from the prefix of `scheme`.";
      description = "Resolved scheme system (base16 or base24). Read-only.";
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
      base16Scheme = schemeYaml;
      inherit (cfg) polarity;
      autoEnable = false;
      fonts.monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
    };

    # Local tinted-vim colourscheme files (modules/theme/schemes/colors/)
    # land under ~/.config/nvim/colors, which is searched before lazy's
    # plugin paths — local files shadow tinted-vim's upstream colours
    # for the same name. Pair each YAML with a matching .vim file.
    xdg.configFile."nvim/colors" = {
      source = ./schemes/colors;
      recursive = true;
    };
  };
}
