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
    home.file."lazy-lock.json".source = ./lazy-lock.json;
    home.packages = with pkgs; [
        neovim
    ];
    xdg.configFile = {
      nvim = {
      source =
        config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/.config/nixpkgs/nvim/lua";
        recursive = true;
      };
    };
  };
}
