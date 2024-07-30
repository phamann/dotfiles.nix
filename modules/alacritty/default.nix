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

            /*
            JetBrains  Mono
            ========================================
            */
            font = {
              normal = {
                family = "JetBrainsMono Nerd Font Mono";
                style = "Light";
              };
              bold = {
                style = "Semibold";
              };
              italic = {
                style = "Light Italic";
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

              /*
            Fira Code
            ========================================
            font = {
              normal = {
                family = "FiraCode Nerd Font Mono";
                style = "Light";
              };
              bold = {
                style = "Semibold";
              };
              italic = {
                  style = "Light Italic";
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
              };*/
              /*
              Operator Mono
              ========================================

              normal = {
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

            keyboard = {
              bindings = [
                { chars = "\\u001BT"; key = "T"; mods = "Command"; }
              ];
            };

            window = {
              padding = {
                x = 6;
              };
              startup_mode = "Fullscreen";
              option_as_alt = "OnlyRight";
            };

            /*
            # tokyo-night-storm: &tokyo-night-storm
            colors = {
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
            };
            */
            /*
            #Kanagawa Alacritty Colors
            colors = {
              primary = {
                background = "0x1f1f28";
                foreground = "0xdcd7ba";
              };
              normal = {
                black = "0x090618";
                red = "0xc34043";
                green = "0x76946a";
                yellow = "0xc0a36e";
                blue = "0x7e9cd8";
                magenta = "0x957fb8";
                cyan = "0x6a9589";
                white = "0xc8c093";
              };
              bright = {
                black = "0x727169";
                red = "0xe82424";
                green = "0x98bb6c";
                yellow = "0xe6c384";
                blue = "0x7fb4ca";
                magenta = "0x938aa9";
                cyan = "0x7aa89f";
                white = "0xdcd7ba";
              };
              selection = {
                background = "0x2d4f67";
                foreground = "0xc8c093";
              };
              indexed_colors = [
                { index = 16; color = "0xffa066"; }
                { index = 17; color = "0xff5d62"; }
              ];
            };
            */

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
            /*
            # (Github Dark) Colors for Alacritty
            colors = {
              # Default colors
              primary = {
                background = "0x30363d";
                foreground = "0xe6edf3";
              };
              # Cursor colors
              #
              # These will only be used when the `custom_cursor_colors` field is set to `true`.
              cursor = {
                text = "0x30363d";
                cursor = "0xe6edf3";
              };
              # Normal colors
              normal = {
                black = "0x484f58";
                red = "0xff7b72";
                green = "0x3fb950";
                yellow = "0xd29922";
                blue = "0x58a6ff";
                magenta = "0xbc8cff";
                cyan = "0x39c5cf";
                white = "0xb1bac4";
              };
              # Bright colors
              bright = {
                black = "0x6e7681";
                red = "0xffa198";
                green = "0x56d364";
                yellow = "0xe3b341";
                blue = "0x79c0ff";
                magenta = "0xbc8cff";
                cyan = "0x39c5cf";
                white = "0xb1bac4";
              };
            };
            */
            /*
            # (Github Dark Dimmed) Colors for Alacritty
            colors = {
              # Default colors
              primary = {
                background = "0x22272e";
                foreground = "0xadbac7";
              };
              # Cursor colors
              #
              # These will only be used when the `custom_cursor_colors` field is set to `true`.
              cursor = {
                text = "0x22272e";
                cursor = "0xadbac7";
              };
              # Normal colors
              normal =
                {
                  black = "0x545d68";
                  red = "0xf47067";
                  green = "0x57ab5a";
                  yellow = "0xc69026";
                  blue = "0x539bf5";
                  magenta = "0xb083f0";
                  cyan = "0x39c5cf";
                  white = "0x909dab";
                };
              # Bright colors
              bright = {
                black = "0x636e7b";
                red = "0xff938a";
                green = "0x6bc46d";
                yellow = "0xdaaa3f";
                blue = "0x6cb6ff";
                magenta = "0xb083f0";
                cyan = "0x39c5cf";
                white = "0x909dab";
              };
            };
            */

            # Material
            /* colors = {
              # Default colors
              primary = {
                background = "#1e282d";
                foreground = "#c4c7d1";
              };
              # Normal colors
              normal = {
                black = "#666666";
                red = "#eb606b";
                green = "#c3e88d";
                yellow = "#f7eb95";
                blue = "#80cbc4";
                magenta = "#ff2f90";
                cyan = "#aeddff";
                white = "#ffffff";
              };
              # Bright colors
              bright = {
                black = "#ff262b";
                red = "#eb606b";
                green = "#c3e88d";
                yellow = "#f7eb95";
                blue = "#7dc6bf";
                magenta = "#6c71c4";
                cyan = "#35434d";
                white = "#ffffff";
              };
            }; */
          };
        };
      };
}
