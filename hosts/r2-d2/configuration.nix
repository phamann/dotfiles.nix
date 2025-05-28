{ pkgs, ... }: {

  networking.hostName = "r2-d2";
  networking.computerName = "r2-d2";
  networking.localHostName = "r2-d2";

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

  system.primaryUser = "phamann";

  system.stateVersion = 5;

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllFiles = true;
      AppleShowScrollBars = "Always";
      # Disable saving documents to iCloud by default.
      NSDocumentSaveNewDocumentsToCloud = false;
    };

    WindowManager = {
      EnableTiledWindowMargins = false;
    };

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

  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = false;
  homebrew.onActivation.cleanup = "zap";
  homebrew.onActivation.upgrade = false;
  homebrew.casks = [
    "1password"
    "bartender"
    "chef-workstation"
    "dropbox"
    "firefox"
    "ghostty"
    "lm-studio"
    "nordvpn"
    "notion-calendar"
    "obsidian"
    "raycast"
    "signal"
    "slack"
    "sonos"
    "spotify"
    "tailscale"
    "vlc"
    "zed"
    "zen-browser"
  ];

  # Tailscale
  # ervices.tailscale.enable = true;
  environment.systemPackages = with pkgs; [ unstable.tailscale ];
}
