return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {"nvim-telescope/telescope-fzf-native.nvim", build = "make"},
        "kyoh86/telescope-windows.nvim", "crispgm/telescope-heading.nvim",
        "xiyaowong/telescope-emoji.nvim", "axkirillov/telescope-changed-files"
    },
    config = function()
        local actions = require("telescope.actions")
        require("telescope").setup({
            defaults = {
                mappings = {
                    i = {
                        ["<esc>"] = actions.close,
                        ["<C-o>"] = actions.send_selected_to_qflist
                    }
                },
                file_ignore_patterns = {
                    "node%_modules/.*", "target/.*", ".git/.*", ".terraform/.*"
                },
                layout_config = {preview_width = 0.6},
                path_display = {"smart"},
                vimgrep_arguments = {
                    "rg", "--color=never", "--no-heading", "--with-filename",
                    "--line-number", "--column", "--smart-case", "--trim"
                }
            },
            pickers = {find_files = {}},
            extensions = {heading = {treesitter = true}}
        })

        require('telescope').load_extension("fzf")
        require('telescope').load_extension("heading")
        require('telescope').load_extension("emoji")
        require('telescope').load_extension("windows")
        require('telescope').load_extension("changed_files")

        vim.g.telescope_changed_files_base_branch = "main"

        -- Telescope styling — recessed popup with invisible borders and a
        -- distinct prompt surface, accent-coloured titles. Palette-driven
        -- via vim.g.stylix_palette so it follows scheme changes.
        local function apply_hl()
            local p = vim.g.stylix_palette
            local set = vim.api.nvim_set_hl
            -- Popup body: mantle bg (recessed from editor), default text fg.
            set(0, "TelescopeNormal",        { fg = p.base05, bg = p.base01 })
            -- Borders match their pane bg so the popup reads as borderless.
            set(0, "TelescopeBorder",        { fg = p.base01, bg = p.base01 })
            set(0, "TelescopePromptBorder",  { fg = p.base02, bg = p.base02 })
            -- Prompt input has its own slightly-lighter surface for contrast.
            set(0, "TelescopePromptNormal",  { fg = p.base05, bg = p.base02 })
            -- Titles in accent (orange/peach) — picks the eye for "what am I searching?".
            set(0, "TelescopePromptTitle",   { fg = p.base09, bg = p.base02 })
            set(0, "TelescopePreviewTitle",  { fg = p.base09, bg = p.base01 })
            set(0, "TelescopeResultsTitle",  { fg = p.base09, bg = p.base01 })
            -- Selected row + matched substring in fuzzy results.
            set(0, "TelescopeSelection",     { fg = p.base05, bg = p.base02, bold = true })
            set(0, "TelescopeMatching",      { fg = p.base09, bold = true })
        end
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("TelescopeHighlights", { clear = true }),
            callback = apply_hl,
        })
        vim.schedule(apply_hl)
    end,
    keys = {
        {
            "<leader>f",
            "<Cmd>Telescope find_files hidden=true<CR>",
            desc = "search files"
        },
        {
            "<C-p>",
            "<Cmd>Telescope find_files hidden=true<CR>",
            desc = "search files"
        }, {"<leader>t", "<Cmd>Telescope live_grep<CR>", desc = "search text"},
        {"<leader>b", "<Cmd>Telescope buffers<CR>", desc = "search buffers"},
        {"<leader>l", "<Cmd>Telescope buffers<CR>", desc = "search buffers"},
        {"<leader>h", "<Cmd>Telescope help_tags<CR>", desc = "search help"},
        {
            "<leader>c",
            "<Cmd>Telescope colorscheme<CR>",
            desc = "search colorschemes"
        },
        {
            "<leader>q",
            "<Cmd>Telescope quickfix<CR>",
            desc = "search quickfix list"
        }, {
            "<leader>r",
            "<Cmd>Telescope current_buffer_fuzzy_find<CR>",
            desc = "search current buffer text"
        }, {
            "<leader>tr",
            "<Cmd>Telescope lsp_references<CR>",
            desc = "search code reference"
        }, {
            "<leader>ts",
            "<Cmd>Telescope lsp_document_symbols<CR>",
            desc = "search document symbol tree"
        }, {
            "<leader>ss",
            "Telescope lsp_workspace_symbols",
            desc = "search workspace symbol tree"
        },{
            "<leader>m",
            "<Cmd>Telescope heading<CR>",
            desc = "search markdown headings"
        }, {"<leader>e", "<Cmd>Telescope emoji<CR>", desc = "search emojis"},
        {"<leader>w", "<Cmd>Telescope windows<CR>", desc = "search windows"}, {
            "<leader>g",
            "<Cmd>Telescope changed_files<CR>",
            desc = "search changed files"
        }, {
            "<leader>gc",
            "<Cmd>Telescope changed_files choose_base_branch<CR>",
            desc = "search changed files and choose branch"
        }
    }
}
