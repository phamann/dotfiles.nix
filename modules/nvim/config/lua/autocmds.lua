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

---Linear blend between two #rrggbb hex strings. alpha=0 → c1, alpha=1 → c2.
---Used to derive intermediate greys when the palette doesn't expose one
---(e.g. a readable comment colour between base04 and base05).
local function blend_hex(c1, c2, alpha)
    local function part(s, i) return tonumber(s:sub(i, i + 1), 16) end
    local r = math.floor((1 - alpha) * part(c1, 2) + alpha * part(c2, 2))
    local g = math.floor((1 - alpha) * part(c1, 4) + alpha * part(c2, 4))
    local b = math.floor((1 - alpha) * part(c1, 6) + alpha * part(c2, 6))
    return string.format("#%02x%02x%02x", r, g, b)
end

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

    -- Comments need to be readable. base04 (surface2) has poor contrast
    -- against base00; blend toward base05 (text) for a brighter muted
    -- tone that still reads as a comment in any base24 scheme. Treesitter
    -- defines @comment separately and takes priority in TS-enabled
    -- buffers, so override that too.
    local comment_fg = blend_hex(p.base04, p.base05, 0.45)
    set(0, "Comment",  { fg = comment_fg, italic = true })
    set(0, "@comment", { fg = comment_fg, italic = true })

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
-- base16-nvim's setup() doesn't fire ColorScheme — defer one-shot apply
-- until after init.lua (and Stylix's appended setup) finishes.
vim.schedule(apply_ui_hl)
