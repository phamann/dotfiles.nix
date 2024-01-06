return {
    -- autocomplete
    "hrsh7th/nvim-cmp",
    lazy = true,
    event = "InsertEnter", -- lazy load cmp on InsertEnter
    dependencies = {
        "onsails/lspkind.nvim",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-vsnip",
        "hrsh7th/vim-vsnip",
        "hrsh7th/vim-vsnip-integ",
    },
    config = function()
        local cmp = require("cmp")
        local lspkind = require("lspkind")
        local luasnip = require("luasnip")

        vim.opt.completeopt = {"menu", "menuone", "noselect"}

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end
            },
            mapping = {
                ["<Up>"] = cmp.mapping.select_prev_item(),
                ["<Down>"] = cmp.mapping.select_next_item(),
                ["<Left>"] = cmp.mapping.select_prev_item(),
                ["<Right>"] = cmp.mapping.select_next_item(),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
                ["<C-e>"] = cmp.mapping.close(),
                ["<CR>"] = cmp.mapping.confirm({
                  behavior = cmp.ConfirmBehavior.Insert,
                  select = true,
                })
              },
            sources = {
                { name = "buffer" },
                { name = "nvim_lua" },
                { name = "nvim_lsp" },
                { name = "nvim_lsp_signature_help" },
                { name = "luasnip"},
                { name = "path" },
                { name = "vsnip" },
            },
            formatting = {
                format = lspkind.cmp_format({
                    mode = "text",
                    maxwidth = 50,
                    ellipsis_char = "...",
                    menu = {
                        buffer = "[buf]",
                        nvim_lsp = "[LSP]",
                        nvim_lua = "[api]",
                        path = "[path]",
                        luasnip = "[snip]"
                    }
                }),
                experimental = {native_menu = false, ghost_text = true}
            }
        })
    end,
}
