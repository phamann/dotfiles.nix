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

-- UI overrides for groups tinted-vim doesn't opinionate on. All overrides
-- reference the active scheme's palette via vim.g.stylix_palette (templated
-- by nix), so they follow scheme changes through `modules.theme.scheme`.
-- Treesitter/LSP captures are tinted-vim's responsibility — nothing here
-- touches @variable, @function, @punctuation, etc.
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
end
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("UIHighlights", { clear = true }),
    callback = apply_ui_hl,
})
-- ColorScheme fires when init.lua calls `vim.cmd.colorscheme(...)` at the
-- end, so apply_ui_hl runs after tinted-vim has set its highlights. The
-- vim.schedule fallback is belt-and-braces for edge cases (e.g. live
-- re-source via the BufWritePost autocmd above).
vim.schedule(apply_ui_hl)
