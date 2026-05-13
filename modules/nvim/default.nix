{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.modules.nvim;
in
{
  options.modules.nvim = {
    enable = mkEnableOption "nvim";
    # Opt-in for hosts where you iterate on the nvim config live. When set,
    # ~/.config/nvim is an out-of-store symlink to the repo path, so editing
    # lua files takes effect on the next nvim launch without a rebuild.
    # Leave off (the default) to materialize the config as a regular store
    # path — reproducible, no dependency on the repo living at a fixed path.
    dev = mkEnableOption "live-symlinked nvim config";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
      };
    }
    (mkIf cfg.dev {
      xdg.configFile.nvim = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixpkgs/modules/nvim/config";
        recursive = true;
      };
    })
    (mkIf (!cfg.dev) {
      xdg.configFile.nvim = {
        source = ./config;
        recursive = true;
      };
    })
  ]);
}
