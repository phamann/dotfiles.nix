{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.omp;
in
{
  imports = [ inputs.omp.homeManagerModules.default ];

  options.modules.omp = {
    enable = lib.mkEnableOption "Oh My Pi";
  };

  config = lib.mkIf cfg.enable {
    programs.omp = {
      enable = true;

      settings.startup.quiet = true;
    };
  };
}
