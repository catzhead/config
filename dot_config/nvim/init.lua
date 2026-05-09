-- mapleader need to be set before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true

vim.opt.number = true -- line numbers
vim.opt.mouse = 'a'
vim.opt.showmode = false -- don't show the mode because it's in the status line
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true -- show which line you're on
vim.opt.scrolloff = 10 -- min number of screen lines to keep above
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.wildmode = 'longest,list'
vim.opt.colorcolumn = "80"
vim.cmd [[highlight ColorColumn ctermbg=lightgrey guibg=lightgrey]]

-- Python - 4 space indent, no tabs
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true
  end
})

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- Clear highlights with Esc
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

require("config.lazy")

vim.cmd[[colorscheme catppuccin-macchiato]]
