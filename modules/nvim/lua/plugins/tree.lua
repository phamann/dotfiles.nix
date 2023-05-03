return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("nvim-tree").setup({
            view = {
                relativenumber = false,
                width = 30,
                signcolumn = "yes",
                number = false,
            },
            reload_on_bufenter = false,
            update_focused_file = {
                enable = true,
            },
            diagnostics = {
                enable = true,
                icons = {
                  error = "",
                  warning = "",
                  hint = "",
                  info = "",
              },
            },
            -- open_on_setup_file = true,
            git = {
                enable = true,
            },
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
                            untracked = '?',
                        },
                    },
                },
            },
            actions = {
                open_file = {
                    quit_on_open = true
                }
            }
        })
    end,
    keys = {
        { "<leader>;", "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree" },
    },
}
