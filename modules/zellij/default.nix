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
    concatMapStringsSep
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

  # zjstatus renders {name} as the InputMode debug name ("Normal",
  # "EnterSearch") with no case option, so spell out every mode in the
  # uppercase form compact-bar used ("NORMAL", "ENTERSEARCH").
  modeColours = {
    normal = success;
    locked = error;
  };
  modeFormats = concatMapStringsSep "\n" (
    mode:
    let
      label = lib.toUpper (lib.replaceStrings [ "_" ] [ "" ] mode);
      colour = modeColours.${mode} or warning;
    in
    ''mode_${mode} "#[bg=${bgAlt},fg=${colour},bold] ${label} "''
  ) inputModes;
  # zjstatus's mode_<name> config suffixes.
  inputModes = [
    "normal"
    "locked"
    "resize"
    "pane"
    "tab"
    "scroll"
    "enter_search"
    "search"
    "rename_tab"
    "rename_pane"
    "session"
    "move"
    "prompt"
    "tmux"
  ];

  # Every segment paints its own background so the bar reads as one band
  # in bgAlt, like compact-bar did. Options: https://github.com/dj95/zjstatus/wiki
  bar = ''
    pane size=1 borderless=true {
        plugin location="file:${zjstatus}/bin/zjstatus.wasm" {
            format_left  "{mode}{tabs}"
            format_right "{datetime}"
            format_space "#[bg=${bgAlt}]"

            // The wasm sandbox can't read the system timezone, so it's set here.
            datetime          "#[bg=${bgAlt},fg=${fgAlt}] {format} "
            datetime_format   "%a %d %b %H:%M"
            datetime_timezone "${cfg.timezone}"

            // pane_frames is off globally; let zellij own frames.
            hide_frame_for_single_pane "false"

            ${modeFormats}

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
          ${concatStringsSep "\n" (lib.imap0 mkTab cfg.tabs)}
      }
    '';

  # Startup tabs: main pane (65%) on the left, two stacked panes on the
  # right. Tabs opened later fall back to default_tab_template (bar + one
  # pane).
  mkTab =
    i: tab:
    let
      attr = key: value: lib.optionalString (value != null) ''${key}="${value}"'';
      # KDL strings accept JSON escaping, so toJSON quotes args safely.
      mainPane =
        if tab.command == null then
          ''pane size="65%" focus=true''
        else
          ''pane size="65%" focus=true command=${builtins.toJSON (lib.head tab.command)} { args ${
            concatMapStringsSep " " builtins.toJSON (lib.tail tab.command)
          }; }'';
    in
    ''
      tab ${attr "name" tab.name} ${attr "cwd" tab.cwd} focus=${lib.boolToString (i == 0)} {
          pane split_direction="vertical" {
              ${mainPane}
              pane split_direction="horizontal" {
                  pane
                  pane
              }
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
    timezone = mkOption {
      type = types.str;
      default = "Europe/London";
      description = "IANA timezone for the zjstatus clock (chrono-tz name).";
    };
    tabs = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            cwd = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Absolute starting directory for every pane in the tab.";
            };
            command = mkOption {
              type = types.nullOr (types.nonEmptyListOf types.str);
              default = null;
              example = [
                "claude"
                "agents"
              ];
              description = "Program + args the main pane runs instead of a shell.";
            };
          };
        }
      );
      default = [ { } ];
      description = "Tabs opened at session start, each with the 65/35 three-pane workspace.";
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

    # Pane frames are on for padding: drawn in bgAlt (the status bar band)
    # they read as a faint line with a 1-cell gutter around each pane.
    # frame_highlight (PANE/RESIZE/MOVE modes) keeps Stylix's colour so you
    # can see which pane a mode will act on. Stylix defines no
    # frame_unselected, so it's declared in full here.
    programs.zellij.themes.stylix.themes.default =
      let
        faint = {
          base = bgAlt;
          background = bg;
          emphasis_0 = bgAlt;
          emphasis_1 = bgAlt;
          emphasis_2 = bgAlt;
          emphasis_3 = bgAlt;
        };
      in
      {
        frame_selected = lib.mapAttrs (_: lib.mkForce) faint;
        frame_unselected = faint;
      };
  };
}
