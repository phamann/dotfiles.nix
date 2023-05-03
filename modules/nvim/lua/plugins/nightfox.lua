return {
    "EdenEast/nightfox.nvim",
    enabled = (vim.g.active_color_scheme == "nightfox" and true or false),
    lazy = false, -- make sure we load this during startup
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        require("nightfox").setup({
            options = {
                dim_inactive = true,
                styles = {
                    comments = "italic",
                    keywords = "bold",
                    types = "italic,bold",
                },
            },
        })
        -- load the colorscheme here
        vim.cmd([[colorscheme duskfox]])
    end,
}
