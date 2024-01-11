{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.alacritty;
in
{
  options.modules.alacritty = { enable = mkEnableOption "alacritty"; };
  config =
    mkIf cfg.enable
      {
        programs.alacritty = {
          enable = true;
          settings = {
            scrolling = {
              # Maximum number of lines in the scrollback buffer.
              # Specifying '0' will disable scrolling.
              history = 20000;
            };

            font = {
              normal = {
                family = "JetBrainsMono Nerd Font Mono";
                style = "ExtraLight";
              };
              bold = {
                style = "Semibold";
              };
              italic = {
                style = "ExtraLight Italic";
              };
              bold_italic = {
                style = "Semibold Italic";
              };
              size = 16;
              offset = {
                x = 0;
                y = 4;
              };
              glyph_offset = {
                x = 0;
                y = 2;
              };
              /* normal = {
                family = "OperatorMono Nerd Font Mono";
                style = "Regular";
              };
              bold = {
                style = "Bold";
              };
              italic = {
                style = "Book Italic";
              };
              bold_italic = {
                style = "Bold Italic";
              };
              size = 16;
              offset = {
                x = 1;
                y = 4;
              };
              glyph_offset = {
                x = 0;
                y = 2;
              };
              */
              builtin_box_drawing = true;
            };

            window = {
              padding = {
                x = 6;
              };
              startup_mode = "Fullscreen";
              option_as_alt = "OnlyRight";
            };

            # tokyo-night-storm: &tokyo-night-storm
            /* colors = {
              draw_bold_text_with_bright_colors = true;
              # Default colors
              primary = {
                background = "#24283b";
                foreground = "#a9b1d6";
              };

              # Normal colors
              normal = {
                black = "#32344a";
                red = "#f7768e";
                green = "#9ece6a";
                yellow = "#e0af68";
                blue = "#7aa2f7";
                magenta = "#ad8ee6";
                cyan = "#449dab";
                white = "#9699a8";
              };

              env = {
                TERM = "alacritty";
              };

              # Bright colors
              bright = {
                black = "#444b6a";
                red = "#ff7a93";
                green = "#b9f27c";
                yellow = "#ff9e64";
                blue = "#7da6ff";
                magenta = "#bb9af7";
                cyan = "#0db9d7";
                white = "#acb0d0";
              };
            }; */

            # TokyoNight Alacritty Colors
            # https://github.com/folke/tokyonight.nvim/blob/main/extras/alacritty/tokyonight_moon.yml
            colors = {
              # Default colors
              primary = {
                background = "0x222436";
                foreground = "0xc8d3f5";
              };
              # Normal colors
              normal = {
                black = "0x1b1d2b";
                red = "0xff757f";
                green = "0xc3e88d";
                yellow = "0xffc777";
                blue = "0x82aaff";
                magenta = "0xc099ff";
                cyan = "0x86e1fc";
                white = "0x828bb8";
              };
              # Bright colors
              bright = {
                black = "0x444a73";
                red = "0xff757f";
                green = "0xc3e88d";
                yellow = "0xffc777";
                blue = "0x82aaff";
                magenta = "0xc099ff";
                cyan = "0x86e1fc";
                white = "0xc8d3f5";
              };
              indexed_colors = [
                { index = 16; color = "0xff966c"; }
                { index = 17; color = "0xc53b53"; }
              ];
            };
          };
        };
      };
}
