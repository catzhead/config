-- :DviHelp / <leader>? — a floating cheat sheet of dvi-specific shortcuts,
-- rendered from config.keymaps.specs so it never drifts from the real bindings.
local M = {}

local GROUP_ORDER = { "Navigate", "Cross-reference", "Sheets/Order", "Focus", "Git", "AI", "Help" }

local function build_lines()
  local specs = require("config.keymaps").specs
  local by_group = {}
  for _, s in ipairs(specs) do
    by_group[s.group] = by_group[s.group] or {}
    table.insert(by_group[s.group], s)
  end

  -- widest lhs, for alignment
  local w = 0
  for _, s in ipairs(specs) do
    w = math.max(w, #s.lhs)
  end

  local lines = { "  dvi — cheat sheet", "" }
  for _, group in ipairs(GROUP_ORDER) do
    local items = by_group[group]
    if items then
      table.insert(lines, "  " .. group)
      for _, s in ipairs(items) do
        table.insert(lines, string.format("    %-" .. w .. "s   %s", s.lhs, s.desc))
      end
      table.insert(lines, "")
    end
  end
  table.insert(lines, "  (q or <Esc> to close)")
  return lines
end

function M.open()
  local lines = build_lines()
  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = math.min(width + 2, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 4)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "dvihelp"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " dvi ",
    title_pos = "center",
  })
  vim.wo[win].wrap = false

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, "<cmd>close<CR>", { buffer = buf, silent = true, nowait = true })
  end
end

function M.setup()
  vim.api.nvim_create_user_command("DviHelp", M.open, { desc = "dvi: show the shortcut cheat sheet" })
end

return M
