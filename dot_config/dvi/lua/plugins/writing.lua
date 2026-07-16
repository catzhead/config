-- The writing surface: in-buffer markdown rendering that stays visible while you
-- edit. (Centering is on-demand via zen-mode / <leader>z, not a permanent split.)
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "markdown" },
    opts = {},
  },
}
