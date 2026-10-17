{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.bat;
in
{
  options.modules.bat = {
    enable = mkEnableOption "bat";
  };
  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
    };
    stylix.targets.bat.enable = true;
  };
}
