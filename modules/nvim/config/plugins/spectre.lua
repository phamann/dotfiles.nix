return { 
    "nvim-pack/nvim-spectre", 
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
      replace_engine={
        ["sed"]={
            cmd = "gsed",
        },
      },
    },
    keys = {
        { "<leader>S", "<Cmd>lua require('spectre').open()<CR>", desc = "search and replace" }
    },
}
