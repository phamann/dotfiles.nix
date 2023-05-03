return {
    "b3nj5m1n/kommentary",
    config = function()
        require("kommentary.config").configure_language("rust", {
            single_line_comment_string = "//",
            multi_line_comment_strings = {"/*", "*/"},
        })
    end,
    keys = {
        { "gcc", "<Plug>kommentary_line_default", },
        { "gc", "<Plug>kommentary_motion_default", },
        { "gc", "<Plug>kommentary_visual_default<C-c>", mode = "v", } ,
    },
}
