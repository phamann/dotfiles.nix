{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.git;
in
{
  options.modules.git = { enable = mkEnableOption "git"; };
  config =
    mkIf cfg.enable {
      programs.git = {
        enable = true;
        userName = "Patrick Hamann";
        userEmail = "patrickhamann@gmail.com";
        signing = {
            signingkey = "CD2E6283475DC528";
            signByDefault = true;
        };
        url = {
          "git@github.com:" = {
            insteadOf = "https://github.com/";
          };
        };
        aliases = {
          st = "status";
          co = "checkout";
          ci = "commit";
          br = "branch";
          hist = ''log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short'';
        };
      };
    };
}
