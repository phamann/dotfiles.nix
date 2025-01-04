{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.fzf;
in
{
  options.modules.fzf = { enable = mkEnableOption "fzf"; };
  config =
    mkIf cfg.enable {
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultOptions = [ "--height 40%" "--multi" "--border none" ];

        #  Catppuccin Frappe
        colors = {
          bg = "#303446";
          "bg+" = "#414559";
          fg = "#c6d0f5";
          "fg+" = "#c6d0f5";
          hl = "#e78284";
          "hl+" = "#e78284";
          info = "#ca9ee6";
          prompt = "#ca9ee6";
          pointer = "#f2d5cf";
          marker = "#babbf1";
          spinner = "#f2d5cf";
          header = "#e78284";
        };

        # one dark
        # colors = {
        #   bg = "#282c34";
        #   "bg+" = "#353b45";
        #   fg = "#565c64";
        #   "fg+" = "#b6bdca";
        #   hl = "#61afef";
        #   "hl+" = "#61afef";
        #   info = "#e5c07b";
        #   prompt = "#e5c07b";
        #   pointer = "#56b6c2";
        #   marker = "#56b6c2";
        #   spinner = "#56b6c2";
        #   header = "#61afef";
        # };
        # tokyonight
        # colors = {
        #   bg = "#24283b";
        #   "bg+" = "#292e42";
        #   fg = "#c0caf5";
        #   "fg+" = "#c0caf5";
        #   hl = "#ff9e64";
        #   "hl+" = "#ff9e64";
        #   info = "#7aa2f7";
        #   prompt = "#7dcfff";
        #   pointer = "#7dcfff";
        #   marker = "#9ece6a";
        #   spinner = "#9ece6a";
        #   header = "#9ece6a";
        # };
        # Github dark
        /*
        colors = {
          fg = "#848d97";
          bg = "#30363d";
          hl = "#ffffff";
          "fg+" = "#e6edf3";
          "bg+" = "#313f50";
          "hl+" = "#ffa657";
          info = "#d29922";
          prompt = "#2f81f7";
          pointer = "#a371f7";
          marker = "#3fb950";
          spinner = "#6e7681";
          header = "#495058";
        };
        */
        /*
        # Github dark dimmed
        colors = {
          fg = "#768390";
          bg = "#22272e";
          hl = "#cdd9e5";
          "fg+" = "#adbac7";
          "bg+" = "#253040";
          "hl+" = "#f69d50";
          info = "#c69026";
          prompt = "#539bf5";
          pointer = "#986ee2";
          marker = "#57ab5a";
          spinner = "#636e7b";
          header = "#3c434d";
        };
        */
      };
    };
}
