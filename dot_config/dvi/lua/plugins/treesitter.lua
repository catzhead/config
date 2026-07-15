return {
  "nvim-treesitter/nvim-treesitter",
  -- Pin the classic branch: our config uses the master-branch API
  -- (nvim-treesitter.configs / install.update). The default now drifts to the
  -- rewritten `main` branch on fresh installs, whose build step is incompatible.
  branch = "master",
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
