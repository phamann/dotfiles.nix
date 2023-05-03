{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.nvim;
in
{
  options.modules.nvim = { enable = mkEnableOption "nvim"; };
  config = mkIf cfg.enable {
    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
    };
    xdg.configFile = {
      nvim = {
        source =
          config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/.config/nixpkgs/modules/nvim/config";
        recursive = true;
      };
    };
  };
}
