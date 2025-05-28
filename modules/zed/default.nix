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
        minimap = { show = "auto"; };
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
            low_speed_timeout_in_seconds = 1000;
            available_models = [
              {
                provider = "ollama";
                name = "devstral:24b";
                display_name = "devstral:24b";
                keep_alive = "10m";
                max_tokens = 32768;
                supports_tools = true;
              }
              {
                provider = "ollama";
                name = "qwen2.5-coder:14b";
                display_name = "qwen2.5-coder:14b";
                keep_alive = "10m";
                max_tokens = 32768;
                supports_tools = true;
              }
              {
                provider = "ollama";
                name = "deepseek-r1:14b";
                display_name = "deepseek-r1:14b";
                keep_alive = "10m";
                max_tokens = 32768;
                supports_tools = true;
              }
            ];
          };
        };
        model_parameters = [
          {
            provider = "ollama";
            model = "devstral:24b";
            temperature = 0.15;
          }
        ];
        agent = {
          enabled = true;
          version = "2";
          default_model = {
            provider = "ollama";
            model = "devstral:24b";
            display_name = "devstral:24b";
            keep_alive = "10m";
            max_tokens = 32768;
            supports_tools = true;
          };
        };
        editor_model = {
          provider = "ollama";
          model = "devstral:24b";
          display_name = "devstral:24b";
          keep_alive = "10m";
          max_tokens = 32768;
          supports_tools = true;
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
