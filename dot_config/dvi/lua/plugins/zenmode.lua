-- Focus mode: hide everything but the writing buffer. Seeded from the main
-- config's zen-mode settings, plus a handshake with the library and no-neck-pain
-- so they don't fight over the window layout.
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
      options = { laststatus = 0 }, -- hide the statusline in focus mode
      twilight = { enabled = false },
    },
    on_open = function()
      pcall(vim.cmd, "Neotree close")
      if vim.g.__nnp_on then
        pcall(vim.cmd, "NoNeckPain")
        vim.g.__nnp_on = false
        vim.g.__nnp_zen = true
      end
    end,
    on_close = function()
      if vim.g.__nnp_zen then
        pcall(vim.cmd, "NoNeckPain")
        vim.g.__nnp_on = true
        vim.g.__nnp_zen = false
      end
    end,
  },
}
