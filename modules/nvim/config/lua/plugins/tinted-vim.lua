-- The active colourscheme. modules/nvim/default.nix calls
-- `vim.cmd.colorscheme("base16-<scheme>")` at the end of init.lua, after
-- lazy.setup() returns — so this plugin needs to be on rtp by then.
-- lazy = false + priority = 1000 makes it a start plugin loaded first.
return {
    "tinted-theming/tinted-vim",
    lazy = false,
    priority = 1000,
}
