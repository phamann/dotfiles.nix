{ pkgs, lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.direnv;
in {
  options.modules.direnv = { enable = mkEnableOption "direnv"; };
  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      package = pkgs.direnv;
    };
  };
}
