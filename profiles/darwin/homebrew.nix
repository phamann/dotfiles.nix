_: {
  # Shared homebrew config for every Mac. Casks/brews specific to one
  # role (e.g. work) live in the role's profile (darwin/work.nix) and
  # merge with these via the module system's list-concatenation.

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      # nix-darwin 26.05 still emits the legacy `--force-cleanup` flag, which
      # Homebrew (>= ~5.x) renamed to `--cleanup`, breaking `brew bundle`
      # during activation. Keep cleanup = "none" so nix-darwin adds no cleanup
      # flag, and supply the modern equivalent of "zap" via extraFlags. Revert
      # to cleanup = "zap" once nix-darwin's 26.05 branch is fixed.
      cleanup = "none";
      extraFlags = [
        "--cleanup"
        "--zap"
      ];
      upgrade = false;
    };

    taps = [
      { name = "terrastruct/tap"; }
      { name = "felipeelias/tap"; }
    ];

    brews = [
      { name = "terrastruct/tap/tala"; }
      { name = "felipeelias/tap/claude-statusline"; }
    ];

    casks = [
      "1password"
      "bartender"
      "claude"
      "daisydisk"
      "dropbox"
      "firefox"
      "ghostty"
      "lm-studio"
      "nordvpn"
      "notion"
      "notion-calendar"
      "macdown"
      "obsidian"
      "raycast"
      "signal"
      "sonos"
      "spotify"
      "superwhisper"
      "tailscale-app"
      "vlc"
      "zed"
      "zen"
    ];
  };
}
