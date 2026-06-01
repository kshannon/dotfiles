-- Minimal neovim config

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs/indent
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- UI
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

-- Clipboard (use system clipboard)
vim.opt.clipboard = "unnamedplus"

-- No swap files
vim.opt.swapfile = false
