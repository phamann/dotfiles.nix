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
        # Content of init.lua. HM merges this with whatever Stylix's neovim
        # target adds (mini.base16 palette + setup call). The standalone
        # init.lua file in the repo (modules/nvim/config/init.lua) is now
        # unused — the previous \`vim.g.active_color_scheme\` line was dead
        # code anyway (its consumers are colorscheme plugins that no longer
        # exist, plus barbecue/styler which fall back gracefully).
        extraLuaConfig = ''
          require("options")
          require("plugin-manager")
          require("mappings")
          require("autocmds")
        '';
      };

      stylix.targets.neovim.enable = true;
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
