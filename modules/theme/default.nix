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

  # Legacy: derive a Catppuccin flavour from a `catppuccin-<X>` scheme name
  # so the transitional `flavour` option below has a sensible default for
  # un-migrated modules (ghostty, zellij, opencode) that still read it.
  # Removed in Phase G when no consumer remains.
  inferredFlavour = if isCatppuccinScheme then removePrefix "catppuccin-" cfg.scheme else "mocha";

  # Legacy: read the active flavour's hex palette from catppuccin/nix.
  # Used only by claude-statusline until Phase F migrates it to `semantic`.
  paletteFor =
    flavour:
    mapAttrs (_: c: c.hex)
      (importJSON "${config.catppuccin.sources.palette}/palette.json").${flavour}.colors;
in
{
  imports = [
    # Transitional during Phases A–F. The catppuccin/nix module drives
    # bat/fzf/starship/delta/zed/ghostty/zellij/opencode/nvim until each
    # is migrated to its `stylix.targets.<x>.enable` equivalent. Removed
    # in Phase G.
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
        `base24/` directory. Drives Stylix.

        Browse:
          ls ${inputs.tinted-schemes}/base24 | sed 's/\.yaml$//'

        Switching to e.g. `"gruvbox-dark-medium"` re-skins every
        Stylix-enabled module + the semantic colour roles below.
      '';
    };

    polarity = mkOption {
      type = types.enum [
        "dark"
        "light"
        "either"
      ];
      default = "dark";
      description = "Tells Stylix which polarity the scheme is.";
    };

    # ===== Semantic colour API (base24-derived, role-named) =====
    # Scheme-agnostic. Hand-templated apps consume role names, not theme
    # names — switching scheme later swaps the hex values but the role
    # mapping holds. Used by claude-statusline once Phase F migrates it.
    semantic = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      default =
        let
          c = config.lib.stylix.colors;
        in
        {
          # Foreground / background
          bg = c.base00;
          fg = c.base05;
          bgAlt = c.base01;
          fgAlt = c.base04;

          # Status / signal
          primary = c.base0D; # blue
          success = c.base0B; # green
          warning = c.base0A; # yellow
          error = c.base08; # red
          info = c.base0C; # teal / cyan

          # Accents
          accent = c.base0E; # mauve / magenta
          accentAlt = c.base07; # lavender / pale accent
          accentBright = c.base17; # bright magenta / pink
        };
      defaultText = "role-named hex values derived from the active base24 scheme";
      description = ''
        Role-named colour roles for hand-templated apps. Consume as
        `inherit (config.modules.theme.semantic) primary accent ...;`
        — scheme-agnostic.
      '';
    };

    # ===== Legacy options (deprecated; removed in Phase G) =====
    # Kept while ghostty/zellij/opencode (Phase C), nvim (Phase D), and
    # claude-statusline (Phase F) still consume them. Each defaults from
    # the scheme; do NOT set explicitly in hosts.

    flavour = mkOption {
      type = types.str;
      default = inferredFlavour;
      defaultText = "<derived from `scheme` for catppuccin-* schemes; else \"mocha\">";
      description = ''
        DEPRECATED. Use `scheme` instead. Kept during the Stylix migration
        for compatibility with the ghostty/zellij/opencode modules that
        still read `themeCfg.flavour` to construct `catppuccin-<flavour>`
        theme name strings. Removed in Phase G.
      '';
    };

    lightFlavour = mkOption {
      type = types.enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = "latte";
      description = ''
        DEPRECATED. Flavour for apps that support a light/dark split
        (ghostty). Removed when ghostty migrates to Stylix in Phase C.
      '';
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
      description = "DEPRECATED. Catppuccin accent colour. Removed in Phase G.";
    };

    palette = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      default = paletteFor cfg.flavour;
      defaultText = "catppuccin palette for the active flavour, keyed by colour name";
      description = ''
        DEPRECATED. Hex values from the active Catppuccin flavour keyed by
        Catppuccin colour name (mauve, lavender, blue, …). Used by
        claude-statusline until Phase F migrates it to `semantic`.
        Removed in Phase G.
      '';
    };
  };

  config = mkIf cfg.enable {
    # ===== Stylix — palette source =====
    # autoEnable=false: no app is themed by Stylix unless its module
    # explicitly opts in via `stylix.targets.<x>.enable = true;`. Mirrors
    # the existing per-app `enable` pattern. Phases B–F flip targets on
    # one module at a time.
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

    # ===== Transitional catppuccin/nix wiring =====
    # bat/fzf/starship/delta/zed (Phase B), ghostty/zellij/opencode
    # (Phase C), and nvim (Phase D) still consume these. Removed in Phase G.
    catppuccin = mkIf isCatppuccinScheme {
      flavor = inferredFlavour;
      inherit (cfg) accent;
    };

    # Phase D removed the env-var → vim.env.CATPPUCCIN_FLAVOUR dance.
    # nvim's only consumer is gone (Stylix injects mini.base16 directly
    # into init.lua). If catppuccin/nix's per-app modules ever need env
    # vars, add them back behind isCatppuccinScheme.
  };
}
