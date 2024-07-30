{ pkgs, lib, inputs, ... }:
{

  networking.hostName = "x-wing";

  # Even though we manage the ZSH config via home-manager, this is still required
  # at a system level, otherwise nix-darwin binaries won't get properly linked.
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable sudo authentication with Touch ID.
  security.pam.enableSudoTouchIdAuth = true;

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllFiles = true;
      AppleShowScrollBars = "Always";
      # Disable saving documents to iCloud by default.
      NSDocumentSaveNewDocumentsToCloud = false;
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

    CustomSystemPreferences = { };
  };

  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = false;
  homebrew.onActivation.cleanup = "zap";
  homebrew.onActivation.upgrade = true;
  homebrew.taps = [
    "homebrew/cask"
    "homebrew/cask-versions"
    "homebrew/cask-fonts"
  ];
  homebrew.casks = [
    "1password"
    "alfred"
    "bartender"
    "cron"
    "divvy"
    "dropbox"
    "firefox"
    "firefox-developer-edition"
    "obsidian"
    "signal"
    "slack"
    "sonos"
    "spotify"
    "zoom"
  ];

  # Avoid having to restart the for certain settings to apply post nix activation.
  system.activationScripts.postUserActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  # Tailscale
  # ervices.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    unstable.tailscale
  ];
}
