-- Cross-references: [[wiki links]], follow-link, link/backlink pickers.
-- Using the maintained fork. The critical guarantee: the numeric ordering prefix
-- never appears in a link. A sheet carries a stable frontmatter `id` (== slug),
-- which obsidian reads as the note's identity (see note.lua: id comes from
-- frontmatter, not the filename). We also strip the prefix when *writing* links,
-- so both ends are prefix-free and renumbering a sheet never breaks a link.
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    legacy_commands = false,
    workspaces = {
      { name = "workspace", path = vim.fn.getcwd() },
    },
    -- dvi writes sheet frontmatter itself (config.order); don't let obsidian
    -- rewrite it (which could derive an id from the prefixed filename).
    frontmatter = { enabled = false },
    picker = { name = "telescope.nvim" },
    -- new notes created *through obsidian* get a prefix-free slug id
    note_id_func = function(title)
      local base = title or ""
      return (base:lower():gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", ""))
    end,
    link = {
      -- emit [[id]] / [[id|alias]] using the stable, prefix-free identity
      style = function(opts)
        local stem = tostring(opts.path or ""):gsub("%.md$", "")
        stem = stem:gsub("^.*/", ""):gsub("^%d+%-", "") -- drop dir + numeric prefix
        local label = tostring(opts.label or "")
        if label ~= "" and label ~= stem then
          return string.format("[[%s|%s]]", stem, label)
        end
        return string.format("[[%s]]", stem)
      end,
    },
  },
}
