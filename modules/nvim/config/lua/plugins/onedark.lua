return {
    "navarasu/onedark.nvim",
    enabled = (vim.g.active_color_scheme == "onedark" and true or false),
    lazy = false,    -- make sure we load this during startup
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        require('onedark').setup({
            style = 'dark',
            colors = {
              fg = '#c8ccd4',
              purple = '#a58faf',
              blue = "#599de2",
              cyan = "#6eb4bf",
              orange = "#bf956a",
              green = "#a1c181",
              grey = "#5d636f",
            },
            highlights = {
                Identifier = {fg = '$fg' },
                Special = {fg = '$fg' },
                SpecialChar = {fg = '$fg' },
                Macro = {fg = '$fg' },
                ["@type"] = { fg = '$cyan' },
                ["@variable"] = { fg = '$fg' },
                ["@variable.builtin"] = { fg = '$fg' },
                ["@variable.parameter"] = { fg = '$fg' },
                ["@parameter"] = { fg = '$fg' },
                ["@label"] = { fg = "$fg" },
                ["@module"] = { fg = "$fg" },
            }
        })
        vim.cmd([[colorscheme onedark]])
    end,
}
