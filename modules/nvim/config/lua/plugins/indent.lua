return {
    "lukas-reineke/indent-blankline.nvim",
    -- lazy = true,
    main = "ibl",
    init = function()
        -- vim.opt.list = true
        -- vim.opt.listchars:append("space:⋅")
    end,
    config = function()
        require("ibl").setup({
            indent = {
                char = "┆",
            },
            scope = {
                enabled = true,
                show_start = false,
                char = "│",
            },
        })
    end
}
