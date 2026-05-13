{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.opencode;
  themeCfg = config.modules.theme;

  mcpWrappers = import ../../lib/mcp-wrappers.nix { inherit pkgs; };

  # Thin wrapper: inject the GitHub PAT for opencode's gh-flavoured tools.
  opencodeWithGhToken = pkgs.writeShellScriptBin "opencode" ''
    export GITHUB_PERSONAL_ACCESS_TOKEN="$(${pkgs._1password-cli}/bin/op read 'op://Private/github-pat/password' 2>/dev/null)"
    exec ${pkgs.unstable.opencode}/bin/opencode "$@"
  '';
in
{
  options.modules.opencode = {
    enable = mkEnableOption "opencode";
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package = opencodeWithGhToken;

      settings = {
        theme = "catppuccin-${themeCfg.flavour}";

        provider = {
          # Local models served by LM Studio's OpenAI-compatible API.
          # The model ID below must match what LM Studio reports at
          # `curl http://127.0.0.1:1234/v1/models`. Adjust if LM Studio
          # exposes a different identifier for the loaded GGUF.
          "lmstudio" = {
            npm = "@ai-sdk/openai-compatible";
            name = "LM Studio (local)";
            options = {
              baseURL = "http://127.0.0.1:1234/v1";
            };
            models = {
              "qwen3.6-35b-a3b" = {
                name = "Qwen3.6 35B-A3B (local)";
                cost = {
                  input = 0.0;
                  output = 0.0;
                };
                limit = {
                  context = 32768;
                  output = 16384;
                };
              };
              "zai-org/glm-4.7-flash" = {
                name = "GLM 4.7 Flash (local)";
              };
            };
          };
        };

        # Default to the local Qwen MoE model.
        model = "lmstudio/qwen3.6-35b-a3b";

        mcp = {
          context7 = {
            type = "local";
            command = [ "${mcpWrappers.context7}" ];
          };
        };
      };

      # Aligned with claude-code's memory.text rather than a divergent subset.
      rules = ''
        # Working relationship
        - No sycophancy.
        - Be direct, matter-of-fact, and concise.
        - Be critical; challenge my reasoning.
        - Don't include timeline estimates in plans.

        # Tooling
        - Prefer Makefile targets (`make help`) over direct tool invocation.
        - When creating git commit messages ALWAYS use conventional commit style: https://www.conventionalcommits.org/en/v1.0.0/#specification
        - When creating pull requests in Github ALWAYS mark them in draft status.
      '';
    };
  };
}
