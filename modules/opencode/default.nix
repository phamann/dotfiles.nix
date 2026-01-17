{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.opencode;

  # Wrapper script to inject API key from decrypted secret
  context7Wrapper = pkgs.writeShellScript "context7-mcp" ''
    export UPSTASH_CONTEXT7_API_KEY="$(cat ${config.age.secrets.context7-api-key.path})"
    exec ${pkgs.nodejs}/bin/npx -y @upstash/context7-mcp "$@"
  '';
in
{
  options.modules.opencode = { enable = mkEnableOption "opencode"; };

  config = mkIf cfg.enable {
    # Reuse context7 API key secret (already defined in claude-code module)
    age.secrets.context7-api-key = {
      file = ../../secrets/context7-api-key.age;
    };

    programs.opencode = {
      enable = true;
      package = pkgs.unstable.opencode;

      settings = {
        # Theme
        theme = "catppuccin-frappe";

        # AWS Bedrock provider config (matching claude-code)
        provider = {
          "amazon-bedrock" = {
            options = {
              region = "eu-west-1";
              profile = "bedrock";
            };
            models = {
              "global.anthropic.claude-sonnet-4-5-20250929-v1:0" = {
                name = "Claude Sonnet 4";
                cost = {
                  input = 3.0;
                  output = 15.0;
                };
                limit = {
                  context = 200000;
                  output = 16000;
                };
              };
              "global.anthropic.claude-opus-4-5-20251101-v1:0" = {
                name = "Claude Opus 4.5";
                cost = {
                  input = 15.0;
                  output = 75.0;
                };
                limit = {
                  context = 200000;
                  output = 16000;
                };
              };
              "eu.anthropic.claude-haiku-4-5-20251001-v1:0" = {
                name = "Claude Haiku 4";
                cost = {
                  input = 0.8;
                  output = 4.0;
                };
                limit = {
                  context = 200000;
                  output = 8192;
                };
              };
            };
          };
        };

        # Default model (Claude Opus 4.5 via Bedrock)
        model = "amazon-bedrock/global.anthropic.claude-opus-4-5-20251101-v1:0";

        # MCP servers
        mcp = {
          context7 = {
            type = "local";
            command = [ "${context7Wrapper}" ];
          };
        };
      };

      # Rules (equivalent to claude-code memory)
      rules = ''
        When creating git commit messages ALWAYS use conventional commit style: https://www.conventionalcommits.org/en/v1.0.0/#specification
        When creating pull requests in Github ALWAYS mark them in draft status
      '';
    };
  };
}
