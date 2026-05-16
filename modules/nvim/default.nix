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
        # init.lua content. HM appends Stylix's base16-nvim setup call after
        # this block. We publish the full base24 palette to `vim.g.stylix_palette`
        # up front so any later lua override can reference scheme slots
        # directly (e.g. `p.base04`) without guessing which standard highlight
        # group the active palette-mapper happened to assign to that slot.
        extraLuaConfig =
          let
            inherit (config.lib.stylix.colors.withHashtag)
              base00
              base01
              base02
              base03
              base04
              base05
              base06
              base07
              base08
              base09
              base0A
              base0B
              base0C
              base0D
              base0E
              base0F
              base10
              base11
              base12
              base13
              base14
              base15
              base16
              base17
              ;
          in
          ''
            vim.g.stylix_palette = {
              base00 = "${base00}", base01 = "${base01}", base02 = "${base02}", base03 = "${base03}",
              base04 = "${base04}", base05 = "${base05}", base06 = "${base06}", base07 = "${base07}",
              base08 = "${base08}", base09 = "${base09}", base0A = "${base0A}", base0B = "${base0B}",
              base0C = "${base0C}", base0D = "${base0D}", base0E = "${base0E}", base0F = "${base0F}",
              base10 = "${base10}", base11 = "${base11}", base12 = "${base12}", base13 = "${base13}",
              base14 = "${base14}", base15 = "${base15}", base16 = "${base16}", base17 = "${base17}",
            }
            require("options")
            require("plugin-manager")
            require("mappings")
            require("autocmds")
          '';
      };

      stylix.targets.neovim = {
        enable = true;
        plugin = "base16-nvim";
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
