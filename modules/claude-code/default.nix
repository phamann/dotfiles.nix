{
  pkgs,
  lib,
  config,
  inputs,
  system,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf optionalAttrs;
  inherit (config.modules) claude-code;
  inherit (config.modules.theme) semantic;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  mcpWrappers = import ../../lib/mcp-wrappers.nix { inherit pkgs; };

  # Wrapper that injects GitHub token once at claude launch; inherited by all child processes
  claudeWithToken = pkgs.writeShellScriptBin "claude" ''
    export GITHUB_PERSONAL_ACCESS_TOKEN="$(${pkgs._1password-cli}/bin/op read 'op://Private/github-pat/password' 2>/dev/null)"
    exec ${inputs.claude-code-nix.packages.${system}.claude-code}/bin/claude "$@"
  '';

in
{
  options.modules.claude-code = {
    enable = mkEnableOption "claude-code";
  };

  config = mkIf claude-code.enable {
    programs.claude-code = {
      enable = true;
      package = claudeWithToken;

      settings = {
        includeCoAuthoredBy = true;
        model = "claude-opus-4-7[1m]";
        mcpServers = {
          context7 = {
            command = "${mcpWrappers.context7}";
            args = [ ];
          };
          "chrome-devtools" = {
            command = "npx";
            args = [
              "-y"
              "chrome-devtools-mcp@latest"
            ];
          };
        };
        permissions = {
          additionalDirectories = [
            "/Users/phamann/Projects/core"
            "/Users/phamann/Projects/infrastructure"
            "/Users/phamann/Projects/manifests"
            "/Users/phamann/Projects/mobile-app"
          ];
          allow = [
            "Bash(gh:*)"
            "Bash(git:*)"
            "Bash(go:*)"
            "Bash(ginkgo:*)"
            "Bash(yarn:*)"
            "Bash(npm:*)"
            "Bash(bun:*)"
            "Bash(make:*)"
            "Bash(rg:*)"
            "Bash(tree:*)"
            "Bash(jq:*)"
            "Bash(find:*)"
            "Bash(say:*)"
            "Bash(ls:*)"
            "Bash(cat:*)"
            "Bash(less:*)"
            "Bash(head:*)"
            "Bash(tail:*)"
            "Bash(grep:*)"
            "Bash(pwd:*)"
            "Bash(wc:*)"
            "Bash(diff:*)"
            "Bash(bq:*)"
            "WebSearch"
            "WebFetch"
            "mcp__Sentry__get_list_issues"
            "mcp__Sentry__resolve_short_id"
            "mcp__Sentry__get_sentry_event"
            "mcp__Sentry__list_projects"
            "mcp__Sentry__get_issue_details"
            "mcp__Sentry__search_docs"
            "mcp__github__get_pull_request"
            "mcp__github__get_pull_request_files"
            "mcp__linear__list_issues"
            "mcp__linear__get_issue"
            "mcp__linear__list_comments"
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
      }
      // optionalAttrs isDarwin {
        # macOS-specific: osascript for notifications, claude-statusline
        # binary installed via the system Homebrew (configuration.nix).
        hooks = {
          Stop = [
            {
              hooks = [
                {
                  type = "command";
                  command = "osascript -e 'display notification \"Claude has finished\" with title \"Claude Code\"'";
                }
              ];
            }
          ];
        };
        statusLine = {
          type = "command";
          command = "/opt/homebrew/bin/claude-statusline prompt";
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
        - When interacting with Github (pull request actions, comments etc.) ALWAYS prefer using the `gh` CLI over the Github MCP or other actions.
      '';
    };

    home.file.".config/claude-statusline/config.toml".source = pkgs.replaceVars ./config.toml {
      inherit (semantic)
        primary
        success
        accent
        warning
        accentAlt
        ;
    };
  };
}
