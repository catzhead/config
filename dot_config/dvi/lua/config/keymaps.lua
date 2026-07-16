-- Single source of truth for dvi-specific keymaps. `apply()` binds them and
-- `config.help` renders the same table into the :DviHelp cheat sheet, so the two
-- can never drift. (A small, deliberate deviation from the main config's inline
-- vim.keymap.set style, justified by the self-documenting cheat sheet.)
local M = {}

local function tb(name, opts)
  return function()
    require("telescope.builtin")[name](opts)
  end
end
local function gs(name)
  return function()
    require("gitsigns")[name]()
  end
end

-- Fields: group, lhs, rhs (fn or :cmd string), desc, mode (default "n"),
-- ft (buffer-local to that filetype), display (show in help but don't bind).
M.specs = {
  -- Navigate
  { group = "Navigate", lhs = "<leader>e", rhs = "<cmd>Neotree toggle<CR>", desc = "Toggle the library (file tree)" },
  { group = "Navigate", lhs = "<leader>o", rhs = "<cmd>Oil<CR>", desc = "Reorganize files (oil buffer)" },
  { group = "Navigate", lhs = "<leader>ff", rhs = tb("find_files"), desc = "Find a sheet" },
  { group = "Navigate", lhs = "<leader>fg", rhs = tb("live_grep"), desc = "Grep across the workspace" },
  { group = "Navigate", lhs = "<leader>fb", rhs = tb("buffers"), desc = "Open buffers" },

  -- Cross-reference
  { group = "Cross-reference", lhs = "<CR>", rhs = "<cmd>Obsidian follow_link<CR>", desc = "Follow [[link]] under cursor", ft = "markdown" },
  { group = "Cross-reference", lhs = "<leader>fs", rhs = "<cmd>Obsidian quick_switch<CR>", desc = "Jump to a sheet by name" },
  { group = "Cross-reference", lhs = "<leader>fl", rhs = "<cmd>Obsidian links<CR>", desc = "Links in this sheet" },
  { group = "Cross-reference", lhs = "<leader>bl", rhs = function() require("config.backlinks").backlinks() end, desc = "Backlinks to this sheet" },

  -- Sheets / Order (book mode)
  { group = "Sheets/Order", lhs = "<leader>nn", rhs = function() require("config.order").new_sheet() end, desc = "New sheet" },
  { group = "Sheets/Order", lhs = "<leader>ni", rhs = function() require("config.order").insert_after() end, desc = "Insert sheet after current" },
  { group = "Sheets/Order", lhs = "[s", rhs = function() require("config.order").move(-1) end, desc = "Move sheet up" },
  { group = "Sheets/Order", lhs = "]s", rhs = function() require("config.order").move(1) end, desc = "Move sheet down" },
  { group = "Sheets/Order", lhs = "<leader>rn", rhs = function() require("config.order").normalize() end, desc = "Renumber sheets (normalize gaps)" },

  -- Focus
  { group = "Focus", lhs = "<leader>z", rhs = "<cmd>ZenMode<CR>", desc = "Focus mode (only the writing buffer)" },
  { group = "Focus", lhs = "<leader>tw", rhs = function() require("config.gradient").toggle() end, desc = "Toggle paragraph gradient focus" },

  -- Git (hunks are real maps; the tree actions run inside the library window)
  { group = "Git", lhs = "<leader>hs", rhs = gs("stage_hunk"), desc = "Stage hunk" },
  { group = "Git", lhs = "<leader>hr", rhs = gs("reset_hunk"), desc = "Reset hunk" },
  { group = "Git", lhs = "<leader>hp", rhs = gs("preview_hunk"), desc = "Preview hunk" },
  { group = "Git", lhs = "ga", desc = "In the library: stage file/folder", display = true },
  { group = "Git", lhs = "gu", desc = "In the library: unstage", display = true },
  { group = "Git", lhs = "gr", desc = "In the library: revert", display = true },
  { group = "Git", lhs = "gc", desc = "In the library: commit (prompts for message)", display = true },
  { group = "Git", lhs = "gp", desc = "In the library: push", display = true },
  { group = "Git", lhs = "gg", desc = "In the library: commit AND push", display = true },

  -- AI (local LLM via LM Studio; custom lua/config/ai.lua)
  { group = "AI", lhs = "<leader>ac", rhs = "<cmd>lua require('config.ai').open_chat()<CR>", desc = "Chat about the selection / file (i=ask, select+y=copy, gx=clear, q=close)", mode = { "n", "v" } },

  -- Help
  { group = "Help", lhs = "<leader>?", rhs = function() require("config.help").open() end, desc = "Show this cheat sheet" },
}

function M.apply()
  local by_ft = {}
  for _, s in ipairs(M.specs) do
    if not s.display and s.rhs then
      if s.ft then
        by_ft[s.ft] = by_ft[s.ft] or {}
        table.insert(by_ft[s.ft], s)
      else
        vim.keymap.set(s.mode or "n", s.lhs, s.rhs, { desc = "dvi: " .. s.desc, silent = s.silent ~= false })
      end
    end
  end
  for ft, list in pairs(by_ft) do
    vim.api.nvim_create_autocmd("FileType", {
      pattern = ft,
      callback = function(ev)
        for _, s in ipairs(list) do
          vim.keymap.set(s.mode or "n", s.lhs, s.rhs, { desc = "dvi: " .. s.desc, buffer = ev.buf, silent = true })
        end
      end,
    })
  end
end

return M
