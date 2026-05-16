return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
        local p = vim.g.stylix_palette
        -- Classic powerline shape, palette-driven:
        --   a (mode indicator)  → accent bg, dark fg
        --   b (git/filetype)    → surface0 bg (base02), text fg
        --   c (filename/path)   → mantle bg (base01, darker than editor)
        local b_section = { fg = p.base05, bg = p.base02 }
        local c_section = { fg = p.base05, bg = p.base01 }
        local mode = function(accent)
            return { fg = p.base00, bg = accent, gui = "bold" }
        end
        local muted = { fg = p.base04, bg = p.base01 }
        return {
            options = {
                globalstatus = true,
                disabled_filetypes = { "packer", "NvimTree", "NeoTree", "Diffview" },
                theme = {
                    normal   = { a = mode(p.base0D), b = b_section, c = c_section },
                    insert   = { a = mode(p.base0B), b = b_section, c = c_section },
                    visual   = { a = mode(p.base0E), b = b_section, c = c_section },
                    replace  = { a = mode(p.base08), b = b_section, c = c_section },
                    command  = { a = mode(p.base0A), b = b_section, c = c_section },
                    inactive = { a = muted,          b = muted,     c = muted     },
                },
            },
        }
    end,
    init = function() vim.go.showtabline = 0 end,
}
