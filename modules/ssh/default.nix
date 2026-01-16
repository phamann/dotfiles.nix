{ lib, config, ... }:
with lib;
let cfg = config.modules.ssh;
in {
  options.modules.ssh = { enable = mkEnableOption "ssh"; };
  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;

      includes = [ "jetpac.conf" "fastly_config" ];

      enableDefaultConfig = false;

      matchBlocks = {
        "*" = {
          setEnv = { TERM = "xterm-256color"; };
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "30m";
          forwardAgent = true;
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
