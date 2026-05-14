_: {
  # Shared homebrew config for every Mac. Casks/brews specific to one
  # role (e.g. work) live in the role's profile (darwin/work.nix) and
  # merge with these via the module system's list-concatenation.

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
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
