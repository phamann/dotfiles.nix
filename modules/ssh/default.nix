{ lib, config, ... }:
with lib;
let cfg = config.modules.ssh;
in {
  options.modules.ssh = { enable = mkEnableOption "ssh"; };
  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;

      includes = [ "jetpac.conf" ];

      enableDefaultConfig = false;

      matchBlocks = {
        "*" = {
          setEnv = { TERM = "xterm-256color"; };
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "30m";
          forwardAgent = true;
          addKeysToAgent = "yes";
          identityFile = "~/.ssh/id_ed25519";
        };

        "github.com" = {
          hostname = "ssh.github.com";
          user = "git";
          port = 443;
          forwardAgent = true;
        };
      };
    };
  };
}
