--[[
Neovim knows to search:
* ~/.config/nvim/lua for our custom scripts when we call require().
* ~/.config/nvim/plugin for installed plugins (+ our own plugin configuration scripts).
:h runtimepath
--]]

-- vim.g.active_color_scheme = "rose-pine"
-- vim.g.active_color_scheme = "catppuccin"
-- vim.g.active_color_scheme = "nightfox"
vim.g.active_color_scheme = "tokyonight"

require("options")
require("plugin-manager")
require("mappings")
require("autocmds")
