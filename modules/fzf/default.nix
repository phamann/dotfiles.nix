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
        defaultOptions = [ "--height 40%" "--reverse" "--border none" ];
        colors = {
          bg = "#24283b";
          "bg+" = "#292e42";
          fg = "#c0caf5";
          "fg+" = "#c0caf5";
          hl = "#ff9e64";
          "hl+" = "#ff9e64";
          info = "#7aa2f7";
          prompt = "#7dcfff";
          pointer = "#7dcfff";
          marker = "#9ece6a";
          spinner = "#9ece6a";
          header = "#9ece6a";
        };
      };
    };
}
