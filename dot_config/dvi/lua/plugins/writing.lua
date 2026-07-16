-- The writing surface: in-buffer markdown rendering that stays visible while you
-- edit. (Centering is on-demand via zen-mode / <leader>z, not a permanent split.)
return {
  {
    -- Uses Neovim's built-in treesitter + bundled markdown parsers (no
    -- nvim-treesitter dependency).
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    opts = {},
  },
}
