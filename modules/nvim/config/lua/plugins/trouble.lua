return {
    "folke/trouble.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    cmd = "Trouble",
    opts = {},
    keys = {
        {  "<leader>dc", "<Cmd>TroubleClose<CR>", noremap=true, silent=true, buffer=bufnr },
        {  "<leader>di", "<cmd>Trouble diagnostics toggle<cr>", noremap=true, silent=true, buffer=bufnr },
        {  "<leader>dw", "<Cmd>TroubleToggle workspace_diagnostics<CR>", noremap=true, silent=true, buffer=bufnr },
        {  "<leader>dr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", noremap=true, silent=true, buffer=bufnr },
        {  "<leader>dq", "<Cmd>TroubleToggle quickfix<CR>", noremap=true, silent=true, buffer=bufnr },
        {  "<leader>dl", "<Cmd>TroubleToggle loclist<CR>", noremap=true, silent=true, buffer=bufnr },
    },
}
