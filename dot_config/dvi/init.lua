-- dvi — "demake vi": an isolated, prose-writing neovim profile.
-- Launched via `NVIM_APPNAME=dvi nvim` (see the `dvi` shell alias). Everything
-- here lives under the dvi XDG roots (~/.config/dvi, ~/.local/share/dvi, ...),
-- so the main neovim config is never touched.

-- mapleader must be set before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true

-- Prose-friendly defaults
vim.opt.number = false        -- no line numbers while writing
vim.opt.relativenumber = false
vim.opt.mouse = "a"
vim.opt.showmode = false      -- mode is in the statusline
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = false
vim.opt.scrolloff = 8
vim.opt.wrap = true
vim.opt.linebreak = true      -- wrap at word boundaries, not mid-word
vim.opt.breakindent = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.conceallevel = 2      -- let render-markdown/obsidian conceal syntax
vim.opt.signcolumn = "yes"    -- stable gutter for gitsigns
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true -- 24-bit colour, needed for the paragraph gradient

-- Global keymaps (basic; dvi-specific maps live in config.keymaps)
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

require("config.lazy")

vim.cmd([[colorscheme catppuccin-macchiato]])

-- dvi modules: user commands, keymaps, cheat sheet
require("config.book").setup()
require("config.order").setup()
require("config.gradient").setup()
require("config.keymaps").apply()
require("config.help").setup()

-- Prose behaviour, gated to markdown buffers so the profile stays inert elsewhere
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function(ev)
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.textwidth = 0
    -- prose-aware vertical motion: move by display line
    local o = { buffer = ev.buf, silent = true }
    vim.keymap.set({ "n", "x" }, "j", "gj", o)
    vim.keymap.set({ "n", "x" }, "k", "gk", o)
    vim.keymap.set({ "n", "x" }, "<Down>", "gj", o)
    vim.keymap.set({ "n", "x" }, "<Up>", "gk", o)
  end,
})

-- In focus mode, zen-mode's float makes a bare :q merely "leave focus", so it
-- would take a second :q to quit. When a real quit is issued (:q / :wq / ZZ)
-- while focused, quit the editor instead. (<leader>z toggles zen without a
-- :quit, so it doesn't trip this.)
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    if vim.g.__dvi_zen then
      vim.schedule(function()
        pcall(vim.cmd, "quitall")
      end)
    end
  end,
})

-- On launch: open the current directory (or the given dir) as the library.
-- `dvi` -> cwd; `dvi some/dir` -> that dir; `dvi file.md` -> that file (library
-- still reachable via <leader>e).
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() > 1 then
      return
    end
    local target = vim.fn.argv(0)
    if target == nil or target == "" then
      -- no args: reveal the cwd in the library
      vim.schedule(function()
        pcall(vim.cmd, "Neotree reveal dir=" .. vim.fn.fnameescape(vim.fn.getcwd()))
      end)
    elseif vim.fn.isdirectory(target) == 1 then
      local dir = vim.fn.fnamemodify(target, ":p")
      vim.cmd("cd " .. vim.fn.fnameescape(dir))
      vim.schedule(function()
        pcall(vim.cmd, "Neotree reveal dir=" .. vim.fn.fnameescape(dir))
      end)
    end
  end,
})
