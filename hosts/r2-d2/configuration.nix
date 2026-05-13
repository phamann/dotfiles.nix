{ pkgs, ... }: {

  nix.enable = false;

  networking = {
    hostName = "r2-d2";
    computerName = "r2-d2";
    localHostName = "r2-d2";
  };

  # Even though we manage the ZSH config via home-manager, this is still required
  # at a system level, otherwise nix-darwin binaries won't get properly linked.
  programs.zsh.enable = true;

  # Enable sudo authentication with Touch ID.
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = "phamann";
    stateVersion = 5;
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllFiles = true;
        AppleShowScrollBars = "Always";
        # Disable saving documents to iCloud by default.
        NSDocumentSaveNewDocumentsToCloud = false;
      };

      WindowManager = { EnableTiledWindowMargins = false; };

      # Dock settings
      dock = {
        autohide = false;
        showhidden = true;
        tilesize = 50;

        # Don't rearrange spaces based on their recent use.
        mru-spaces = false;
      };

      # Finder settings
      finder = {
        # Show hidden files
        AppleShowAllFiles = true;

        # Don't display files/icons on desktop.
        CreateDesktop = false;

        FXEnableExtensionChangeWarning = false;
        # Change the default finder view to column view.
        FXPreferredViewStyle = "clmv";

        QuitMenuItem = true;
        # Show path breadcrumbs in finder windows
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      # Spaces
      spaces.spans-displays = false;

      CustomSystemPreferences = { };
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
      upgrade = false;
    };
    casks = [
      "1password"
      "bartender"
      "claude"
      "cursor"
      "daisydisk"
      "dropbox"
      "expo-orbit"
      "firefox"
      "ghostty"
      "gram"
      "granola"
      "linear"
      "lm-studio"
      "loom"
      "nordvpn"
      "notion-calendar"
      "macdown"
      "obsidian"
      "raycast"
      "signal"
      "slack"
      "sonos"
      "spotify"
      "superwhisper"
      "postico"
      "tailscale-app"
      "vlc"
      "zed"
      "zen"
      "zoom"
    ];
    taps = [
      { name = "terrastruct/tap"; }
      { name = "felipeelias/tap"; }
    ];
    brews = [
      { name = "terrastruct/tap/tala"; }
      { name = "felipeelias/tap/claude-statusline"; }
      "postgresql@17"
      "redis"
      "memcached"
    ];
  };

  # Tailscale
  # ervices.tailscale.enable = true;
  environment.systemPackages = with pkgs; [ unstable.tailscale ];

  environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" "/opt/homebrew/opt/postgresql@17/bin" ];

}
