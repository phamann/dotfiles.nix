return { 
    "sindrets/diffview.nvim",
    config = true,
    event = "VeryLazy", -- not needed for initial UI so load very lazily
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader><leader>dh", "<cmd>DiffViewFileHistory<cr>", desc = "diff history" },
      { "<leader><leader>do", "<cmd>DiffViewOpen<cr>", desc = "diff open" },
      { "<leader><leader>dc", "<cmd>DiffViewClose<cr>", desc = "diff clode" },
    },
}
