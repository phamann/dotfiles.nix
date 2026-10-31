{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    mkEnableOption
    mkIf
    mkMerge
    ;
  cfg = config.modules.rex;
  rex = lib.getExe config.programs.rex.package;
  inherit (config.modules.theme) scheme;

  # Ghostty-format theme generated from the active stylix scheme. Rex has no
  # theme setting in init.lua — the Mac app keeps themes in its own defaults
  # and imports them from Ghostty or iTerm files (Settings > Theme > Import).
  # Slot mapping is copied from stylix's ghostty target so Rex and ghostty
  # render identically: bright 9-14 repeat the normal hues, 15 is base07.
  c = config.lib.stylix.colors;
  palette = with c.withHashtag; [
    base00
    base08
    base0B
    base0A
    base0D
    base0E
    base0C
    base05
    base03
    base08
    base0B
    base0A
    base0D
    base0E
    base0C
    base07
  ];
  ghosttyTheme = concatStringsSep "\n" (
    [
      "background = ${c.base00}"
      "foreground = ${c.base05}"
      "cursor-color = ${c.base05}"
      "selection-background = ${c.base02}"
      "selection-foreground = ${c.base05}"
    ]
    ++ lib.imap0 (i: hex: "palette = ${toString i}=${hex}") palette
  );
in
{
  imports = [ inputs.rex.homeManagerModules.default ];

  options.modules.rex = {
    enable = mkEnableOption "rex";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # The flake's package is the CLI only; the Mac app (installed by hand,
      # it self-updates via Sparkle) runs the server, so services.rex stays
      # off — the upstream module asserts it is Linux-only. Installing the
      # package also gives us the xterm-rex terminfo in ~/.terminfo and the
      # ssh guard in ~/.ssh/config (programs.ssh is on via modules/ssh).
      programs.rex = {
        enable = true;
        config = ./init.lua;
      };

      xdg.configFile."rex/themes/${scheme}".text = ghosttyTheme + "\n";

      # Rex doesn't watch init.lua. Reload the running server so a rebuild
      # takes effect, but don't fail activation when the app isn't running.
      home.activation.rexConfigReload = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        if ${rex} server status >/dev/null 2>&1; then
          run ${rex} config reload || warnEcho "rex config reload failed; run it by hand"
        fi
      '';
    }

    # Claude Code integration. `rex skill setup` can't do this itself: it
    # edits ~/.claude/settings.json in place, which is a read-only nix store
    # symlink here. The hook and skill mirror what `rex skill setup` writes
    # (Rex 2026-10, `--feature-session-naming=false`); re-run
    # `rex skill setup --project --agent claude` in a scratch dir and diff
    # after a Rex upgrade if `rex skill status` reports them as outdated.
    (mkIf config.programs.claude-code.enable {
      programs.claude-code = {
        settings = {
          mcpServers.superlogical = {
            type = "http";
            url = "https://www.superlogical.com/rex/community-mcp";
          };
          permissions.allow = [ "mcp__superlogical" ];
          # Tells each session which Rex session and terminal it runs in.
          hooks.SessionStart = [
            {
              hooks = [
                {
                  type = "command";
                  command = "/bin/sh -c 'rex __internal session-start --agent claude --feature-session-naming=false 2>/dev/null || true'";
                  timeout = 5;
                }
              ];
            }
          ];
        };

        skills.rex = ''
          ---
          name: rex
          description: Use the rex CLI to manage Rex sessions, open tabs, arrange panes, run commands, inspect terminal output, and control connected Rex apps.
          metadata:
            rex-stub: "2"
          ---
          <!-- Installed by "rex skill setup". Remove it with "rex skill remove". -->

          Run `rex __internal skill --feature-session-naming=false` and follow the guide it prints. The guide comes from
          the installed Rex CLI, so it describes the commands available in that version.

          If the command fails, the installed Rex version predates the guide. Start with
          `rex whoami --json`, then use `rex --help` and `rex COMMAND --help`.
        '';
      };

      # `rex skill setup` already wrote a real file here; take it over.
      home.file."${config.programs.claude-code.configDir}/skills/rex/SKILL.md".force = true;
    })
  ]);
}
