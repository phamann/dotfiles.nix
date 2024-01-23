return {
    "folke/styler.nvim",
    event = "VeryLazy",
    opts = {
      themes = {
        markdown = { colorscheme = vim.g.active_color_scheme },
        -- help = { colorscheme = "oxocarbon", background = "dark" },
      },
    },
}
