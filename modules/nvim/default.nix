{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.modules.nvim;

  # Path under the repo where the live config lives.
  liveConfigPath = "${config.home.homeDirectory}/.config/nixpkgs/modules/nvim/config";
in
{
  options.modules.nvim = {
    enable = mkEnableOption "nvim";
    # Opt-in for hosts where you iterate on the nvim config live. When set,
    # ~/.config/nvim/lua and ~/.config/nvim/lazy-lock.json are out-of-store
    # symlinks to the repo path, so editing lua files takes effect on the
    # next nvim launch without a rebuild. ~/.config/nvim/init.lua is always
    # owned by home-manager (see programs.neovim.extraLuaConfig below); it
    # gets Stylix's mini.base16 setup injected into it at build time.
    dev = mkEnableOption "live-symlinked nvim config";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        # init.lua content. Colorscheme is `tinted-vim` (installed via lazy,
        # see modules/nvim/config/lua/plugins/tinted-vim.lua). We publish the
        # full base24 palette to `vim.g.stylix_palette` up front for lua
        # overrides that need scheme slots directly (lualine theme, neo-tree
        # tabs, etc.); tinted-vim itself handles all the standard highlight
        # groups and treesitter captures.
        extraLuaConfig =
          let
            c = config.lib.stylix.colors.withHashtag;
            # base16 schemes don't define base10-base17; fall back to the
            # nearest base16 slot so vim.g.stylix_palette.base1X always
            # resolves regardless of the active scheme system.
            base10 = c.base10 or c.base00;
            base11 = c.base11 or c.base01;
            base12 = c.base12 or c.base08;
            base13 = c.base13 or c.base09;
            base14 = c.base14 or c.base0B;
            base15 = c.base15 or c.base0C;
            base16 = c.base16 or c.base0D;
            base17 = c.base17 or c.base0E;
          in
          ''
            vim.g.stylix_palette = {
              base00 = "${c.base00}", base01 = "${c.base01}", base02 = "${c.base02}", base03 = "${c.base03}",
              base04 = "${c.base04}", base05 = "${c.base05}", base06 = "${c.base06}", base07 = "${c.base07}",
              base08 = "${c.base08}", base09 = "${c.base09}", base0A = "${c.base0A}", base0B = "${c.base0B}",
              base0C = "${c.base0C}", base0D = "${c.base0D}", base0E = "${c.base0E}", base0F = "${c.base0F}",
              base10 = "${base10}", base11 = "${base11}", base12 = "${base12}", base13 = "${base13}",
              base14 = "${base14}", base15 = "${base15}", base16 = "${base16}", base17 = "${base17}",
            }
            require("options")
            require("plugin-manager")
            require("mappings")
            require("autocmds")
            vim.cmd.colorscheme("${config.modules.theme.system}-${config.modules.theme.scheme}")
          '';
      };
    }

    # When dev is on, symlink only the subdirs/files we want live-editable.
    # `init.lua` is HM-managed (see extraLuaConfig above) — narrowing the
    # symlink scope is what lets that coexist without claim conflicts.
    (mkIf cfg.dev {
      xdg.configFile = {
        "nvim/lua" = {
          source = config.lib.file.mkOutOfStoreSymlink "${liveConfigPath}/lua";
          recursive = true;
        };
        "nvim/lazy-lock.json".source =
          config.lib.file.mkOutOfStoreSymlink "${liveConfigPath}/lazy-lock.json";
      };
    })

    # When dev is off (yoda), copy the lua tree into the store as normal.
    # Same narrow-scope pattern — init.lua stays HM-managed.
    (mkIf (!cfg.dev) {
      xdg.configFile = {
        "nvim/lua" = {
          source = ./config/lua;
          recursive = true;
        };
        "nvim/lazy-lock.json".source = ./config/lazy-lock.json;
      };
    })
  ]);
}
