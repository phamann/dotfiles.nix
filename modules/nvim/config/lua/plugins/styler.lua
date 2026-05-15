return {
    "folke/styler.nvim",
    event = "VeryLazy",
    -- No per-filetype overrides today — markdown previously read
    -- `vim.g.active_color_scheme` which no longer exists. Stylix's
    -- mini.base16 sets the global highlight palette and that suffices.
    -- Add per-filetype overrides back here if/when wanted.
    opts = {
      themes = { },
    },
}
