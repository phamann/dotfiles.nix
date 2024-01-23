return {
    "rebelot/kanagawa.nvim",
    enabled = (vim.g.active_color_scheme == "kanagawa" and true or false),
    name = "kanagawa",
    lazy = false, -- make sure we load this during startup
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        require("kanagawa").setup({
            compile = false, -- enable compiling the colorscheme
            undercurl = true, -- enable undercurls
            commentStyle = {italic = true},
            functionStyle = {},
            keywordStyle = {italic = true},
            statementStyle = {bold = true},
            typeStyle = {},
            transparent = false, -- do not set background color
            dimInactive = true, -- dim inactive window `:h hl-NormalNC`
            terminalColors = true, -- define vim.g.terminal_color_{0,17}
            --[[ overrides = function(colors)
                local theme = colors.theme
                return {
                    NormalFloat = {bg = "none"},
                    FloatBorder = {bg = "none"},
                    FloatTitle = {bg = "none"},

                    -- Save an hlgroup with dark background and dimmed foreground
                    -- so that you can use it where your still want darker windows.
                    -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
                    NormalDark = {fg = theme.ui.fg_dim, bg = theme.ui.bg_m3},

                    -- Popular plugins that open floats will link to NormalFloat by default;
                    -- set their background accordingly if you wish to keep them dark and borderless
                    LazyNormal = {bg = theme.ui.bg_m3, fg = theme.ui.fg_dim},
                    MasonNormal = {bg = theme.ui.bg_m3, fg = theme.ui.fg_dim}
                }
            end, ]]
            theme = "wave", -- Load "wave" theme when 'background' option is not set
            background = { -- map the value of 'background' option to a theme
                dark = "wave", -- try "wave" !
                light = "wave"
            }
        })
        -- load the colorscheme here
        vim.cmd("colorscheme kanagawa-wave")
    end
}
