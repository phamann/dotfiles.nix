return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    opts = {
        options = {
            globalstatus = true,
            theme = "catppuccin-nvim",
            disabled_filetypes = { 'packer', 'NvimTree', 'NeoTree', 'Diffview' }
        }
    },
    init = function() vim.go.showtabline = 0 end
}
