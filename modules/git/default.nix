{ pkgs, lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.git;
in
{
  options.modules.git = { enable = mkEnableOption "git"; };
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        alias = {
          st = "status";
          co = "checkout";
          ci = "commit";
          br = "branch";
          hist =
            "log --graph --pretty=format:'%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) %C(cyan)<%an>%Creset' --abbrev-commit";
        };
        user = {
          name = "Patrick Hamann";
          email = "patrick.hamann@incident.io";
        };
        core = { hooksPath = "~/.git-hooks"; };
        init = { defaultBranch = "main"; };
        url = { "git@github.com:" = { insteadOf = "https://github.com/"; }; };
        mergetool = {
          prompt = false;
          keepBackup = false;
        };
      };
      signing = {
        key = "51DEA9FE8BB98BD2";
        signByDefault = true;
      };
      ignores =
        [ ".devenv" ".direnv" ".envrc" "flake.lock" "flake.nix" ".aider*" ];
    };
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = false;
        line-numbers = true;
        hunk-header-style = "file line-number syntax";
      };
    };
    catppuccin.delta.enable = true;
  };
}
