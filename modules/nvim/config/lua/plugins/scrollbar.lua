return {
    "petertriho/nvim-scrollbar",
    event = "BufReadPost",
    config = function()
        local p = vim.g.stylix_palette
        require("scrollbar").setup({
            handle = { color = p.base02 },
            excluded_filetypes = {
                "prompt", "TelescopePrompt", "noice", "notify", "NvimTree",
                "NeoTree",
            },
            marks = {
                Search = { color = p.base09 },
                Error  = { color = p.base08 },
                Warn   = { color = p.base0A },
                Info   = { color = p.base0D },
                Hint   = { color = p.base0C },
                Misc   = { color = p.base0E },
            },
        })
    end,
}
