return {
    "ray-x/go.nvim",
    lazy = true,
    dependencies = { -- optional packages
        "ray-x/guihua.lua", "neovim/nvim-lspconfig",
        "nvim-treesitter/nvim-treesitter"
    },
    config = function()
        local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
        require("go").setup({
            lsp_cfg = {
                capabilities = capabilities,
            },
        })
        local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*.go",
          callback = function()
           require('go.format').goimports()
          end,
          group = format_sync_grp,
        })
    end,
    event = {"CmdlineEnter"},
    ft = {"go", 'gomod'},
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
}
