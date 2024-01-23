return {
    'projekt0n/github-nvim-theme',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    enabled = (vim.g.active_color_scheme == "github" and true or false),
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        require('github-theme').setup({
            options = {
                dim_inactive = false,
                styles = {
                    comments = 'italic',
                    keywords = 'bold',
                    types = 'italic,bold'
                },
                modules = {
                    telescope = {enable = true},
                    neotree = {enable = true},
                    cmp = {enable = true},
                    fzf = {enable = true},
                    gitsigns = {enable = true},
                    lsp_trouble = {enable = true},
                    neogit = {enable = true},
                    treesitter = {enable = true},
                    whichkey = {enable = true},
                    indent_blankline = {enable = true}
                }
                --[[ overrides = function(c)
                    local prompt = "#2d3149"
                    return {
                        TelescopeNormal = {fg = c.fg1, bg = c.bg1},
                        TelescopeBorder = {fg = c.bg1, bg = c.bg1},
                        TelescopePromptNormal = {bg = prompt},
                        TelescopePromptBorder = {bg = prompt, fg = prompt}
                    }
                end ]]
            },
            groups = {
                all = {NeoTreeTabInactive = {bg = 'palette.canvas.inset'}}
            }
        })

        -- vim.cmd('colorscheme github_dark_dimmed')
        vim.cmd('colorscheme github_dark')
    end
}
