-- Stylix appends `require('base16-colorscheme').setup({...})` to init.lua;
-- this spec ensures base16-nvim is on the runtime path when that fires.
return {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
}
