--[[
Neovim knows to search:
* ~/.config/nvim/lua for our custom scripts when we call require().
* ~/.config/nvim/plugin for installed plugins (+ our own plugin configuration scripts).
:h runtimepath
--]] -- vim.g.active_color_scheme = "rose-pine"
-- vim.g.active_color_scheme = "kanagawa"
-- vim.g.active_color_scheme = "catppuccin"
-- vim.g.active_color_scheme = "nightfox"
-- vim.g.active_color_scheme = "tokyonight"
vim.g.active_color_scheme = "onedark"
-- vim.g.active_color_scheme = "doom-one"
-- vim.g.active_color_scheme = "github"
-- vim.g.active_color_scheme = "moonfly"
-- vim.g.active_color_scheme = "onedark"
-- vim.g.active_color_scheme = "material"

require("options")
require("plugin-manager")
require("mappings")
require("autocmds")
