return {
    "navarasu/onedark.nvim",
    enabled = (vim.g.active_color_scheme == "onedark" and true or false),
    lazy = false,    -- make sure we load this during startup
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        require('onedark').setup({
            style = 'dark'
        })
        vim.cmd([[colorscheme onedark]])
    end,
}
