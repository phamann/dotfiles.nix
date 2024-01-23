-- This file contains simple plugin spec definitions that don't
-- warrant their own file.
return {
    -- syntax tree parsing for more intelligent syntax highlighting and code navigation
    --[[ {
        "m-demare/hlargs.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        config = true,
    }, ]]
    "fladson/vim-kitty", "fgsch/vim-varnish", "L3MON4D3/LuaSnip",

    -- git change indicator
    {"lewis6991/gitsigns.nvim", config = true}, -- ui improvements
    {"stevearc/dressing.nvim", event = "VeryLazy"},

    -- modify surrounding characters
    "tpope/vim-surround", -- highlight yanked region
    "machakann/vim-highlightedyank", -- suggest mappings
    {"folke/which-key.nvim", config = true}, -- display hex colours
    {"norcalli/nvim-colorizer.lua", config = true}, -- icons
    {"nvim-tree/nvim-web-devicons", opts = {default = true}}

}
