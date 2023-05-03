return {
    "folke/trouble.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        {  "<leader>dc", "<Cmd>TroubleClose<CR>", noremap=true, silent=true, buffer=bufnr },
        {  "<leader>di", "<Cmd>TroubleToggle document_diagnostics<CR>", noremap=true, silent=true, buffer=bufnr },
        {  "<leader>dw", "<Cmd>TroubleToggle workspace_diagnostics<CR>", noremap=true, silent=true, buffer=bufnr },
        {  "<leader>dr", "<Cmd>TroubleToggle lsp_references<CR>", noremap=true, silent=true, buffer=bufnr },
        {  "<leader>dq", "<Cmd>TroubleToggle quickfix<CR>", noremap=true, silent=true, buffer=bufnr },
        {  "<leader>dl", "<Cmd>TroubleToggle loclist<CR>", noremap=true, silent=true, buffer=bufnr },
    },
}
