return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim", -- required
        "nvim-telescope/telescope.nvim", -- optional
        "sindrets/diffview.nvim", -- optional
        "nvim-telescope/telescope.nvim" -- optional
    },
    config = function() require("neogit").setup {} end
}
