return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim", {
        's1n7ax/nvim-window-picker',
        version = '2.*',
        config = function()
            require("window-picker").setup({
                hint = 'statusline-winbar',
                selection_chars = 'ABCDEFGHIJ',
                filter_rules = {
                    include_current_win = false,
                    autoselect_one = false,
                    bo = {
                        filetype = { 'neo-tree', "neo-tree-popup", "notify" },
                        buftype = { 'terminal', "quickfix" }
                    }
                }
            })
        end
    }
    },
    deactivate = function() vim.cmd([[Neotree close]]) end,
    config = function()
        require("neo-tree").setup({
            close_if_last_window = true,
            popup_border_style = "single",
            enable_git_status = true,
            enable_diagnostics = true,

            default_component_configs = {
                name = { use_git_status_colors = true },
                git_status = {
                    symbols = {
                        -- Change type
                        added = "",    -- or "✚", but this is redundant info if you use git_status_colors on the name
                        modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
                        -- deleted = "✖", -- this can only be used in the git_status source
                        renamed = '➜',
                        deleted = '',
                        -- Status type
                        untracked = '?',
                        ignored = '◌',
                        unstaged = 'ϟ',
                        staged = '+',
                        conflict = ""
                    }
                }
            },
            window = {
                mappings = {
                    ["P"] = {
                        "toggle_preview",
                        config = { use_float = true, use_image_nvim = false }
                    },
                    ["<cr>"] = "open_with_window_picker",
                    ["w"] = "open_with_window_picker"
                }
            },
            filesystem = {
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                    hide_gitignored = false
                }
            },
            buffers = {
                follow_current_file = { enabled = true, leave_dirs_open = true }
            },
            sources = { "filesystem", "git_status", "document_symbols" },
            source_selector = { winbar = true, statusline = false },
            event_handlers = {
                {
                    event = "file_opened",
                    handler = function(file_path)
                        require("neo-tree.command").execute({ action = "close" })
                    end
                }, {
                event = "neo_tree_window_after_open",
                handler = function(args)
                    if args.position == "left" or args.position == "right" then
                        vim.cmd("wincmd =")
                    end
                end
            }, {
                event = "neo_tree_window_after_close",
                handler = function(args)
                    if args.position == "left" or args.position == "right" then
                        vim.cmd("wincmd =")
                    end
                end
            }
            }
        })
    end,
    keys = {
        {
            "<leader>;",
            function()
                require("neo-tree.command").execute({
                    toggle = true,
                    reveal = true
                })
            end,
            desc = "Toggle  NeoTree"
        }
    }
}
