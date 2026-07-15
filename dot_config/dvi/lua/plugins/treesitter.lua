return {
  "nvim-treesitter/nvim-treesitter",
  build = function()
    require("nvim-treesitter.install").update({ with_sync = true })()
  end,
  config = function()
    -- classic (master-branch) API; ensure the markdown parsers render-markdown needs
    local ok, configs = pcall(require, "nvim-treesitter.configs")
    if ok then
      configs.setup({
        ensure_installed = { "markdown", "markdown_inline" },
        highlight = { enable = true },
      })
    end
  end,
}
