{ pkgs, lib, config, ... }:
with lib; let
  cfg = config.modules.starship;
in
{
  options.modules.starship = { enable = mkEnableOption "starship"; };
  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
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
        hostname = {
          ssh_symbol = "";
          format = "on [$hostname]($style) ";
        };
        username = {
          show_always = true;
          style_user = "bold purple";
          format = "[$user]($style) ";
        };
        directory = {
          format = "in [$path]($style)[$read_only]($read_only_style) ";
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
        palette = "catppuccin_frappe";
        palettes = {
          catppuccin_frappe = {
                rosewater = "#f2d5cf";
                flamingo = "#eebebe";
                pink = "#f4b8e4";
                mauve = "#ca9ee6";
                red = "#e78284";
                maroon = "#ea999c";
                peach = "#ef9f76";
                yellow = "#e5c890";
                green = "#a6d189";
                teal = "#81c8be";
                sky = "#99d1db";
                sapphire = "#85c1dc";
                blue = "#8caaee";
                lavender = "#babbf1";
                text = "#c6d0f5";
                subtext1 = "#b5bfe2";
                subtext0 = "#a5adce";
                overlay2 = "#949cbb";
                overlay1 = "#838ba7";
                overlay0 = "#737994";
                surface2 = "#626880";
                surface1 = "#51576d";
                surface0 = "#414559";
                base = "#303446";
                mantle = "#292c3c";
                crust = "#232634";
          };
          catppuccin_macchiato = {
            rosewater = "#f4dbd6";
            flamingo = "#f0c6c6";
            pink = "#f5bde6";
            mauve = "#c6a0f6";
            red = "#ed8796";
            maroon = "#ee99a0";
            peach = "#f5a97f";
            yellow = "#eed49f";
            green = "#a6da95";
            teal = "#8bd5ca";
            sky = "#91d7e3";
            sapphire = "#7dc4e4";
            blue = "#8aadf4";
            lavender = "#b7bdf8";
            text = "#cad3f5";
            subtext1 = "#b8c0e0";
            subtext0 = "#a5adcb";
            overlay2 = "#939ab7";
            overlay1 = "#8087a2";
            overlay0 = "#6e738d";
            surface2 = "#5b6078";
            surface1 = "#494d64";
            surface0 = "#363a4f";
            base = "#24273a";
            mantle = "#1e2030";
            crust = "#181926";
          };
        };
      };
    };
  };
}
