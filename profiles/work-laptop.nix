_: {
  # incident.io work laptop. Inherits everything dev-laptop has, plus the
  # work packages sub-module and incident.io engineering env.
  imports = [ ./dev-laptop.nix ];

  modules.packages.work.enable = true;

  home = {
    # incident.io engineering env. Pre-Phase-4 these lived in modules/zsh
    # behind a `modules.zsh.work` flag; the profile owns them directly now.
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
