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
                            filetype = {'neo-tree', "neo-tree-popup", "notify"},
                            buftype = {'terminal', "quickfix"}
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
            popup_border_style = "rounded",
            enable_git_status = true,
            enable_diagnostics = true,

            default_component_configs = {
                name = {use_git_status_colors = true},
                git_status = {
                    symbols = {
                        -- Change type
                        added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
                        modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
                        deleted = "✖", -- this can only be used in the git_status source
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
                        config = {use_float = true, use_image_nvim = false}
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
                follow_current_file = {enabled = true, leave_dirs_open = true}
            },
            sources = {
                "filesystem", "buffers", "git_status", "document_symbols"
            },
            source_selector = {winbar = true, statusline = false}
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
--[[
return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()
        require("nvim-tree").setup({
            view = {
                relativenumber = false,
                width = 30,
                signcolumn = "yes",
                number = false
            },
            reload_on_bufenter = false,
            update_focused_file = {enable = true},
            diagnostics = {
                enable = true,
                icons = {
                    error = "",
                    warning = "",
                    hint = "",
                    info = ""
                }
            },
            -- open_on_setup_file = true,
            git = {enable = true},
            renderer = {
                highlight_opened_files = "all",
                icons = {
                    padding = " ",
                    git_placement = "after",
                    glyphs = {
                        default = '',
                        symlink = '',
                        git = {
                            deleted = '',
                            ignored = '◌',
                            renamed = '➜',
                            staged = '+',
                            unmerged = '',
                            unstaged = 'ϟ',
                            untracked = '?'
                        }
                    }
                }
            },
            actions = {open_file = {quit_on_open = true}},
            source_selector = {winbar = true}
        })
    end,
    keys = {{"<leader>;", "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree"}}
} ]]
