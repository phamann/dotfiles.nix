{ pkgs, ... }:
{
  # macOS system defaults shared across every Mac. Homebrew config is in
  # the sibling homebrew.nix; desktop.nix is the aggregator that pulls
  # both together.

  nix.enable = false;
  nixpkgs.config.allowUnfree = true;

  # Even though zsh is managed via home-manager, the system-level flag
  # is still required for nix-darwin to link binaries into the user's PATH.
  programs.zsh.enable = true;

  # sudo via Touch ID.
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = "phamann";
    stateVersion = 5;
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllFiles = true;
        AppleShowScrollBars = "Always";
        # Don't auto-save documents to iCloud.
        NSDocumentSaveNewDocumentsToCloud = false;
      };

      WindowManager.EnableTiledWindowMargins = false;

      dock = {
        autohide = false;
        showhidden = true;
        tilesize = 50;
        # Don't auto-rearrange Spaces by recent use.
        mru-spaces = false;
      };

      finder = {
        AppleShowAllFiles = true;
        # No icons on the desktop.
        CreateDesktop = false;
        FXEnableExtensionChangeWarning = false;
        # Column view as the default Finder layout.
        FXPreferredViewStyle = "clmv";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      spaces.spans-displays = false;

      CustomSystemPreferences = { };
    };
  };

  environment.systemPackages = with pkgs; [ unstable.tailscale ];

  environment.systemPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];
}
