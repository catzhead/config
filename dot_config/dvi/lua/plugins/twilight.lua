return {
  "folke/twilight.nvim",
  cmd = "Twilight",
  opts = {
    dimming = {
      alpha = 0.25,
      color = { "Normal", "#ffffff" },
      inactive = true,
    },
    treesitter = true,
    expand = { "function", "method", "table", "if_statement" },
    exclude = {},
  },
}
