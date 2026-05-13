{ ... }:
{
  # Headless / SSH-only role for a dev box: base shell tooling plus
  # language toolchains and k8s tooling — nothing GUI, no laptop
  # conveniences. yoda is the only host using this today.
  imports = [ ./base.nix ];

  modules.packages = {
    dev.enable = true;
    k8s.enable = true;
  };
}
