return {
    "petertriho/nvim-scrollbar",
    -- v2 (a full rewrite) replaces v1 on main and rejects every v1 setup()
    -- option. Stay on v1 until this config is ported; see
    -- https://github.com/petertriho/nvim-scrollbar/issues/121
    branch = "v1",
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
