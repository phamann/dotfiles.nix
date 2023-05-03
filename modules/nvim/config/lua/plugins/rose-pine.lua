return {
    'rose-pine/neovim',
    enabled = (vim.g.active_color_scheme == "rose-pine" and true or false),
    name = 'rose-pine',
    config = function()
        require("rose-pine").setup({
            variant = "main",
        })
        -- load the colorscheme here
        vim.cmd([[colorscheme rose-pine]])
    end,
}
