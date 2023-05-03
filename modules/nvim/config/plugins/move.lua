return {
    "fedepujol/move.nvim",
    keys = {
        { '<A-j>', ":MoveLine(1)<CR>",  noremap = true, silent = true },
        { '<A-k>', ":MoveLine(-1)<CR>", noremap = true, silent = true },
        { '<A-j>', ":MoveBlock(1)<CR>", mode = 'v', noremap = true, silent = true },
        { '<A-k>', ":MoveBlock(-1)<CR>", mode = 'v', noremap = true, silent = true },
        { '<A-l>', ":MoveHChar(1)<CR>", noremap = true, silent = true },
        { '<A-h>', ":MoveHChar(-1)<CR>", noremap = true, silent = true },
        { '<A-l>', ":MoveHBlock(1)<CR>", mode = 'v', noremap = true, silent = true },
        { '<A-h>', ":MoveHBlock(-1)<CR>", mode = 'v', noremap = true, silent = true },
    },
}
