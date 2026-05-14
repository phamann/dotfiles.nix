{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.packages.work;
in
{
  options.modules.packages.work.enable = mkEnableOption "incident.io infrastructure tooling";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      caddy
      grafana-alloy
      haproxy
      ngrok
    ];
  };
}
