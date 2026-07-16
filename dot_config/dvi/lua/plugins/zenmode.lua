-- Focus mode / centering: an on-demand, distraction-free centered view built on
-- zen-mode's floating window (no split padding windows, so :q stays sane).
-- Toggled with <leader>z.
return {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  opts = {
    window = {
      width = 90,
      height = 1,
      options = {
        signcolumn = "no",
        number = false,
        relativenumber = false,
        cursorline = false,
        cursorcolumn = false,
        foldcolumn = "0",
        list = false,
      },
    },
    plugins = {
      options = { laststatus = 0 }, -- hide the statusline while focused
      twilight = { enabled = false },
    },
    on_open = function()
      pcall(vim.cmd, "Neotree close") -- a float can't sit beside the tree
    end,
  },
}
