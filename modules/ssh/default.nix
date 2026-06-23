{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = {
    enable = mkEnableOption "ssh";
  };
  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;

      includes = [ "jetpac.conf" ];

      enableDefaultConfig = false;

      # HM 26.05 replaced matchBlocks (camelCase) with settings, a freeform
      # attrset keyed by Host pattern using upstream ssh_config(5) directive
      # names. Booleans render as yes/no; SetEnv takes an attrset.
      settings = {
        "*" = {
          SetEnv = {
            TERM = "xterm-256color";
          };
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "30m";
          ForwardAgent = true;
          AddKeysToAgent = "yes";
          IdentityFile = "~/.ssh/id_ed25519";
        };

        "github.com" = {
          HostName = "ssh.github.com";
          User = "git";
          Port = 443;
          ForwardAgent = true;
        };
      };
    };
  };
}
