{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.zed;
in
{
  options.modules.zed = {
    enable = mkEnableOption "zed";
  };
  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = null; # Don't install package as it's installed via cask.
      userSettings = {
        vim_mode = true;
        ui_font_size = 16;
        buffer_font_size = 16;
        restore_on_startup = "last_workspace";
        buffer_font_family = "JetBrainsMono Nerd Font Mono";
        buffer_font_features = {
          calt = false;
        };
        autosave = "on_window_change";
        load_direnv = "shell_hook";
        show_wrap_guides = true;
        wrap_guides = [ 80 ];
        inlay_hints = {
          enabled = true;
        };
        preview_tabs = {
          enabled = true;
          enable_preview_from_file_finder = true;
          enable_preview_from_code_navigation = true;
        };
        minimap = {
          show = "auto";
        };
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        lsp = {
          nil = {
            initialization_options = {
              formatting = {
                command = [ "nixfmt" ];
              };
            };
          };
        };
        git = {
          inline_blame = {
            enabled = true;
            delay_ms = 500;
          };
        };
        terminal = {
          line_height = "standard";
        };
      };
      extensions = [
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
    stylix.targets.zed = {
      enable = true;
      # Colours only — we set buffer/ui font size and family explicitly in
      # `userSettings` above. Letting Stylix manage Zed fonts would
      # override those to `stylix.fonts.sizes.applications` (default 12).
      fonts.enable = false;
    };
  };
}
