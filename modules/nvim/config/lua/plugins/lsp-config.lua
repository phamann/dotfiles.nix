local shared_on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', '<c-]>', "<Cmd>lua vim.lsp.buf.definition()<CR>", bufopts)
  vim.keymap.set('n', '<leader>k', "<Cmd>lua vim.lsp.buf.signature_help()<CR>", bufopts)
  vim.keymap.set('n', 'K', "<Cmd>lua vim.lsp.buf.hover()<CR>", bufopts)
  vim.keymap.set('n', 'gi', "<Cmd>lua vim.lsp.buf.implementation()<CR>", bufopts)
  vim.keymap.set('n', 'giC', "<Cmd>lua vim.lsp.buf.incoming_calls()<CR>", bufopts)
  vim.keymap.set('n', 'gd', "<Cmd>lua vim.lsp.buf.type_definition()<CR>", bufopts)
  vim.keymap.set('n', 'gr', "<Cmd>lua vim.lsp.buf.references()<CR>", bufopts)
  vim.keymap.set('n', 'gn', "<Cmd>lua vim.lsp.buf.rename()<CR>", bufopts)
  vim.keymap.set('n', 'gs', "<Cmd>lua vim.lsp.buf.document_symbol()<CR>", bufopts)
  vim.keymap.set('n', 'gw', "<Cmd>lua vim.lsp.buf.workspace_symbol()<CR>", bufopts)
  vim.keymap.set('n', '<leader>z', "<Cmd>lua vim.diagnostic.goto_prev()<CR>", bufopts)
  vim.keymap.set('n', '<leader>x', "<Cmd>lua vim.diagnostic.goto_next()<CR>", bufopts)
  vim.keymap.set('n', '<leader>ds', "<Cmd>lua vim.diagnostic.show()<CR>", bufopts)

  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = {
      "*.rs", "*.go",
    },
    command = [[lua vim.lsp.buf.format()]]
  })
end

function OrgImports(wait_ms)
  local params = vim.lsp.util.make_range_params()
  params.context = {only = {"source.organizeImports"}}
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
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
        { "williamboman/nvim-lsp-installer", config = true },
        { "j-hui/fidget.nvim", config = true },
        "simrat39/rust-tools.nvim",
    },
    config = function()
        local lspcfg = require("lspconfig")

        lspcfg.gopls.setup({
          on_attach = function(client, bufnr)
            shared_on_attach(client, bufnr)

            vim.api.nvim_create_autocmd("BufWritePre", {
              pattern = {
                "*.go"
              },
              command = [[lua OrgImports(1000)]]
            })
          end,
            cmd = {"gopls"},
          settings = {
            gopls = {
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              experimentalPostfixCompletions = true,
              gofumpt = true,
              staticcheck = true,
              usePlaceholders = true,
            },
          },
        })

        lspcfg.solargraph.setup({})

        require("rust-tools").setup({
          -- rust-tools options
          tools = {
            autoSetHints = true,
            inlay_hints = {
              show_variable_name = true,
              show_parameter_hints = true,
              parameter_hints_prefix = "<- ",
              other_hints_prefix = "=> ",
              },
            },

          -- all the opts to send to nvim-lspconfig
          -- these override the defaults set by rust-tools.nvim
          -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
          -- https://rust-analyzer.github.io/manual.html#features
          server = {
            on_attach = function(_, bufnr)
              shared_on_attach(_, bufnr)
              -- Hover actions
              vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
              -- Code action groups
              vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
              vim.keymap.set('n', '<leader>rr', "<Cmd>RustRunnables<CR>", bufopts)
            end,
            settings = {
              ["rust-analyzer"] = {
                assist = {
                  importEnforceGranularity = true,
                  importPrefix = "crate"
                  },
                cargo = {
                  allFeatures = true
                  },
                checkOnSave = {
                  -- default: `cargo check`
                  command = "clippy"
                  },
                },
                inlayHints = {
                  lifetimeElisionHints = {
                    enable = true,
                    useParameterNames = true
                  },
                },
              }
            },
        })

        -- NOTE: When using :LspInstallInfo to install available LSPs, we need to still
        -- add calls to their setup here in our Vim configuration.

        lspcfg.quick_lint_js.setup{}
        lspcfg.terraformls.setup({
          filetypes = { "terraform", "terraform-vars", "hcl" },
          on_attach = function(client, bufnr)
            shared_on_attach(client, bufnr)
          end,
        })
        lspcfg.tflint.setup{}
        lspcfg.tsserver.setup{}
        lspcfg.java_language_server.setup{
            on_attach = function(client, bufnr)
                shared_on_attach(client, bufnr)
            end,
            cmd = {"java-language-server"}
        }

        -- Styling
        -- https://github.com/folke/dot/blob/6e89c6cf2ad92a8b0335ab69d51fc275f78dd524/config/nvim/lua/config/lsp/diagnostics.lua
        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
          underline = true,
          update_in_insert = false,
          virtual_text = { spacing = 2, prefix = "●" },
          severity_sort = true,
        })
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

        for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
    end,
}
