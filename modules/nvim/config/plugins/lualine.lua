return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
      options = {
        globalstatus = true,
        theme = vim.g.active_color_scheme,
        disabled_filetypes = { 'packer', 'NvimTree', 'Diffview' },
      },
    },
    init = function()
        vim.go.showtabline = 0
    end,
}
