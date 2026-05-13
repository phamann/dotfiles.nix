{ pkgs, ... }:
{
  # incident.io work laptop. Inherits everything dev-laptop has, adds
  # company-specific tooling and env. Pre-Phase-4 the env vars and
  # postgresql@17 PATH lived in modules/zsh behind a `modules.zsh.work`
  # flag; now the profile owns them directly.
  imports = [ ./dev-laptop.nix ];

  home = {
    packages = with pkgs; [
      caddy
      grafana-alloy
      haproxy
      ngrok
    ];

    sessionVariables = {
      GOOGLE_GENAI_USE_VERTEXAI = "true";
      GOOGLE_CLOUD_PROJECT = "vertexai-core-misc-b097";
      GOOGLE_CLOUD_LOCATION = "global";
      GOOGLE_VERTEX_PROJECT = "vertexai-core-misc-b097";
      GOOGLE_VERTEX_LOCATION = "global";
    };

    sessionPath = [ "/opt/homebrew/opt/postgresql@17/bin" ];
  };
}
