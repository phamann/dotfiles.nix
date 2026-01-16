{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.git;
  catppuccin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "delta";
    rev = "e9e21cffd98787f1b59e6f6e42db599f9b8ab399";
    hash = "sha256-04po0A7bVMsmYdJcKL6oL39RlMLij1lRKvWl5AUXJ7Q=";
  };
in
{
  options.modules.git = { enable = mkEnableOption "git"; };
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      includes = [{ path = "${catppuccin}/catppuccin.gitconfig"; }];
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
          email = "patrick@fastly.com";
        };
        init = { defaultBranch = "main"; };
        url = { "git@github.com:" = { insteadOf = "https://github.com/"; }; };
        mergetool = {
          prompt = false;
          keepBackup = false;
        };
      };
      signing = {
        key = "CD2E6283475DC528";
        signByDefault = true;
      };
      ignores = [ ".devenv" ".direnv" ".envrc" "flake.lock" "flake.nix" ".aider*" ];
    };
    programs.delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = false;
        line-numbers = true;
        hunk-header-style = "file line-number syntax";
        features = "catppuccin-frappe";
      };

    };
  };
}
