return {
    "folke/tokyonight.nvim",
    enabled = (vim.g.active_color_scheme == "tokyonight" and true or false),
    lazy = false, -- make sure we load this during startup
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        require("tokyonight").setup({
            style = "moon",
            hide_inactive_statusline = true,
            styles = {
                -- Style to be applied to different syntax groups
                -- Value is any valid attr-list value for `:help nvim_set_hl`
                comments = { italic = true },
                keywords = { italic = true },
                functions = {},
                variables = {},
                -- Background styles. Can be "dark", "transparent" or "normal"
                sidebars = "dark", -- style for sidebars, see below
                floats = "transparent", -- style for floating windows
            },
            --[[ on_highlights = function(hl, c)
                hl.CursorLine = { c.}
            end, ]]
            on_highlights = function(hl, c)
              hl.CursorLineNr = { fg = c.orange, bold = true }
              hl.LineNr = { fg = c.orange, bold = true }
              hl.LineNrAbove = { fg = c.fg_gutter }
              hl.LineNrBelow = { fg = c.fg_gutter }
              local prompt = "#2d3149"
              hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg_dark }
              hl.TelescopeBorder = { bg = c.bg_dark, fg = c.bg_dark }
              hl.TelescopePromptNormal = { bg = prompt }
              hl.TelescopePromptBorder = { bg = prompt, fg = prompt }
              hl.TelescopePromptTitle = { bg = c.fg_gutter, fg = c.orange }
              hl.TelescopePreviewTitle = { bg = c.bg_dark, fg = c.orange }
              hl.TelescopeResultsTitle = { bg = c.bg_dark, fg = c.orange }
              hl.NvimTreeOpenedFile = { bg = c.bg_dark, fg = c.orange }
            end,
        })
        -- load the colorscheme here
        vim.cmd([[colorscheme tokyonight]])
    end,
}
