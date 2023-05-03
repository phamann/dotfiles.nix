return {
    "mileszs/ack.vim",
    config = function()
        vim.g.ackprg = "rg --vimgrep --smart-case --hidden"
    end,
}
