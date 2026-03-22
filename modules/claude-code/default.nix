{ pkgs, lib, config, inputs, system, ... }:
with lib;
let
  cfg = config.modules.claude-code;

  # Wrapper script to inject API key from 1Password at runtime
  context7Wrapper = pkgs.writeShellScript "context7-mcp" ''
    export UPSTASH_CONTEXT7_API_KEY="$(${pkgs._1password-cli}/bin/op read 'op://Private/context7-api-token/password')"
    exec ${pkgs.nodejs}/bin/npx -y @upstash/context7-mcp "$@"
  '';

in
{
  options.modules.claude-code = { enable = mkEnableOption "claude-code"; };

  config = mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      package = inputs.claude-code-nix.packages.${system}.claude-code;

      settings = {
        permissions = {
          allow = [
            "ReadFile"
            "Edit"
            "Bash(git add:*)"
            "Bash(git commit -m:*)"
            "Bash(git diff:*)"
            "Bash(gh pr diff:*)"
            "Bash(gh pr view:*)"
            "Bash(gh pr list:*)"
            "Bash(curl:*)"
            "Bash(mvn:*)"
            "WebFetch"
            "Bash(go test:*)"
            "Bash(go run:*)"
            "Bash(make test:*)"
          ];
        };
        enabledPlugins = {
          "context7@claude-plugins-official" = true;
          "github@claude-plugins-official" = true;
          "explanatory-output-style@claude-plugins-official" = true;
          "pr-review-toolkit@claude-plugins-official" = true;
          "feature-dev@claude-plugins-official" = true;
          "code-review@claude-plugins-official" = true;
          "commit-commands@claude-plugins-official" = true;
          "typescript-lsp@claude-plugins-official" = true;
          "gopls-lsp@claude-plugins-official" = true;
          "rust-analyzer-lsp@claude-plugins-official" = true;
          "superpowers@superpowers-marketplace" = true;
        };
        extraKnownMarketplaces = {
          superpowers-marketplace = {
            source = {
              source = "github";
              repo = "obra/superpowers-marketplace";
            };
          };
        };
        statusLine = {
          type = "command";
          command = "/opt/homebrew/bin/claude-statusline prompt";
        };
      };

      # MCP servers - uses wrapper script to inject API key at runtime
      mcpServers = {
        context7 = {
          command = "${context7Wrapper}";
          args = [ ];
        };
        "chrome-devtools" = {
          command = "npx";
          args = [ "-y" "chrome-devtools-mcp@latest" ];
        };
      };

      # User memory/instructions
      memory.text = ''
        # Working relationship
        - No sycophancy.
        - Be direct, matter-of-fact, and concise.
        - Be critical; challenge my reasoning.
        - Don't include timeline estimates in plans.

        # Tooling

        ## General
        - Prefer Makefile targets (`make help`) over direct tool invocation.
        - Use your Edit tool for changes; Search tool for searching.
        - Use Mermaid diagrams for complex systems.

        ## Git
        - When creating git commit messages ALWAYS use [conventional commit style](https://www.conventionalcommits.org/en/v1.0.0/#specification).
        - When creating pull requests in Github ALWAYS mark them in draft status.
      '';
    };

    home.file.".config/claude-statusline/config.toml".source = ./config.toml;
  };
}
