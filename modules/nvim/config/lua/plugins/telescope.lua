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
            desc = "search document tree"
        },
        {
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
