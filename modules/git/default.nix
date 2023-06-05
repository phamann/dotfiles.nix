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
        userEmail = "patrick@fastly.com";
        signing = {
            key = "CD2E6283475DC528";
            signByDefault = true;
        };
        extraConfig = {
            init = { defaultBranch = "main"; };
            url = {
              "git@github.com:" = {
                insteadOf = "https://github.com/";
              };
            };
            mergetool = {
              prompt = false;
              keepBackup = false;
            };
        };
        aliases = {
          st = "status";
          co = "checkout";
          ci = "commit";
          br = "branch";
          hist = ''log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short'';
        };
        ignores = [
          ".devenv"
          ".direnv"
          ".envrc"
          "flake.lock"
          "flake.nix"
        ];
      };
    };
}
