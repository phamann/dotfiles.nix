{ pkgs, ... }: {

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "r2-d2";
    computerName = "r2-d2";
    localHostName = "r2-d2";
  };

  # Even though we manage the ZSH config via home-manager, this is still required
  # at a system level, otherwise nix-darwin binaries won't get properly linked.
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  # nix.settings.experimental-features = "nix-command flakes";

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
      "chef-workstation"
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
      "slack"
      "sonos"
      "spotify"
      "superwhisper"
      "tailscale"
      "vlc"
      "zed"
      "zen-browser"
    ];
    taps = [
      { name = "terrastruct/tap"; }
      { name = "felipeelias/tap"; }
    ];
    brews = [
      { name = "terrastruct/tap/tala"; }
      { name = "felipeelias/tap/claude-statusline"; }
    ];
  };

  # Tailscale
  # ervices.tailscale.enable = true;
  environment.systemPackages = with pkgs; [ unstable.tailscale ];

  environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

  nix = {
    settings = {
      download-buffer-size = 524288000; # 500 MiB
      keep-derivations = true; # Keep .drv files
      keep-outputs = false; # Save space
      min-free = "${toString (10 * 1024 * 1024 * 1024)}"; # 10GB
    };
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
      options = "--delete-generations +10"; # Keep last 10 generations
    };
    optimise = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 4;
        Minute = 0;
      };
    };
  };
}
