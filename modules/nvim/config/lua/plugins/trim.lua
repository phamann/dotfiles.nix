return {
    "cappyzawa/trim.nvim",
    opts = {
        -- if you want to ignore markdown file.
        -- you can specify filetypes.
        ft_blocklist = {"markdown"},

        -- if you want to ignore space of top
        patterns = {
            [[%s/\s\+$//e]],
            [[%s/\($\n\s*\)\+\%$//]],
            [[%s/\(\n\n\)\n\+/\1/]],
        },
    },
}
