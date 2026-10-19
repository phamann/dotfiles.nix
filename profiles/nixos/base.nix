{ pkgs, ... }:
{
  # Baseline every NixOS host gets. Hardware, disks and hostname live in
  # hosts/<name>/; role packages live in the sibling role profiles.
  #
  # The NixOS analogue of profiles/darwin/system.nix. Note there is no
  # `nix.enable = false` here: that option is nix-darwin/home-manager only.
  # On NixOS, inputs.determinate.nixosModules.default (wired in
  # flake/hosts.nix) IS the Determinate install, and it needs the stock nix
  # module active to generate the config it redirects into nix.custom.conf.

  nix = {
    settings = {
      # Redundant under Determinate Nix, which enables both by default, but
      # kept so the config still does the right thing without it.
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "phamann"
      ];
      auto-optimise-store = true;
      # i7-10710U is 6C/12T. Cap parallel derivations at the physical core
      # count so a rebuild doesn't starve the containers.
      max-jobs = 6;
    };

    # Untouched by the Determinate module, so the stock GC timer applies.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot.loader = {
    systemd-boot = {
      enable = true;
      # Bound the ESP — 1G of /boot fills fast with unbounded generations.
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Required even though the zsh config itself comes from home-manager:
  # NixOS needs the shell registered in /etc/shells before it is valid as a
  # login shell. Same reason profiles/darwin/system.nix sets it.
  programs.zsh.enable = true;

  users.users.phamann = {
    isNormalUser = true;
    description = "Patrick Hamann";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgyawe37BcgC+brREsJi5cEyQuR8PXUKrDEotc8MD9h patrick.hamann@incident.io"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.enable = true;

  # Bootstrap only — the rest of the user environment comes from
  # home-manager via profiles/headless-server.nix.
  environment.systemPackages = [ pkgs.git ];
}
