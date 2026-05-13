{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.fzf;
in
{
  options.modules.fzf = {
    enable = mkEnableOption "fzf";
  };
  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--height 40%"
        "--multi"
        "--border none"
      ];
    };
    catppuccin.fzf.enable = true;
  };
}
