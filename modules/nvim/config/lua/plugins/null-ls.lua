return {
    "nvimtools/none-ls.nvim",
    config = function()
        local null_ls = require("null-ls")

        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
        null_ls.setup({
            -- format on save - https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save#code
            on_attach = function(client, bufnr)
                if client.supports_method("textDocument/formatting") then
                    vim.api.nvim_clear_autocmds({
                        group = augroup,
                        buffer = bufnr
                    })
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = augroup,
                        buffer = bufnr,
                        callback = function()
                            -- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save#choosing-a-client-for-formatting
                            vim.lsp.buf.format({
                                bufnr = bufnr,
                                filter = function(client)
                                    return client.name == "null-ls"
                                end
                            })
                        end
                    })
                end
            end,
            sources = {
                null_ls.builtins.diagnostics.hadolint,
                null_ls.builtins.diagnostics.jsonlint,
                null_ls.builtins.diagnostics.luacheck,
                -- null_ls.builtins.diagnostics.markdownlint,
                -- null_ls.builtins.diagnostics.semgrep,
                -- null_ls.builtins.diagnostics.shellcheck,
                -- null_ls.builtins.diagnostics.staticcheck,
                null_ls.builtins.diagnostics.statix,
                null_ls.builtins.diagnostics.yamllint.with({
                    extra_args = {
                        "-d",
                        '{extends: relaxed, rules: {line-length: {max: 120}, document-start: disable}}'
                    }
                }), -- null_ls.builtins.formatting.beautysh,
                -- null_ls.builtins.formatting.buf,
                -- null_ls.builtins.formatting.cbfmt,
                null_ls.builtins.formatting.fixjson,
                null_ls.builtins.formatting.gofumpt,
                null_ls.builtins.formatting.goimports,
                null_ls.builtins.formatting.goimports_reviser,
                null_ls.builtins.formatting.jq,
                null_ls.builtins.formatting.lua_format,
                null_ls.builtins.formatting.nixpkgs_fmt,
                null_ls.builtins.formatting.rustfmt,
                null_ls.builtins.formatting.shfmt
                    .with({extra_args = {"-i", "4", "-ci"}}),
                null_ls.builtins.formatting.terraform_fmt
                -- null_ls.builtins.formatting.yamlfmt
            }
        })
    end
}
