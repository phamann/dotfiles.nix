{ lib, config, ... }:
with lib;
let cfg = config.modules.zed;
in {
  options.modules.zed = { enable = mkEnableOption "zed"; };
  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      userSettings = {
        theme = "Catppuccin Frappé";
        vim_mode = true;
        ui_font_size = 16;
        buffer_font_size = 16;
        restore_on_startup = "last_workspace";
        buffer_font_family = "JetBrainsMono Nerd Font Mono";
        autosave = "on_window_change";
        load_direnv = "shell_hook";
        show_wrap_guides = true;
        wrap_guides = [ 80 ];
        inlay_hints = { enabled = true; };
        preview_tabs = {
          enabled = true;
          enable_preview_from_file_finder = true;
          enable_preview_from_code_navigation = true;
        };
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        lsp = {
          nil = {
            initialization_options = {
              formatting = { command = [ "nixfmt" ]; };
            };
          };
        };
        git = {
          inline_blame = {
            enabled = true;
            delay_ms = 500;
          };
        };
        terminal = { line_height = "standard"; };
      };
      extensions = [
        "atomize"
        "catppuccin"
        "cue"
        "docker-compose"
        "dockerfile"
        "env"
        "helm"
        "http"
        "ini"
        "kdl"
        "nginx"
        "nix"
        "one-dark-flat"
        "one-dark-pro"
        "perl"
        "rego"
        "ruby"
        "siri"
        "sql"
        "xml"
      ];
    };
  };
}
