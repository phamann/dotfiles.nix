{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    listToAttrs
    mkOption
    nameValuePair
    recursiveUpdate
    optionalAttrs
    types
    ;
  cfg = config.modules.pi;

  inherit (import ../../lib/color.nix { inherit lib; }) mix;

  # Raw base24 slots. Pi's theme wants 50+ tokens including a full syntax
  # palette, which `modules.theme.semantic` deliberately doesn't model — so
  # this is the same "reach for the palette" case as the nvim overrides
  # rather than the `semantic`-consuming case (claude-statusline).
  c = config.lib.stylix.colors.withHashtag;

  jsonFormat = pkgs.formats.json { };

  # Pi TUI theme derived from the active base24 scheme. Pi has no global
  # background token — it composites onto the terminal's own background,
  # which stylix already paints from this same scheme via ghostty.
  themeFile = jsonFormat.generate "pi-stylix-theme.json" {
    "$schema" =
      "https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json";
    name = "stylix";
    colors = {
      # Core UI
      accent = c.base0D;
      border = c.base03;
      borderAccent = c.base0D;
      borderMuted = c.base02;
      success = c.base0B;
      error = c.base08;
      warning = c.base0A;
      muted = c.base04;
      dim = c.base03;
      text = c.base05;
      thinkingText = c.base03;

      # Backgrounds and content
      selectedBg = c.base02;
      scrollbarThumb = c.base03;
      searchMatchBg = c.base02;
      searchMatchText = c.base0A;
      userMessageBg = c.base01;
      userMessageText = c.base05;
      customMessageBg = mix c.base01 c.base0E 12;
      customMessageText = c.base05;
      customMessageLabel = c.base0E;
      toolPendingBg = c.base01;
      toolSuccessBg = mix c.base01 c.base0B 15;
      toolErrorBg = mix c.base01 c.base08 15;
      toolTitle = c.base0D;
      toolOutput = c.base04;

      # Markdown
      mdHeading = c.base0D;
      mdLink = c.base0C;
      mdLinkUrl = c.base03;
      mdCode = c.base0B;
      mdCodeBlock = c.base05;
      mdCodeBlockBorder = c.base02;
      mdQuote = c.base04;
      mdQuoteBorder = c.base02;
      mdHr = c.base02;
      mdListBullet = c.base0E;

      # Diffs
      toolDiffAdded = c.base0B;
      toolDiffRemoved = c.base08;
      toolDiffContext = c.base04;

      # Syntax. `syntaxVariable` and `syntaxPunctuation` are recessed to
      # base05 for the same reason the nvim treesitter overrides recess
      # `@variable` / `@punctuation.*` — the base16 spec's accent-coloured
      # variables read as noise next to catppuccin/tokyonight.
      syntaxComment = c.base03;
      syntaxKeyword = c.base0E;
      syntaxFunction = c.base0D;
      syntaxVariable = c.base05;
      syntaxString = c.base0B;
      syntaxNumber = c.base09;
      syntaxType = c.base0A;
      syntaxOperator = c.base0C;
      syntaxPunctuation = c.base05;

      # Thinking-level indicator, ramped cool -> hot.
      thinkingOff = c.base03;
      thinkingMinimal = c.base04;
      thinkingLow = c.base0C;
      thinkingMedium = c.base0D;
      thinkingHigh = c.base0E;
      thinkingXhigh = c.base09;
      thinkingMax = c.base08;

      bashMode = c.base09;
    };
  };

  settingsFile = jsonFormat.generate "pi-settings.json" (
    {
      theme = "stylix";
      # Pi installs any missing entries from user settings on startup, so this
      # is the whole install step — no imperative `pi install` needed.
      inherit (cfg) packages;
      # Persist the fullscreen renderer, matching the claude-code `tui`
      # setting so both harnesses render the same way.
      tuiMode = "fullscreen";
      fullscreenCopyOnSelect = true;
      quietStartup = true;
      externalEditor = "nvim";
      markdown.mermaid = true;
      powerline = {
        placement = "below";
        separator = "pipe";
        # Keep other extension statuses, but suppress pi-lens's persistent LSP
        # summary. Declaring it as a custom item excludes it from the aggregate;
        # disabling that custom segment then prevents it rendering separately.
        customItems = [
          {
            id = "lsp";
            statusKey = "pi-lens-lsp";
            excludeFromExtensionStatuses = true;
          }
        ];
        disabledSegments = [
          "cost"
          "custom:lsp"
        ];
      };
    }
    // optionalAttrs (cfg.provider != null) { defaultProvider = cfg.provider; }
    // optionalAttrs (cfg.model != null) { defaultModel = cfg.model; }
    // cfg.settings
  );

  modelsFile = jsonFormat.generate "pi-models.json" { inherit (cfg) providers; };

  # MCP servers for pi-mcp-adapter. Pi core has no MCP support — the adapter
  # supplies it, and proxies every server behind a single ~200-token `mcp` tool
  # rather than injecting each server's full tool schema into the context.
  #
  # Remote servers need only a `url`: the adapter auto-detects OAuth from the
  # 401 + WWW-Authenticate challenge, and Linear/Notion/incident.io all publish
  # a registration_endpoint, so Dynamic Client Registration handles the client
  # with no clientId to configure. Authorise each once with `/mcp-auth <name>`.
  remoteMcpServers = {
    linear.url = "https://mcp.linear.app/mcp";
    notion.url = "https://mcp.notion.com/mcp";
    incident-io.url = "https://mcp.incident.io/mcp";
  };

  # Slack is the exception: its authorization-server metadata sets
  # `registration_endpoint: null`, so DCR is unavailable and OAuth cannot start
  # without a pre-registered client. Emitted only once a clientId is supplied,
  # rather than shipping a server that would fail at first auth.
  slackMcpServer = optionalAttrs (cfg.slack.clientId != null) {
    slack = {
      url = "https://mcp.slack.com/mcp";
      auth = "oauth";
      oauth = {
        inherit (cfg.slack) clientId scope;
      }
      // optionalAttrs (cfg.slack.clientSecretCommand != null) {
        # A leading `!` makes the adapter run this at authentication time, so
        # the secret is never written into the world-readable Nix store.
        clientSecret = "!${cfg.slack.clientSecretCommand}";
      }
      // optionalAttrs (cfg.slack.redirectUri != null) {
        inherit (cfg.slack) redirectUri;
      };
    };
  };

  localMcpServers = {
    chrome-devtools = {
      command = "${pkgs.nodejs}/bin/npx";
      args = [
        "-y"
        "chrome-devtools-mcp@latest"
      ];
    };
  };

  # Ported from the claude-code module's `permissions.allow`. Pi core has no
  # permission gating; @gotgenes/pi-permission-system restores it.
  #
  # ORDERING LANDMINE: rules are last-match-wins, and the JSON generator sorts
  # keys alphabetically. That happens to be correct here only because `*` (0x2a)
  # sorts before alphanumerics, so catch-alls land before their overrides. Any
  # new rule that must beat a broader one has to also sort after it — check the
  # emitted file rather than assuming.
  bashRules = {
    "*" = "ask";
  }
  // listToAttrs (map (c: nameValuePair "${c} *" "allow") cfg.bashAllow)
  // {
    "rm -rf *" = "deny";
    "sudo *" = "ask";
  };

  permissionConfig = recursiveUpdate {
    permission = {
      "*" = "allow";
      bash = bashRules;
      # Cross-cutting: applies to pi tools, bash, and MCP calls alike, so a
      # per-tool allow cannot re-expose these.
      path = {
        "*" = "allow";
        "*.env" = "deny";
        "*.env.*" = "deny";
        "*.env.example" = "allow";
        "${config.home.homeDirectory}/.ssh/*" = "deny";
        "${config.home.homeDirectory}/.aws/credentials" = "deny";
      };
      # The analogue of claude-code's `permissions.additionalDirectories`:
      # these are the repos worked in from outside their own cwd.
      external_directory = {
        "*" = "ask";
      }
      // listToAttrs (map (d: nameValuePair "${d}/*" "allow") cfg.projectDirectories);
      # Reads outside the working tree are safe by default; cross-cutting path
      # denies above still protect secrets, and external writes remain gated.
      external_directory_read = "allow";
    };
  } cfg.permissions;

  permissionFile = jsonFormat.generate "pi-permission-config.json" permissionConfig;

  webSearchFile = jsonFormat.generate "pi-web-search.json" cfg.webSearch;

  mcpFile = jsonFormat.generate "mcp.json" {
    # MCP commands and connection state remain available; only the persistent
    # footer status is disabled.
    settings.mcpFooterStatus = "off";
    # recursiveUpdate, not `//`: an override like `{ disabled = true; }` must
    # merge into the built-in server rather than replace it and drop its url.
    mcpServers = recursiveUpdate (remoteMcpServers // slackMcpServer // localMcpServers) cfg.mcpServers;
  };

  # Pi owns ~/.pi/agent/settings.json at runtime: `/settings` and the theme
  # picker both write it back. A home.file symlink would point at a read-only
  # store path and break those, so merge instead — declared keys win, any key
  # Pi added on its own survives.
  mergeSettings = pkgs.writeShellScript "pi-merge-settings" ''
    set -euo pipefail
    target="$HOME/.pi/agent/settings.json"
    mkdir -p "$(dirname "$target")"
    if [ -f "$target" ]; then
      tmp="$(mktemp)"
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$target" ${settingsFile} > "$tmp"
      mv "$tmp" "$target"
    else
      install -m 0644 ${settingsFile} "$target"
    fi
  '';
in
{
  options.modules.pi = {
    enable = mkEnableOption "pi";

    package = mkOption {
      type = types.package;
      default = pkgs.unstable.pi-coding-agent;
      defaultText = "pkgs.unstable.pi-coding-agent";
      description = ''
        Pi derivation to wrap. Defaults to unstable — stable 25.11 lags
        several minor versions behind and pi ships breaking TUI changes
        often enough that tracking stable is not worth it.
      '';
    };

    provider = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "cursor-agent";
      description = ''
        Pi `defaultProvider`, or null to leave it unmanaged.

        Unmanaged by default on purpose: Pi persists the `/model` choice into
        this key, and the activation merge re-asserts Nix values on every
        rebuild — so pinning it would silently revert your picker choice each
        `make r2-d2`. Set it only to force a provider, and note it must have
        credentials in ~/.pi/agent/auth.json or Pi falls back to whatever else
        is ready (the GOOGLE_* vars from work-laptop.nix make google-vertex
        ready without any explicit login).
      '';
    };

    model = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "claude-opus-4-8-thinking-high";
      description = "Pi `defaultModel`, or null to leave it unmanaged. See `provider`.";
    };

    providers = mkOption {
      type = types.attrsOf jsonFormat.type;
      default = { };
      example = {
        my-proxy = {
          name = "My Proxy";
          baseUrl = "http://127.0.0.1:8080/v1";
          api = "openai-completions";
          apiKey = "!op read 'op://Private/my-proxy/credential'";
          models = [ { id = "some-model"; } ];
        };
      };
      description = ''
        Custom providers written to ~/.pi/agent/models.json. `apiKey` accepts
        `!shell command`, `$ENV_VAR`, or a literal — prefer `!op read ...` so
        no secret lands in the world-readable Nix store.
      '';
    };

    packages = mkOption {
      type = types.listOf types.str;
      default = [
        # Adds MCP, which pi core deliberately omits.
        "npm:pi-mcp-adapter"
        # Registers the `cursor-agent` provider and reuses an existing Cursor
        # subscription via browser OAuth, rather than metered API-key billing.
        "npm:pi-cursor-agent"
        # web_search / fetch_content. Falls back to keyless DuckDuckGo, so it
        # works unconfigured; see `webSearch` to add a provider key.
        "npm:pi-web-access"
        "npm:pi-subagents"
        "npm:@juicesharp/rpiv-ask-user-question"
        "npm:pi-background-tasks"
        "npm:@juicesharp/rpiv-todo"
        "npm:pi-lens"
        # Compact tool calls and hide read/search/MCP result bodies.
        "npm:pi-tool-display"
        "npm:@narumitw/pi-goal"
        # Reads Pi theme colour names (accent/success/muted), so it picks up
        # the stylix theme with no override file.
        "npm:pi-powerline-footer"
        # Restores allow/ask/deny gating, which pi core also omits.
        "npm:@gotgenes/pi-permission-system"
      ];
      description = ''
        Pi packages listed in settings.json. Pi installs missing ones on
        startup into ~/.pi/agent/npm, so this is impure by nature — pin with
        `npm:name@version` if you want reproducibility over freshness.
      '';
    };

    bashAllow = mkOption {
      type = types.listOf types.str;
      default = [
        "gh"
        "git"
        "go"
        "ginkgo"
        "yarn"
        "npm"
        "bun"
        "make"
        "rg"
        "nix"
        "nixfmt"
        "tree"
        "jq"
        "find"
        "say"
        "ls"
        "cat"
        "less"
        "head"
        "tail"
        "grep"
        "pwd"
        "wc"
        "diff"
        "bq"
      ];
      description = ''
        Bash commands allowed without a prompt, ported from claude-code's
        `permissions.allow`. Each becomes a `"<cmd> *"` rule, which also
        matches the bare command. Everything else defaults to `ask`.
      '';
    };

    projectDirectories = mkOption {
      type = types.listOf types.str;
      default = map (d: "${config.home.homeDirectory}/Projects/${d}") [
        "core"
        "infrastructure"
        "manifests"
        "mobile-app"
      ];
      description = ''
        Directories reachable outside the current working tree without a
        prompt — the analogue of claude-code's `permissions.additionalDirectories`.
      '';
    };

    permissions = mkOption {
      type = types.attrsOf jsonFormat.type;
      default = { };
      description = ''
        Extra keys recursively merged over the generated
        pi-permission-system config, overriding the defaults built from
        `bashAllow` and `projectDirectories`.
      '';
    };

    webSearch = mkOption {
      type = types.attrsOf jsonFormat.type;
      default = { };
      example = {
        provider = "brave";
        braveApiKey = "$BRAVE_API_KEY";
      };
      description = ''
        pi-web-access config, written to ~/.pi/web-search.json only when
        non-empty. Left empty the extension still works, falling back to its
        keyless DuckDuckGo provider. Key fields accept `$ENV_VAR`, so no
        secret needs to enter the Nix store.
      '';
    };

    mcpServers = mkOption {
      type = types.attrsOf jsonFormat.type;
      default = { };
      example = {
        grafana.url = "https://mcp.grafana.com/mcp";
      };
      description = ''
        Extra MCP servers, recursively merged over the built-in set (linear,
        notion, incident-io, chrome-devtools, and slack when configured).
        Reuse a built-in name to merge keys into it — `{ disabled = true; }`
        turns one off while keeping its url.
      '';
    };

    slack = {
      clientId = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Client ID of a Slack app you have created at
          https://api.slack.com/apps. Required because mcp.slack.com does not
          support Dynamic Client Registration. The Slack MCP server is omitted
          entirely while this is null.
        '';
      };

      clientSecretCommand = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "op read 'op://Private/slack-mcp/credential'";
        description = "Command printing the Slack app client secret, run at auth time.";
      };

      redirectUri = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "http://localhost:3118/callback";
        description = "Must exactly match a redirect URL registered on the Slack app.";
      };

      scope = mkOption {
        type = types.str;
        default = "channels:history channels:read groups:history groups:read im:history im:read mpim:history mpim:read chat:write search:read.public search:read.private users:read";
        description = "Space-delimited Slack user scopes to request.";
      };
    };

    settings = mkOption {
      type = types.attrsOf jsonFormat.type;
      default = { };
      description = "Extra keys merged into ~/.pi/agent/settings.json, overriding the defaults set here.";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [ cfg.package ];

      file = {
        # User memory. Pi loads AGENTS.md from ~/.pi/agent, then every parent
        # directory, then the cwd — so this is the analogue of ~/.claude/CLAUDE.md.
        ".pi/agent/AGENTS.md".text = ''
          # Working relationship
          - No sycophancy.
          - Be direct, matter-of-fact, and concise.
          - Be critical; challenge my reasoning.
          - Don't include timeline estimates in plans.

          # Tooling

          ## General
          - Prefer Makefile targets (`make help`) over direct tool invocation.
          - Use Mermaid diagrams for complex systems.

          ## Git
          - When creating git commit messages ALWAYS use [conventional commit style](https://www.conventionalcommits.org/en/v1.0.0/#specification).
          - When creating pull requests in Github ALWAYS mark them in draft status.
          - When interacting with Github (pull request actions, comments etc.) ALWAYS prefer using the `gh` CLI.
        '';

        ".pi/agent/themes/stylix.json".source = themeFile;

        # Read by @gotgenes/pi-permission-system. Session approvals ("approve
        # for this session") are held in memory, so nothing writes back here.
        ".pi/agent/extensions/pi-permission-system/config.json".source = permissionFile;

        # Keep pi-lens diagnostics active while hiding its persistent footer.
        # It can still be shown for the current session with /lens-widget-toggle.
        ".pi-lens/config.json".text = builtins.toJSON {
          widget.visible = false;
        };

        # Pi has no native setting to hide tool-call rows completely. Start
        # from the opencode preset's concrete values, then minimise every
        # configurable preview and disable its native user-message box.
        ".pi/agent/extensions/pi-tool-display/config.json" = {
          # The extension creates this file before Home Manager first manages
          # it. Force ownership so a stale .hm-backup cannot block activation.
          force = true;
          text = builtins.toJSON {
            enabled = true;
            registerToolOverrides = {
              read = true;
              grep = true;
              find = true;
              ls = true;
              bash = true;
              edit = true;
              write = true;
            };
            customToolOverrides = { };
            enableNativeUserMessageBox = false;
            readOutputMode = "hidden";
            searchOutputMode = "hidden";
            mcpOutputMode = "hidden";
            previewLines = 1;
            expandedPreviewMaxLines = 0;
            bashOutputMode = "opencode";
            bashCollapsedLines = 0;
            diffViewMode = "auto";
            diffIndicatorMode = "bars";
            diffSplitMinWidth = 120;
            diffCollapsedLines = 4;
            diffWordWrap = true;
            showTruncationHints = false;
            showRtkCompactionHints = false;
          };
        };
      }
      // optionalAttrs (cfg.providers != { }) {
        ".pi/agent/models.json".source = modelsFile;
      }
      // optionalAttrs (cfg.webSearch != { }) {
        ".pi/web-search.json".source = webSearchFile;
      };

      activation.piSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${mergeSettings}
      '';
    };

    # Lowest-precedence layer in the adapter's config stack, and the only one
    # it never writes to — `/mcp disable` and `directTools` persist to the
    # Pi-owned ~/.pi/agent/mcp.json and .pi/mcp.json above it. That keeps this
    # read-only store symlink safe while leaving those layers writable.
    xdg.configFile."mcp/mcp.json".source = mcpFile;
  };
}
