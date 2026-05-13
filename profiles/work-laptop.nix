{ pkgs, ... }:
{
  # incident.io work laptop. Inherits everything dev-laptop has, adds
  # company-specific tooling and env.
  imports = [ ./dev-laptop.nix ];

  # incident.io infra tools.
  home.packages = with pkgs; [
    caddy
    grafana-alloy
    haproxy
    ngrok
  ];

  # incident.io engineering env. Pre-Phase-4 these lived in modules/zsh
  # behind a `modules.zsh.work` flag — now they're owned by the profile.
  home.sessionVariables = {
    GOOGLE_GENAI_USE_VERTEXAI = "true";
    GOOGLE_CLOUD_PROJECT = "vertexai-core-misc-b097";
    GOOGLE_CLOUD_LOCATION = "global";
    GOOGLE_VERTEX_PROJECT = "vertexai-core-misc-b097";
    GOOGLE_VERTEX_LOCATION = "global";
  };
  home.sessionPath = [ "/opt/homebrew/opt/postgresql@17/bin" ];
}
