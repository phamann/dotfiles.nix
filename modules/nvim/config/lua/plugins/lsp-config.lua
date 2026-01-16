local shared_on_attach = function(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', '<c-]>', "<Cmd>lua vim.lsp.buf.definition()<CR>",
        bufopts)
    vim.keymap.set('n', '<leader>k',
        "<Cmd>lua vim.lsp.buf.signature_help()<CR>", bufopts)
    vim.keymap.set('n', 'K', "<Cmd>lua vim.lsp.buf.hover()<CR>", bufopts)
    vim.keymap.set('n', 'gi', "<Cmd>lua vim.lsp.buf.implementation()<CR>",
        bufopts)
    vim.keymap.set('n', 'giC', "<Cmd>lua vim.lsp.buf.incoming_calls()<CR>",
        bufopts)
    vim.keymap.set('n', 'gd', "<Cmd>lua vim.lsp.buf.type_definition()<CR>",
        bufopts)
    vim.keymap.set('n', 'gr', "<Cmd>lua vim.lsp.buf.references()<CR>", bufopts)
    vim.keymap.set('n', 'gn', "<Cmd>lua vim.lsp.buf.rename()<CR>", bufopts)
    vim.keymap.set('n', 'gs', "<Cmd>lua vim.lsp.buf.document_symbol()<CR>",
        bufopts)
    vim.keymap.set('n', 'gw', "<Cmd>lua vim.lsp.buf.workspace_symbol()<CR>",
        bufopts)
    vim.keymap.set('n', '<leader>z', "<Cmd>lua vim.diagnostic.goto_prev()<CR>",
        bufopts)
    vim.keymap.set('n', '<leader>x', "<Cmd>lua vim.diagnostic.goto_next()<CR>",
        bufopts)
    vim.keymap.set('n', '<leader>ds', "<Cmd>lua vim.diagnostic.show()<CR>",
        bufopts)

    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.rs", "*.go" },
        command = [[lua vim.lsp.buf.format()]]
    })
end

function OrgImports(wait_ms)
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction",
        params, wait_ms)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
            else
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end
end

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/nvim-cmp",
        { "williamboman/nvim-lsp-installer", config = true },
        { "j-hui/fidget.nvim",               config = true },
        {
          'mrcjkb/rustaceanvim',
          version = '^6', -- Recommended
          lazy = false, -- This plugin is already lazy
        }
    },
    config = function()
        local configs = require("lspconfig.configs")
        local util = require("lspconfig.util")
        local map = vim.api.nvim_set_keymap
        local option = vim.api.nvim_set_option

        -- Enable completion triggered by <c-x><c-o>
        option("omnifunc", "v:lua.vim.lsp.omnifunc")

        -- Mappings.
        local opts = { noremap = true, silent = true }

        -- See `:help vim.lsp.*` for documentation on any of the below functions
        map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
        map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
        map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
        map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
        map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
        map("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
        map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
        map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
        map("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
        map("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)

        vim.diagnostic.config({
            virtual_text = false,
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = false
        })

        -- https://github.com/hrsh7th/nvim-cmp/issues/1208#issuecomment-1281501620
        local function get_forced_lsp_capabilities()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport =
                true
            capabilities.textDocument.completion.completionItem.resolveSupport =
            {
                properties = {
                    "documentation", "detail", "additionalTextEdits"
                }
            }
            return capabilities
        end

        local function my_lsp_on_attach(client, bufnr)
            local capabilities = require("cmp_nvim_lsp").default_capabilities(
                vim.lsp.protocol.make_client_capabilities())
        end

        util.default_config = vim.tbl_extend("force", util.default_config, {
            autostart = true,
            on_attach = my_lsp_on_attach,
            capabilities = get_forced_lsp_capabilities()
        })

        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
        local servers = {
            "rust_analyzer", "bashls", "dockerls", "terraformls", "tflint",
            "ts_ls", "jdtls"
        }

        -- NOTE: Call setup last
        -- https://github.com/hrsh7th/nvim-cmp/issues/1208#issuecomment-1281501620
        for _, lsp in ipairs(servers) do
            vim.lsp.config(lsp, { on_attach = shared_on_attach })
            -- lspconfig[lsp].setup(coq.lsp_ensure_capabilities())
            -- lspconfig[lsp].setup {capabilities = capabilities}
        end

        vim.g.rustaceanvim = {
            -- rust-tools options
            tools = {
                autoSetHints = true,
                inlay_hints = {
                    show_variable_name = true,
                    show_parameter_hints = true,
                    parameter_hints_prefix = "<- ",
                    other_hints_prefix = "=> "
                }
            },

            -- all the opts to send to nvim-lspconfig
            -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            -- https://rust-analyzer.github.io/manual.html#features
            server = {
                on_attach = function(_, bufnr)
                    shared_on_attach(_, bufnr)
                    -- Hover actions
                    vim.keymap.set("n", "<C-space>",
                        rt.hover_actions.hover_actions,
                        { buffer = bufnr })
                    -- Code action groups
                    vim.keymap.set("n", "<Leader>a",
                        rt.code_action_group.code_action_group,
                        { buffer = bufnr })
                    vim.keymap.set('n', '<leader>rr', "<Cmd>RustRunnables<CR>",
                        bufopts)
                end,
                default_settings = {
                    ["rust-analyzer"] = {
                        assist = {
                            importEnforceGranularity = true,
                            importPrefix = "crate"
                        },
                        cargo = { allFeatures = true },
                        checkOnSave = true
                    },
                    inlayHints = {
                        lifetimeElisionHints = {
                            enable = true,
                            useParameterNames = true
                        }
                    }
                }
            }
        }

        -- NOTE: When using :LspInstallInfo to install available LSPs, we need to still
        -- add calls to their setup here in our Vim configuration.
        vim.lsp.config('terraformls', {
            filetypes = { "terraform", "terraform-vars", "hcl" },
            on_attach = function(client, bufnr)
                shared_on_attach(client, bufnr)
            end
        })
        --[[ lspconfig.java_language_server.setup {
            on_attach = function(client, bufnr)
                shared_on_attach(client, bufnr)
            end,
            cmd = {"java-language-server"}
        } ]]

        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
        local workspace_dir = vim.fn.expand(
            '$HOME/.cache/jdtls/' .. project_name)

        vim.lsp.config('jdtls', {
            cmd = { "jdtls", "-data", workspace_dir }
        })

        if not configs.regols then
            configs.regols = {
                default_config = {
                    cmd = { 'regols' },
                    filetypes = { 'rego' },
                    root_dir = util.root_pattern(".git")
                }
            }
        end
        vim.lsp.enable('ruby_lsp')

        -- Styling
        -- https://github.com/folke/dot/blob/6e89c6cf2ad92a8b0335ab69d51fc275f78dd524/config/nvim/lua/config/lsp/diagnostics.lua
        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp
            .diagnostic
            .on_publish_diagnostics,
            {
                underline = true,
                update_in_insert = false,
                virtual_text = { spacing = 2, prefix = "●" },
                severity_sort = true
            })

        local signs = {
          Error = " ",
          Warn  = " ",
          Hint  = " ",
          Info  = " ",
        }

        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
    end
}
