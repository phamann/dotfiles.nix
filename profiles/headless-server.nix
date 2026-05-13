{ ... }:
{
  # Headless / SSH-only role: base shell tooling, nothing GUI, no laptop
  # conveniences. yoda is the only host using this today.
  imports = [ ./base.nix ];
}
