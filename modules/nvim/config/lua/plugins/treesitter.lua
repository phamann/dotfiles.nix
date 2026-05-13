return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup()

        vim.api.nvim_create_autocmd("FileType", {
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })

        local parsers = {
            "bash", "c", "cmake", "css", "cue", "dockerfile", "glimmer",
            "go", "gomod", "gowork", "hcl", "html", "http", "java",
            "javascript", "json", "jsonnet", "kdl", "lua", "make", "markdown",
            "markdown_inline", "python", "regex", "rego", "ruby", "rust",
            "terraform", "toml", "vim", "yaml", "zig", "nix"
        }
        vim.api.nvim_create_autocmd("VimEnter", {
            once = true,
            callback = function()
                require("nvim-treesitter").install(parsers)
            end,
        })
    end
}
