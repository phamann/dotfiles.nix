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
-- Treesitter/LSP captures are otherwise tinted-vim's responsibility — the
-- ONE deliberate exception is the data-language overrides below.
-- Blend two "#rrggbb" strings by a factor t (0 = a, 1 = b), returning
-- "#rrggbb". Used to synthesize colours the 24-slot palette doesn't expose
-- by interpolating between the slots that bracket them.
local function blend(a, b, t)
    local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
    local ar, ag, ab = rgb(a)
    local br, bg, bb = rgb(b)
    return string.format("#%02x%02x%02x",
        math.floor(ar + (br - ar) * t + 0.5),
        math.floor(ag + (bg - ag) * t + 0.5),
        math.floor(ab + (bb - ab) * t + 0.5))
end

-- WCAG relative luminance of a "#rrggbb" string.
local function luminance(h)
    local function chan(i)
        local c = tonumber(h:sub(i, i + 1), 16) / 255
        return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
    end
    return 0.2126 * chan(2) + 0.7152 * chan(4) + 0.0722 * chan(6)
end

-- WCAG contrast ratio between two "#rrggbb" strings. Used to decide whether
-- a scheme slot needs correcting, rather than correcting it unconditionally.
local function contrast_ratio(a, b)
    local la, lb = luminance(a), luminance(b)
    if la < lb then
        la, lb = lb, la
    end
    return (la + 0.05) / (lb + 0.05)
end

local function apply_ui_hl()
    local p = vim.g.stylix_palette
    local set = vim.api.nvim_set_hl

    -- Comments: tinted-vim links @comment → Comment → base03, and whether
    -- that needs lifting is a property of the SCHEME, not of this config.
    -- Low-contrast schemes park base03 barely off the editor background —
    -- catppuccin-frappe 1.7:1, ayu-mirage 1.9:1 — so comments all but
    -- vanish. Catppuccin's own theme uses overlay2 (#949cbb) there, which
    -- the base24 palette exposes in no slot: base03 (surface1) is too dark
    -- and base04 (surface2) still a touch dim, but overlay2 sits between
    -- base04 and base05 (text), so a 50/50 blend synthesizes it.
    --
    -- Applying that blend unconditionally is wrong, though: schemes that
    -- place base03 deliberately (signal-mirage 3.0:1, github-dark-dimmed
    -- 3.6:1) would be dragged to ~8.5:1 — comments shouting louder than the
    -- code they annotate, the same failure that makes cerulean-signal-dark
    -- tiring to read. So lift base03 only when it actually falls short of
    -- the ~3:1 that reads as recessive-but-legible, and otherwise trust the
    -- scheme. Palette-driven either way, so it tracks scheme changes (and
    -- inverts correctly on light schemes) instead of freezing at a
    -- mocha-specific literal.
    --
    -- This is a global fix (not the per-language `.<lang>` variant) because
    -- the darkness is a property of the @comment → Comment link, not of any
    -- one filetype — Go, YAML, everything shares it. Override both Comment
    -- (non-treesitter buffers, diff/git comments) and @comment (the
    -- treesitter capture tinted-vim sets explicitly, so linking through
    -- Comment alone wouldn't win). The more specific @comment.todo/.error/
    -- .warning captures are untouched. Italic matches catppuccin's style.
    local comment_fg = p.base03
    if contrast_ratio(p.base03, p.base00) < 2.6 then
        comment_fg = blend(p.base04, p.base05, 0.5)
    end
    set(0, "Comment",  { fg = comment_fg, italic = true })
    set(0, "@comment", { fg = comment_fg, italic = true })

    -- Data-language keys (YAML/JSON/TOML mapping keys) are captured as
    -- @property, which tinted-vim links @property → @variable.member →
    -- base04 — a muted grey meant for recessed member access (`foo.bar`).
    -- In data files the key IS the content, so base04 renders it grey-on-
    -- background (base00), nearly invisible in low-contrast schemes like
    -- catppuccin-frappe. Promote it to base07 to match what catppuccin's
    -- own theme does (lavender). The `.<lang>` suffix wins over the generic
    -- @property link without touching struct member access in real code.
    for _, lang in ipairs({ "yaml", "json", "toml" }) do
        set(0, "@property." .. lang,        { fg = p.base07 })
        set(0, "@field." .. lang,           { fg = p.base07 })
        set(0, "@variable.member." .. lang, { fg = p.base07 })
    end

    -- Go struct fields are too recessed in real code. Go's grammar captures
    -- `field_identifier` as @property for BOTH struct field declarations
    -- (`type Foo struct { Name string }`) and field access (`foo.Name`), and
    -- captures struct-literal keys (`Foo{Name: ...}`) as @variable.member.
    -- Both links resolve to base04 (surface2) — the recessed-member grey that
    -- suits `foo.bar` chains but leaves field-heavy Go structs washed out.
    -- Promote to base05 (text): normal identifier brightness, which is also
    -- how catppuccin's own theme renders fields (no special hue). Scoped to
    -- `.go` so member access in other languages keeps tinted-vim's recessed
    -- default.
    set(0, "@property.go",        { fg = p.base05 })
    set(0, "@variable.member.go", { fg = p.base05 })

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
    -- Open / modified files in the file tree pop in the accent colour so
    -- you can scan the panel and see "what am I currently editing."
    set(0, "NeoTreeFileNameOpened",       { fg = p.base09 })
    set(0, "NeoTreeModified",             { fg = p.base09 })
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
