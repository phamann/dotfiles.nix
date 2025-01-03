return {
    "olimorris/onedarkpro.nvim",
    enabled = (vim.g.active_color_scheme == "onedarkpro" and true or false),
    lazy = false,    -- make sure we load this during startup
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        require('onedarkpro').setup({
            style = 'dark'
        })
        vim.cmd([[colorscheme onedark]])
    end,
}
