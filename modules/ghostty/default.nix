{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.ghostty;
in
{
  options.modules.ghostty = {
    enable = mkEnableOption "ghostty";
  };
  config = mkIf cfg.enable {
    # ghostty itself is installed via the homebrew cask (see
    # profiles/darwin/homebrew.nix). Setting package = null tells HM to
    # manage the config directory only — same pattern as zed.
    programs.ghostty = {
      enable = true;
      package = null;
      settings = {
        # Two font-family entries stack — JetBrainsMono for text, Symbols
        # Nerd Font as a fallback for glyphs/icons.
        font-family = [
          "JetBrainsMonoNL NF"
          "Symbols Nerd Font"
        ];
        font-size = 16;
        font-feature = "-calt,-liga,-dlig";
        adjust-cell-height = "8%";
        window-padding-x = 6;
        fullscreen = true;
      };
    };

    # Stylix writes the theme directly into the ghostty config. fonts
    # opt-out preserves our explicit font-size / font-family above.
    stylix.targets.ghostty = {
      enable = true;
      fonts.enable = false;
    };
  };
}
