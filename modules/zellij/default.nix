{
  pkgs,
  lib,
  config,
  inputs,
  system,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.modules.zellij;
  inherit (config.modules.theme.semantic)
    bg
    bgAlt
    fgAlt
    primary
    success
    warning
    error
    ;

  zjstatus = inputs.zjstatus.packages.${system}.default;

  # Every segment paints its own background so the bar reads as one band
  # in bgAlt, like compact-bar did. Options: https://github.com/dj95/zjstatus/wiki
  bar = ''
    pane size=1 borderless=true {
        plugin location="file:${zjstatus}/bin/zjstatus.wasm" {
            format_left  "{mode}{tabs}"
            format_right ""
            format_space "#[bg=${bgAlt}]"

            // pane_frames is off globally; let zellij own frames.
            hide_frame_for_single_pane "false"

            mode_normal          "#[bg=${bgAlt},fg=${success},bold] {name} "
            mode_locked          "#[bg=${bgAlt},fg=${error},bold] {name} "
            mode_tmux            "#[bg=${bgAlt},fg=${warning},bold] {name} "
            mode_default_to_mode "tmux"

            tab_normal   "#[bg=${bgAlt},fg=${fgAlt}] {name} "
            tab_active   "#[bg=${primary},fg=${bg},bold] {name} {floating_indicator}{fullscreen_indicator}{sync_indicator}"
            tab_rename   "#[bg=${warning},fg=${bg},bold] {name} "

            tab_floating_indicator   "󰉈 "
            tab_fullscreen_indicator "󰊓 "
            tab_sync_indicator       "󰓦 "
        }
    }
  '';

  mkLayout =
    position:
    pkgs.writeText "zellij-compact-${position}.kdl" ''
      layout {
          default_tab_template {
              ${concatStringsSep "\n" (
                if position == "top" then
                  [
                    bar
                    "children"
                  ]
                else
                  [
                    "children"
                    bar
                  ]
              )}
          }
      }
    '';
in
{
  options.modules.zellij = {
    enable = mkEnableOption "zellij";
    layout = mkOption {
      type = types.enum [
        "compact-top"
        "compact-bottom"
      ];
      default = "compact-top";
    };
  };
  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      package = pkgs.unstable.zellij;
    };
    home.file = {
      ".config/zellij/layouts/compact-top.kdl".source = mkLayout "top";
      ".config/zellij/layouts/compact-bottom.kdl".source = mkLayout "bottom";
      ".config/zellij/config.kdl".source = pkgs.replaceVars ./config.kdl {
        layout = "${cfg.layout}";
      };
    };

    # Themes zellij's own UI (frames, prompts); zjstatus is coloured above.
    stylix.targets.zellij.enable = true;
  };
}
