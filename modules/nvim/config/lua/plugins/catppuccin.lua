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
                    dim_dirname = true,
                    bold_basename = true,
                    dim_context = false,
                    alt_background = false,
                },
                native_lsp = {
                    enabled = true,
                    virtual_text = {
                        errors = { "italic" },
                        hints = { "italic" },
                        warnings = { "italic" },
                        information = { "italic" },
                        ok = { "italic" },
                    },
                    underlines = {
                        errors = { "undercurl" },
                        hints = { "undercurl" },
                        warnings = { "undercurl" },
                        information = { "undercurl" },
                        ok = { "underline" },
                    },
                    inlay_hints = {
                        background = true,
                    },
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
                        },
                        WinSeparator = {
                            fg = colors.surface0,
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
