return {
    "catppuccin/nvim",
    enabled = (vim.g.active_color_scheme == "catppuccin" and true or false),
    name = "catppuccin",
    lazy = false,    -- make sure we load this during startup
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        require("catppuccin").setup({
            flavour = "frappe", -- latte, frappe, macchiato, mocha
            dim_inactive = {
                enabled = false,
                shade = "dark",
                percentage = 0.15
            },
            default_integrations = false,
            integrations = {
                aerial = true,
                barbecue = {
                    enabled = true,
                    dim_dirname = true,
                },
                native_lsp = {
                    enabled = true,
                    underlines = {
                        errors = { "undercurl" },
                        hints = { "undercurl" },
                        warnings = { "undercurl" },
                        information = { "undercurl" }
                    }
                },
                indent_blankline = { enabled = true },
                diffview = true,
                neogit = true,
                neotree = true,
                telescope = {
                    enabled = true,
                },
                lsp_trouble = true,
            },
            highlight_overrides = {
                all = function(colors)
                    return {
                        IndentBlankLineSpaceChar = {
                            fg = colors.surface0,
                            nocombine = true
                        },
                        IndentBlankLineContextSpaceChar = {
                            fg = colors.surface1,
                            nocombine = true
                        }
                    }
                end,
                macchiato = function(macchiato) end
            }
        })
        -- load the colorscheme here
        vim.cmd([[colorscheme catppuccin]])
    end
}
