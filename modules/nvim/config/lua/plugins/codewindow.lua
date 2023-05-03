return {
    "gorbit99/codewindow.nvim",
    event = "VeryLazy", -- not needed for initial UI so load very lazily
    config = function()
        local codewindow = require("codewindow")
        codewindow.setup({
            exclude_filetypes = {'alpha', 'aerial', 'Trouble', 'packer', 'neorg', 'norg', 'Telescope', 'NvimTree'},
        })
        codewindow.apply_default_keybinds()
    end,
}
