_: {
  # Single M.2 2280 NVMe, GPT + UEFI. The NUC10FNH also has a 2.5" SATA
  # bay — add a `disk.bulk` entry here if/when it gets populated.
  #
  # WARNING: disko ZAPS whatever device is named here. Confirm the path on
  # the installer with `lsblk` before running nixos-anywhere.
  #
  # ext4, not btrfs, on purpose: Docker on btrfs uses the btrfs storage
  # driver rather than overlay2, and overlay2 is the far better-trodden
  # path for a container host. No swap partition — zramSwap covers it
  # (profiles/nixos/server.nix).
  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
