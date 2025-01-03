{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.zed;
in
{
  options.modules.zed = { enable = mkEnableOption "zed"; };
  config =
    mkIf cfg.enable {
      programs.zed-editor = {
        enable = true;
        extensions = [
        "cue"
        "docker-compose"
        "dockerfile"
        "env"
        "helm"
        "http"
        "nginx"
        "nix"
        "one-dark-flat"
        "one-dark-pro"
        "perl"
        "rego"
        "ruby"
        "sql"
        "xml"
        ];
      };
    };
}
