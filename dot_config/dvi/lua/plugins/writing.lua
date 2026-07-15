-- The writing surface: an always-on centered soft-wrap column, and in-buffer
-- markdown rendering that stays visible while you edit.
return {
  {
    "shortcuts/no-neck-pain.nvim",
    cmd = "NoNeckPain",
    opts = { width = 90 }, -- defaults already set wrap + linebreak on the side buffers
    config = function(_, opts)
      require("no-neck-pain").setup(opts)
      -- auto-center the first markdown buffer; the flag prevents re-toggling
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          if not vim.g.__nnp_on and not vim.g.__nnp_zen then
            vim.g.__nnp_on = true
            pcall(vim.cmd, "NoNeckPain")
          end
        end,
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "markdown" },
    opts = {},
  },
}
