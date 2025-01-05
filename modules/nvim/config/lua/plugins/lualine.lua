return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        options = {
            globalstatus = true,
            theme = "catppuccin",
            disabled_filetypes = { 'packer', 'NvimTree', 'NeoTree', 'Diffview' }
        }
    },
    init = function() vim.go.showtabline = 0 end
}
