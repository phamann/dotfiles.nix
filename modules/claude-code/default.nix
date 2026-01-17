{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.claude-code;

  # Wrapper script to inject API key from decrypted secret
  context7Wrapper = pkgs.writeShellScript "context7-mcp" ''
    export UPSTASH_CONTEXT7_API_KEY="$(cat ${config.age.secrets.context7-api-key.path})"
    exec ${pkgs.nodejs}/bin/npx -y @upstash/context7-mcp "$@"
  '';

  # CCometixLine - statusline for Claude Code
  ccline = pkgs.rustPlatform.buildRustPackage rec {
    pname = "ccline";
    version = "1.0.9";

    src = pkgs.fetchFromGitHub {
      owner = "Haleclipse";
      repo = "CCometixLine";
      rev = "v${version}";
      sha256 = "sha256-afXdP8TSXBVb3J3eYqz+CIpomRNUza2jQtA96Wu6Rkk=";
    };

    cargoHash = "sha256-hWsxdl6qabU9x8oMW8f1sH6B2KHeU8ZNxm2wPUpERxc=";

    # Binary is named ccometixline, create ccline symlink for convenience
    postInstall = ''
      ln -s $out/bin/ccometixline $out/bin/ccline
    '';

    meta = with lib; {
      description = "High-performance statusline for Claude Code";
      homepage = "https://github.com/Haleclipse/CCometixLine";
      platforms = platforms.unix;
    };
  };
in
{
  options.modules.claude-code = {
    enable = mkEnableOption "claude-code";
  };

  config = mkIf cfg.enable {
    # Decrypt API key at activation time
    age.secrets.context7-api-key = {
      file = ../../secrets/context7-api-key.age;
    };

    programs.claude-code = {
      enable = true;
      package = pkgs.unstable.claude-code;

      settings = {
        awsAuthRefresh = "aws sso login --profile bedrock";
        env = {
          CLAUDE_CODE_USE_BEDROCK = "1";
          AWS_REGION = "eu-west-1";
          AWS_PROFILE = "bedrock";
          ANTHROPIC_MODEL = "arn:aws:bedrock:eu-west-1:635784355978:inference-profile/global.anthropic.claude-opus-4-5-20251101-v1:0";
          ANTHROPIC_DEFAULT_OPUS_MODEL = "arn:aws:bedrock:eu-west-1:635784355978:inference-profile/global.anthropic.claude-opus-4-5-20251101-v1:0";
          ANTHROPIC_DEFAULT_SONNET_MODEL = "arn:aws:bedrock:eu-west-1:635784355978:inference-profile/global.anthropic.claude-sonnet-4-5-20250929-v1:0";
          ANTHROPIC_DEFAULT_HAIKU_MODEL = "arn:aws:bedrock:eu-west-1:635784355978:inference-profile/eu.anthropic.claude-haiku-4-5-20251001-v1:0";
        };
        permissions = {
          allow = [
            "ReadFile"
            "Edit"
            "Bash(git add .)"
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
        };
        statusLine = {
          command = "${ccline}/bin/ccline --theme catppuccin-frappe";
          type = "command";
          padding = 0;
        };
      };

      # MCP servers - uses wrapper script to inject API key at runtime
      mcpServers = {
        context7 = {
          command = "${context7Wrapper}";
          args = [ ];
        };
      };

      # User memory/instructions
      memory.text = ''
        When creating git commit messages ALWAYS use conventional commit style: https://www.conventionalcommits.org/en/v1.0.0/#specification
        When creating pull requests in Github ALWAYS mark them in draft status
      '';
    };

    # ccline configuration - use catppuccin-frappe theme
    home.file.".claude/ccline/config.toml".text = ''
      theme = "catppuccin-frappe"
    '';

    # Catppuccin Frappe theme for ccline (minimal style - colored text, no background)
    home.file.".claude/ccline/themes/catppuccin-frappe.toml".text = ''
      # Catppuccin Frappe theme for CCometixLine
      # https://github.com/catppuccin/catppuccin
      theme = "catppuccin-frappe"

      [style]
      mode = "nerd_font"
      separator = " │ "

      # Model segment - Mauve (#ca9ee6)
      [[segments]]
      id = "model"
      enabled = false

      [segments.icon]
      plain = "🤖"
      nerd_font = ""

      [segments.colors.icon]
      r = 202
      g = 158
      b = 230

      [segments.colors.text]
      r = 202
      g = 158
      b = 230

      [segments.styles]
      text_bold = false

      [segments.options]

      # Directory segment - Blue (#8caaee)
      [[segments]]
      id = "directory"
      enabled = true

      [segments.icon]
      plain = "📁"
      nerd_font = "󰉋"

      [segments.colors.icon]
      r = 140
      g = 170
      b = 238

      [segments.colors.text]
      r = 140
      g = 170
      b = 238

      [segments.styles]
      text_bold = false

      [segments.options]

      # Git segment - Green (#a6d189)
      [[segments]]
      id = "git"
      enabled = true

      [segments.icon]
      plain = "🌿"
      nerd_font = "󰊢"

      [segments.colors.icon]
      r = 166
      g = 209
      b = 137

      [segments.colors.text]
      r = 166
      g = 209
      b = 137

      [segments.styles]
      text_bold = false

      [segments.options]
      show_sha = false

      # Context Window segment - Lavender (#babbf1)
      [[segments]]
      id = "context_window"
      enabled = true

      [segments.icon]
      plain = "⚡️"
      nerd_font = ""

      [segments.colors.icon]
      r = 186
      g = 187
      b = 241

      [segments.colors.text]
      r = 186
      g = 187
      b = 241

      [segments.styles]
      text_bold = false

      [segments.options]

      # Usage segment - Peach (#ef9f76)
      [[segments]]
      id = "usage"
      enabled = true

      [segments.icon]
      plain = "📊"
      nerd_font = "󰪞"

      [segments.colors.icon]
      r = 239
      g = 159
      b = 118

      [segments.colors.text]
      r = 239
      g = 159
      b = 118

      [segments.styles]
      text_bold = false

      [segments.options]
      timeout = 2
      api_base_url = "https://api.anthropic.com"
      cache_duration = 180

      # Cost segment - Yellow (#e5c890)
      [[segments]]
      id = "cost"
      enabled = true

      [segments.icon]
      plain = "💰"
      nerd_font = ""

      [segments.colors.icon]
      r = 229
      g = 200
      b = 144

      [segments.colors.text]
      r = 229
      g = 200
      b = 144

      [segments.styles]
      text_bold = false

      [segments.options]

      # Session segment - Teal (#81c8be)
      [[segments]]
      id = "session"
      enabled = true

      [segments.icon]
      plain = "⏱️"
      nerd_font = "󱦻"

      [segments.colors.icon]
      r = 129
      g = 200
      b = 190

      [segments.colors.text]
      r = 129
      g = 200
      b = 190

      [segments.styles]
      text_bold = false

      [segments.options]

      # Output Style segment - Sky (#99d1db)
      [[segments]]
      id = "output_style"
      enabled = true

      [segments.icon]
      plain = "🎯"
      nerd_font = "󱋵"

      [segments.colors.icon]
      r = 153
      g = 209
      b = 219

      [segments.colors.text]
      r = 153
      g = 209
      b = 219

      [segments.styles]
      text_bold = false

      [segments.options]
    '';
  };
}
