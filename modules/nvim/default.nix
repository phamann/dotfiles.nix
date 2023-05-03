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
    programs.neovim = {
      enable = true;
      extraConfig = ''
        luafile ${config.xdg.configHome}/nvim/init.lua
      '';
      vimdiffAlias = true;
    };
    xdg.configFile = {
      nvim = {
        source = ./lua;
        recursive = true;
      };
    };
  };
}
