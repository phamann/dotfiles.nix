{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.k9s;
in
{
  options.modules.k9s = {
    enable = mkEnableOption "k9s";
  };
  config = mkIf cfg.enable {
    programs.k9s.enable = true;
    stylix.targets.k9s.enable = true;
  };
}
