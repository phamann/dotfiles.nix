return {
    "nvim-lualine/lualine.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    opts = {
        options = {
            globalstatus = true,
            --[[ theme = (vim.g.active_color_scheme == "tokyonight" and
                "tokyonight" or "base16"), ]] --
            disabled_filetypes = {'packer', 'NvimTree', 'NeoTree', 'Diffview'}
        }
    },
    init = function() vim.go.showtabline = 0 end
}
