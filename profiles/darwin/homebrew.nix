_: {
  # Shared homebrew config for every Mac. Casks/brews specific to one
  # role (e.g. work) live in the role's profile (darwin/work.nix) and
  # merge with these via the module system's list-concatenation.

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      # Uninstall (with `--zap`) anything not declared here. nix-darwin emits
      # `--zap --force-cleanup`, the current Homebrew flags that actually
      # perform the cleanup (a bare `--cleanup` is a deprecated no-op that only
      # dry-runs and exits non-zero, failing activation).
      cleanup = "zap";
      upgrade = false;
    };

    # `trusted` defaults to false for taps (Homebrew 6.0.0 turned on
    # HOMEBREW_REQUIRE_TAP_TRUST). Fully-qualified brews below carry their
    # own trust, but a bare-named brew from these taps would abort
    # activation and a cask would be skipped silently — so trust the taps.
    taps = [
      {
        name = "felipeelias/tap";
        trusted = true;
      }
    ];

    brews = [
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
      "obsidian"
      "raycast"
      "signal"
      "sonos"
      "spotify"
      "superwhisper"
      "tailscale-app"
      "tldraw"
      "vlc"
      "zed"
      "zen"
    ];
  };
}
