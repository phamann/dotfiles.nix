return {
    "weilbith/nvim-code-action-menu",
    event = "InsertEnter", -- lazy load on InsertEnter
    config = function()
        vim.g.code_action_menu_window_border = "single"
    end,
    keys = {
      { "<leader>ga", "<cmd>CodeActionMenu<cr>", desc = "code action menu", noremap = true },
    },
}   
