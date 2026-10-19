{ config, lib, ... }:
{
  # PLACEHOLDER — not yet generated from the real machine.
  #
  # The flake has to evaluate before nixos-anywhere can build the disko
  # script, and it can't evaluate with a missing import, so this file has to
  # exist up front. During the install,
  #
  #   --generate-hardware-config nixos-generate-config ./hosts/yoda/hardware-configuration.nix
  #
  # overwrites it with the real thing. Commit that result and delete this
  # comment.
  #
  # Values below are the expected shape for a NUC10FNH (Comet Lake-U, NVMe
  # boot, Thunderbolt 3). `not-detected.nix` is deliberately NOT imported
  # here — nixos-generate-config will add it.
  #
  # NOTE: no `fileSystems` / `swapDevices`. Those come from disko
  # (./disk-config.nix). If the generated file brings its own, delete them
  # or you get conflicting definitions for the same mountpoint.

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  networking.useDHCP = lib.mkDefault true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
