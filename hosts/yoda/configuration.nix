{ inputs, ... }:
{
  imports = [
    ../../profiles/nixos/server.nix
    ./disk-config.nix
    ./hardware-configuration.nix

    # No NUC10 module exists upstream (only 5i5ryb, 7i3bnb, 8i7beh,
    # 12wshi7). `common-cpu-intel-cpu-only` is just the microcode default;
    # plain `common-cpu-intel` additionally pulls the whole Intel GPU stack
    # (VAAPI, compute runtime, media runtime), which is dead weight on a
    # headless box.
    #
    # Switch to `common-cpu-intel` if you ever want QuickSync hardware
    # transcoding in a container (Frigate, Plex, Jellyfin) — the UHD
    # graphics in the 10710U supports it. Do NOT reach for
    # `common-gpu-intel-comet-lake`: deprecated upstream despite the CPU
    # being Comet Lake.
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  networking.hostName = "yoda";

  # Fresh install — matches the release it was installed from. Do not bump
  # this on upgrade.
  system.stateVersion = "26.05";
}
