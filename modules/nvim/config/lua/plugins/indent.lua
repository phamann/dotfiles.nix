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
            -- char = "┆",
            -- context_char = "│",
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

-- return {
--     "lukas-reineke/indent-blankline.nvim",
--     lazy = true,
--     init = function()
--         vim.opt.list = true
--         vim.opt.listchars:append("space:⋅")
--     end,
--     opts = {
--         char = "┆",
--         context_char = "│",
--         use_treesitter = true,
--         space_char_blankline = " ",
--         show_current_context = true,
--         show_current_context_start = false,
--         show_trailing_blankline_indent = false,
--         char_highlight_list = {
--             "IndentBlanklineIndent1",
--         },
--         context_highlight_list = {
--             "IndentBlanklineIndent2",
--         },
--         use_treesitter_scope = true,
--         show_first_indent_level = false,
--     }
-- }
