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
  # Rex defaults this on; `rex skill setup` turns it off.
  sessionNaming = "--feature-session-naming=false";

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

    # Claude Code integration: what `rex skill setup` would install, which
    # can't write to the nix-managed ~/.claude/settings.json itself.
    (mkIf config.programs.claude-code.enable {
      programs.claude-code = {
        mcpServers.superlogical = {
          type = "http";
          url = "https://www.superlogical.com/rex/community-mcp";
        };

        settings = {
          # HM serves mcpServers from a generated plugin, hence the prefix.
          permissions.allow = [ "mcp__plugin_claude-code-home-manager_superlogical" ];
          # Tells each session which Rex session and terminal it runs in.
          hooks.SessionStart = [
            {
              hooks = [
                {
                  type = "command";
                  command = "${rex} __internal session-start --agent claude ${sessionNaming} 2>/dev/null || true";
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
          ---
          Run `rex __internal skill ${sessionNaming}` and follow the guide it prints.
        '';
      };
    })
  ]);
}
