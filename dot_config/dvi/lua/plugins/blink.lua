return {
  "saghen/blink.cmp",
  dependencies = { "rafamadriz/friendly-snippets" },
  version = "1.*",
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = false },
      -- prose: don't pop the menu on every word. Only show it on a trigger
      -- character (e.g. '[' for [[wiki links]]); <C-space> still triggers manually.
      trigger = { show_on_keyword = false, show_on_trigger_character = true },
    },
    -- obsidian provides '[[' completion via its built-in LSP (obsidian-ls), so
    -- keep the lsp source enabled to surface link completions
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
