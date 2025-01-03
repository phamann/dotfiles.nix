return {
    "folke/tokyonight.nvim",
    enabled = (vim.g.active_color_scheme == "doom-one" and true or false),
    lazy = false, -- make sure we load this during startup
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        require("NTBBloodbath/doom-one.nvim").setup()
            vim.g.doom_one_cursor_coloring = true
            -- Set :terminal colors
            vim.g.doom_one_terminal_colors = true
            -- Enable italic comments
            vim.g.doom_one_italic_comments = true
            -- Enable TS support
            vim.g.doom_one_enable_treesitter = true
            -- Color whole diagnostic text or only underline
            vim.g.doom_one_diagnostics_text_color = true
            -- Enable transparent background
            vim.g.doom_one_transparent_background = false

            -- Plugins integration
            vim.g.doom_one_plugin_neorg = true
            vim.g.doom_one_plugin_telescope = true
            vim.g.doom_one_plugin_neogit = true
            vim.g.doom_one_plugin_nvim_tree = true
            vim.g.doom_one_plugin_whichkey = true
            vim.g.doom_one_plugin_indent_blankline = true
            vim.g.doom_one_plugin_lspsaga = false
        -- load the colorscheme here
        vim.cmd([[colorscheme doom-one]])
    end
}
