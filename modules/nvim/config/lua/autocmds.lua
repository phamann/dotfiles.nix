vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {
    "*.lua"
  },
  command = [[source ~/.config/nvim/init.lua]]
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "sh", "go", "rust"
  },
  command = [[setlocal textwidth=80]]
})

--[[ -- Set the colorcolumn highlight on BufWinEnter
vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = {
        "*"
    },
    command = [[highlight ColorColumn ctermbg=237]]
-- }) ]]

-- Automatically close nvim if NvimTree is last buffer open
vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil then
      vim.cmd "quit"
    end
  end
})

-- Set custom filetype mappings
vim.filetype.add({
    filename = {
        ["api.vcl.tftpl"] = "vcl",
    },
})

-- Override stock UI groups that base16-nvim leaves at unstyled defaults
-- or maps to a too-low-contrast slot. All overrides reference the active
-- scheme's palette via vim.g.stylix_palette (templated by nix), so they
-- follow scheme changes through `modules.theme.scheme`.
local function apply_ui_hl()
    local p = vim.g.stylix_palette
    local set = vim.api.nvim_set_hl

    -- Subtle but visible separator between split panes.
    set(0, "WinSeparator",  { fg = p.base03 })

    -- "Chromeless" status line / winbar — bg matches editor body so the
    -- bars don't draw attention to themselves; barbecue/lualine handle
    -- their own bg painting through their plugin specs.
    set(0, "StatusLine",    { link = "Normal" })
    set(0, "StatusLineNC",  { fg = p.base04, bg = p.base00 })
    set(0, "WinBar",        { link = "StatusLine" })
    set(0, "WinBarNC",      { link = "StatusLine" })

    -- Neo-tree source selector tabs — match lualine's bg shape so the
    -- sidebar's tabstrip aligns visually with the rest of the chrome.
    set(0, "NeoTreeTabActive",            { fg = p.base05, bg = p.base02, bold = true })
    set(0, "NeoTreeTabInactive",          { fg = p.base04, bg = p.base01 })
    set(0, "NeoTreeTabSeparatorActive",   { fg = p.base02, bg = p.base02 })
    set(0, "NeoTreeTabSeparatorInactive", { fg = p.base01, bg = p.base01 })

    -- Variable identifiers in plain text colour rather than red. base16
    -- spec puts @variable → base08 (red); base16-nvim is spec-faithful.
    -- Aesthetic deviation: keep variable mentions recessed so operations
    -- on them (function calls, member access) catch the eye. Covers both
    -- treesitter captures and LSP semantic tokens.
    set(0, "@variable",          { fg = p.base05 })
    set(0, "@variable.builtin",  { fg = p.base05, italic = true })
    set(0, "@lsp.type.variable", { fg = p.base05 })

    -- Punctuation (. , ; ${} etc) in text colour. base16-nvim maps
    -- @punctuation.{delimiter,special} → base0F (spec's "Deprecated /
    -- Embedded Language Tags" slot — typically a deep red/brown), which
    -- visually fights with the actual content. Most aesthetic themes
    -- send punctuation to base05; brackets already land there in
    -- base16-nvim's own mapping, so this just makes the family uniform.
    set(0, "@punctuation.delimiter", { fg = p.base05 })
    set(0, "@punctuation.special",   { fg = p.base05 })
end
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("UIHighlights", { clear = true }),
    callback = apply_ui_hl,
})
-- base16-nvim's setup() doesn't fire ColorScheme — defer one-shot apply
-- until after init.lua (and Stylix's appended setup) finishes.
vim.schedule(apply_ui_hl)
