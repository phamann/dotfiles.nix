return {
    "marko-cerovac/material.nvim",
    enabled = (vim.g.active_color_scheme == "material" and true or false),
    name = "material",
    lazy = false, -- make sure we load this during startup
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        require("material").setup({
            contrast = {
                terminal = true, -- Enable contrast for the built-in terminal
                sidebars = false, -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
                floating_windows = false, -- Enable contrast for floating windows
                cursor_line = true, -- Enable darker background for the cursor line
                lsp_virtual_text = true, -- Enable contrasted background for lsp virtual text
                non_current_windows = false, -- Enable contrasted background for non-current windows
                filetypes = {}, -- Specify which filetypes get the contrasted (darker) background
            },

            styles = { -- Give comments style such as bold, italic, underline etc.
                comments = {
                    italic = true,
                },
                strings = { --[[ bold = true ]] },
                keywords = { --[[ underline = true ]] },
                functions = { --[[ bold = true, undercurl = true ]] },
                variables = {},
                operators = {},
                types = {},
            },

            plugins = { -- Uncomment the plugins that you use to highlight them
                -- Available plugins:
                -- "coc",
                -- "colorful-winsep",
                -- "dap",
                -- "dashboard",
                -- "eyeliner",
                -- "fidget",
                -- "flash",
                "gitsigns",
                -- "harpoon",
                -- "hop",
                -- "illuminate",
                "indent-blankline",
                -- "lspsaga",
                -- "mini",
                "neogit",
                -- "neotest",
                "neo-tree",
                -- "neorg",
                "noice",
                "nvim-cmp",
                -- "nvim-navic",
                -- "nvim-tree",
                "nvim-web-devicons",
                "rainbow-delimiters",
                -- "sneak",
                "telescope",
                "trouble",
                "which-key",
                "nvim-notify",
            },
            lualine_style = "stealth", -- Lualine style ( can be 'stealth' or 'default' )
            async_loading = true, -- Load parts of the theme asynchronously for faster startup (turned on by default)
        })
        -- load the colorscheme here
        vim.g.material_style = "palenight"
        vim.cmd([[colorscheme material]])
    end
}
