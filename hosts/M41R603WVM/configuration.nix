{ pkgs, lib, inputs, ... }:
{

  # Even though we manage the ZSH config via home-manager, this is still required
  # at a system level, otherwise nix-darwin binaries won't get properly linked.
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

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
  };
}
