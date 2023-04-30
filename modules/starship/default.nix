{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.starship;
in
{
  options.modules.starship = { enable = mkEnableOption "starship"; };
  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$nix_shell"
          "$localip"
          "$shlvl"
          "$directory"
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_metrics"
          "$git_status"
          "$hg_branch"
          "$docker_context"
          "$container"
          "$terraform"
          "$env_var"
          "$sudo"
          "$cmd_duration"
          "$line_break"
          "$status"
          "$shell"
          "$character"
        ];
        username = {
          show_always = true;
          style_user = "bold_purple";
        };
        character = {
          success_symbol = "[±](bold green)";
          error_symbol = "[±](bold red)";
          vicmd_symbol = "[±](bold green)";
        };
        git_commit = {
          tag_symbol = " tag ";
        };
        git_status = {
          format = ''([\[](bold green)[$conflicted$renamed]($style)$modified$untracked$staged$deleted$ahead_behind[\]](bold green)) '';
          ahead = "[>$count](bold red)";
          behind = "[<$count](bold cyan)";
          diverged = "<>";
          renamed = "r";
          deleted = "[-](bold red)";
          stashed = "s";
          staged = "[+](bold green)";
          modified = "[m](bold yellow)";
          untracked = "[u](bold red)";
        };
        directory = {
          read_only = " ro";
          truncation_length = 8;
          truncation_symbol = "…/";
          truncate_to_repo = false;
          style = "bold yellow";
        };
        docker_context = {
          symbol = "docker ";
        };
        git_branch = {
          style = "bold cyan";
          symbol = " ";
        };
        nix_shell = {
          symbol = "nix ";
        };
      };
    };
  };
};
