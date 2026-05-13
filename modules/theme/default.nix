{ inputs, lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf mkOption types mapAttrs importJSON;
  cfg = config.modules.theme;

  # Read the active flavour's hex palette straight from catppuccin/nix's
  # palette source. Same JSON the upstream per-app modules consume.
  paletteFor = flavour:
    mapAttrs (_: c: c.hex)
      (importJSON "${config.catppuccin.sources.palette}/palette.json").${flavour}.colors;
in {
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  options.modules.theme = {
    enable = mkEnableOption "theme";

    flavour = mkOption {
      type = types.enum [ "latte" "frappe" "macchiato" "mocha" ];
      default = "frappe";
      description = "Primary (dark) Catppuccin flavour.";
    };

    lightFlavour = mkOption {
      type = types.enum [ "latte" "frappe" "macchiato" "mocha" ];
      default = "latte";
      description = "Flavour for apps that support a light/dark split (e.g. ghostty, zed).";
    };

    accent = mkOption {
      type = types.enum [
        "rosewater" "flamingo" "pink" "mauve" "red" "maroon"
        "peach" "yellow" "green" "teal" "sky" "sapphire" "blue" "lavender"
      ];
      default = "mauve";
      description = "Global Catppuccin accent colour.";
    };

    palette = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      default = paletteFor cfg.flavour;
      defaultText = "catppuccin palette for the active flavour, keyed by colour name (e.g. blue, mauve, base)";
      description = ''
        Hex values from the active Catppuccin flavour, keyed by colour name.
        Use as `config.modules.theme.palette.<name>` when templating raw config
        files (e.g. via `pkgs.replaceVars`) for apps that aren't covered by an
        upstream catppuccin/nix module.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Note: deliberately NOT setting `catppuccin.enable = true`. Upstream
    # auto-enables EVERY per-app catppuccin module when the global flag is on,
    # which conflicts with apps we theme by hand (zellij, ghostty, nvim) and
    # with apps we deliberately keep on a different theme (alacritty/kitty/tmux
    # use tokyo-night). Per-app modules are opted-in inside each app's module.
    catppuccin = {
      flavor = cfg.flavour;
      accent = cfg.accent;
    };

    home.sessionVariables = {
      CATPPUCCIN_FLAVOUR = cfg.flavour;
      CATPPUCCIN_LIGHT_FLAVOUR = cfg.lightFlavour;
      CATPPUCCIN_ACCENT = cfg.accent;
    };
  };
}
