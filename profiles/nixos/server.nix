_: {
  # Headless always-on box: containers, no desktop, never sleeps.
  imports = [ ./base.nix ];

  virtualisation.docker = {
    enable = true;
    # Containers survive a daemon restart — including the one a
    # nixos-rebuild triggers when it bumps the docker package — instead of
    # all going down at once.
    daemon.settings.live-restore = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
  users.users.phamann.extraGroups = [ "docker" ];

  # The NUC chassis is small and the 10710U throttles hard without active
  # thermal management.
  services.thermald.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  # Firmware/BIOS updates without booting anything else.
  services.fwupd.enable = true;

  # Compressed RAM swap instead of a swap partition: better for the SSD, and
  # removes a partition disk-config.nix would otherwise have to size.
  zramSwap.enable = true;

  # Nothing is ever on the console, so never suspend. Note this is
  # `settings.Sleep`, not the `extraConfig` string that 26.05 removed.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
  };
}
