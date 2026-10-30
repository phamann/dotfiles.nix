{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (lib) concatStringsSep mkEnableOption mkIf;
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

  config = mkIf cfg.enable {
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
  };
}
