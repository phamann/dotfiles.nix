return {
    "petertriho/nvim-scrollbar",
    event = "BufReadPost",
    config = function()
        local scrollbar = require("scrollbar")
        local colors = require('github-theme.lib.color')
        -- local colors = require(vim.g.active_color_scheme .. ".colors").setup()
        scrollbar.setup({
            handle = {color = colors.bg_highlight},
            excluded_filetypes = {
                "prompt", "TelescopePrompt", "noice", "notify", "NvimTree",
                "NeoTree"
            },
            marks = {
                Search = {color = colors.orange},
                Error = {color = colors.error},
                Warn = {color = colors.warning},
                Info = {color = colors.info},
                Hint = {color = colors.hint},
                Misc = {color = colors.purple}
            }
        })
    end
}
