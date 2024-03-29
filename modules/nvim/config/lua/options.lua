--[[option
To see what an option is set to execute :lua = vim.o.<name>
NOTE: .. is equivalent to += in vimscript
--]] vim.g.mapleader = "'"

vim.o.backup = false
vim.o.clipboard = "unnamed"
vim.o.cursorline = true
vim.o.dictionary = "/usr/share/dict/words"
vim.o.expandtab = true
vim.o.expandtab = true
vim.o.grepprg = "rg --vimgrep"
vim.o.ignorecase = true
vim.o.inccommand = "split"
vim.o.lazyredraw = false
vim.o.number = true
vim.o.scrolloff = 5
vim.o.shiftwidth = 4
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.showcmd = true
vim.o.showmatch = true
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.spell = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.wrap = false
vim.o.mouse = "a"
vim.o.showtabline = 0
vim.o.signcolumn = 'yes' -- always draw sign column
vim.wo.colorcolumn = "80"
vim.wo.relativenumber = true

if vim.fn.has("termguicolors") == 1 then vim.o.termguicolors = true end
