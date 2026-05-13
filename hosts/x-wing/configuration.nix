{ ... }:
{
  imports = [ ../../profiles/darwin/desktop.nix ];

  networking = {
    hostName = "x-wing";
    computerName = "x-wing";
    localHostName = "x-wing";
  };
}
