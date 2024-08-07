return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
        -- { "lewis6991/spellsitter.nvim", config = true },
    },
    config = function()
        local treesitter = require("nvim-treesitter.configs")
        treesitter.setup({
            auto_install = false,
            ensure_installed = {
                "bash", "c", "cmake", "css", "cue", "dockerfile", "glimmer",
                "go", "gomod", "gowork", "hcl", "html", "http", "java",
                "javascript", "json", "kdl", "lua", "make", "markdown", "markdown_inline",
                "python", "regex", "rego", "ruby", "rust", "terraform", "toml",
                "vim", "yaml", "zig", "nix"
            },
            highlight = {enable = true},
            rainbow = {
                enable = true,
                extended_mode = true,
                max_file_lines = nil
            }
        })
    end
}
