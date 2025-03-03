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
        buffer_font_features = { calt = false; };
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
        language_models = {
          ollama = {
            api_url = "http://localhost:11434";
            available_models = [
              {
                name = "llama3.2";
                display_name = "llama3.2";
                max_tokens = 16384;
              }
              {
                name = "qwen2.5-coder:7b";
                display_name = "qwen2.5-coder:7b";
                max_tokens = 128000;
              }
              {
                name = "qwen2.5-coder:1.5b-instruct";
                display_name = "qwen2.5-coder:1.5b-instruct";
                max_tokens = 32000;
              }
            ];
          };
        };
        assistant = {
          enabled = true;
          version = "2";
          default_model = {
            provider = "ollama";
            model = "llama3.2";
          };
        };
      };
      extensions = [
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
        "perl"
        "rego"
        "ruby"
        "sql"
        "xml"
      ];
    };
  };
}
