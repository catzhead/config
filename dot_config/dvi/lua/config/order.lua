-- Sheet ordering (book mode). Ordering is carried by a gapped numeric filename
-- prefix (010-, 020-, ...); the slug after the prefix is the stable identity and
-- never appears in a cross-reference link, so renumbering never breaks links.
local book = require("config.book")

local M = {}

local SHEET = "^(%d+)%-(.+)%.md$" -- prefix, slug

local function fmt(n)
  return string.format("%03d", n)
end

local function slugify(s)
  s = s:lower():gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
  return s
end

-- Directory to operate in: the current file's dir (if it's a real file), else cwd.
local function current_dir()
  local f = vim.api.nvim_buf_get_name(0)
  if f ~= "" and vim.bo.filetype ~= "neo-tree" then
    local d = vim.fn.fnamemodify(f, ":h")
    if vim.fn.isdirectory(d) == 1 then
      return d
    end
  end
  return vim.fn.getcwd()
end

local function list_sheets(dir)
  local sheets = {}
  local handle = vim.loop.fs_scandir(dir)
  if not handle then
    return sheets
  end
  while true do
    local name, typ = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    if typ ~= "directory" then
      local prefix, base = name:match(SHEET)
      if prefix then
        table.insert(sheets, { prefix = tonumber(prefix), base = base, file = name, path = dir .. "/" .. name })
      end
    end
  end
  table.sort(sheets, function(a, b)
    return a.prefix < b.prefix
  end)
  return sheets
end

local function next_prefix(dir)
  local max = 0
  for _, s in ipairs(list_sheets(dir)) do
    if s.prefix > max then
      max = s.prefix
    end
  end
  return max + 10
end

local function in_git(dir)
  vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--is-inside-work-tree" })
  return vim.v.shell_error == 0
end

-- Rename within a directory, preserving git history when the file is tracked.
local function rename(src, dst)
  local dir = vim.fn.fnamemodify(src, ":h")
  if in_git(dir) then
    vim.fn.system({ "git", "-C", dir, "mv", "-f", vim.fn.fnamemodify(src, ":t"), vim.fn.fnamemodify(dst, ":t") })
    if vim.v.shell_error == 0 then
      return true
    end
  end
  return vim.loop.fs_rename(src, dst) == true
end

-- Two-phase rename (src -> tmp -> dst) so swaps/renumbers never collide.
local function do_renames(list)
  local tmp = {}
  for i, p in ipairs(list) do
    local t = vim.fn.fnamemodify(p.src, ":h") .. "/.dvitmp-" .. i .. "-" .. vim.fn.fnamemodify(p.src, ":t")
    rename(p.src, t)
    tmp[i] = t
  end
  for i, p in ipairs(list) do
    rename(tmp[i], p.dst)
  end
end

local function refresh_tree()
  pcall(function()
    require("neo-tree.sources.manager").refresh("filesystem")
  end)
end

local function render_template(id, title)
  local path = vim.fn.stdpath("config") .. "/templates/sheet.md"
  local lines = vim.fn.filereadable(path) == 1 and vim.fn.readfile(path)
    or { "---", "id: {{id}}", "title: {{title}}", "aliases: [{{title}}]", "---", "", "# {{title}}", "" }
  local out = {}
  for _, l in ipairs(lines) do
    table.insert(out, (l:gsub("{{id}}", id):gsub("{{title}}", title)))
  end
  return out
end

local function open(path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  vim.cmd("normal! G")
  refresh_tree()
end

-- New sheet: numbered in book mode, plain slug.md otherwise.
function M.new_sheet()
  vim.ui.input({ prompt = "New sheet title: " }, function(title)
    if not title or title == "" then
      return
    end
    local slug = slugify(title)
    if slug == "" then
      vim.notify("dvi: title has no usable slug", vim.log.levels.WARN)
      return
    end
    local dir = current_dir()
    if book.is_book(dir) then
      for _, s in ipairs(list_sheets(dir)) do
        if s.base == slug then
          vim.notify("dvi: a sheet '" .. slug .. "' already exists here", vim.log.levels.ERROR)
          return
        end
      end
      local path = dir .. "/" .. fmt(next_prefix(dir)) .. "-" .. slug .. ".md"
      vim.fn.writefile(render_template(slug, title), path)
      open(path)
    else
      local path = dir .. "/" .. slug .. ".md"
      if vim.fn.filereadable(path) == 1 then
        vim.notify("dvi: " .. slug .. ".md already exists", vim.log.levels.WARN)
      else
        vim.fn.writefile({ "# " .. title, "" }, path)
      end
      open(path)
    end
  end)
end

-- Validate that the current buffer is a numbered sheet in a book. Returns dir, filename.
local function require_book_sheet()
  local f = vim.api.nvim_buf_get_name(0)
  if f == "" then
    vim.notify("dvi: no file in the current buffer", vim.log.levels.WARN)
    return nil
  end
  local dir = vim.fn.fnamemodify(f, ":h")
  if not book.is_book(dir) then
    vim.notify("dvi: not a book (run :DviBookInit to enable ordering)", vim.log.levels.WARN)
    return nil
  end
  local name = vim.fn.fnamemodify(f, ":t")
  if not name:match(SHEET) then
    vim.notify("dvi: current file is not a numbered sheet", vim.log.levels.WARN)
    return nil
  end
  return dir, name
end

-- Move the current sheet up (delta -1) or down (delta +1) by swapping prefixes.
function M.move(delta)
  local dir, name = require_book_sheet()
  if not dir then
    return
  end
  local sheets = list_sheets(dir)
  local idx
  for i, s in ipairs(sheets) do
    if s.file == name then
      idx = i
      break
    end
  end
  local j = idx + delta
  if j < 1 or j > #sheets then
    vim.notify("dvi: already at the " .. (delta < 0 and "top" or "bottom"), vim.log.levels.INFO)
    return
  end
  local a, b = sheets[idx], sheets[j]
  local a_dst = dir .. "/" .. fmt(b.prefix) .. "-" .. a.base .. ".md"
  local b_dst = dir .. "/" .. fmt(a.prefix) .. "-" .. b.base .. ".md"
  do_renames({ { src = a.path, dst = a_dst }, { src = b.path, dst = b_dst } })
  local view = vim.fn.winsaveview()
  vim.cmd("edit " .. vim.fn.fnameescape(a_dst))
  vim.fn.winrestview(view)
  refresh_tree()
end

-- Re-space a folder to clean 010,020,030... gaps in current order.
function M.normalize(dir)
  dir = dir or current_dir()
  if not book.is_book(dir) then
    vim.notify("dvi: not a book (run :DviBookInit to enable ordering)", vim.log.levels.WARN)
    return
  end
  local sheets = list_sheets(dir)
  if #sheets == 0 then
    vim.notify("dvi: no numbered sheets here", vim.log.levels.INFO)
    return
  end
  local cur = vim.api.nvim_buf_get_name(0)
  local cur_base
  if cur ~= "" then
    local _, b = vim.fn.fnamemodify(cur, ":t"):match(SHEET)
    cur_base = b
  end
  local renames, new_cur = {}, nil
  for i, s in ipairs(sheets) do
    local dst = dir .. "/" .. fmt(i * 10) .. "-" .. s.base .. ".md"
    if dst ~= s.path then
      table.insert(renames, { src = s.path, dst = dst })
    end
    if cur_base and s.base == cur_base then
      new_cur = dst
    end
  end
  if #renames == 0 then
    vim.notify("dvi: already normalised", vim.log.levels.INFO)
    return
  end
  do_renames(renames)
  if new_cur then
    local view = vim.fn.winsaveview()
    vim.cmd("edit " .. vim.fn.fnameescape(new_cur))
    vim.fn.winrestview(view)
  end
  refresh_tree()
  vim.notify("dvi: renumbered " .. #renames .. " sheet(s)", vim.log.levels.INFO)
end

-- Insert a new sheet immediately after the current one (midpoint prefix).
function M.insert_after()
  local dir, name = require_book_sheet()
  if not dir then
    return
  end
  vim.ui.input({ prompt = "Insert sheet after current — title: " }, function(title)
    if not title or title == "" then
      return
    end
    local slug = slugify(title)
    if slug == "" then
      return
    end
    local sheets = list_sheets(dir)
    local idx
    for i, s in ipairs(sheets) do
      if s.file == name then
        idx = i
        break
      end
    end
    local cur, nxt = sheets[idx], sheets[idx + 1]
    local newp
    if not nxt then
      newp = cur.prefix + 10
    else
      local mid = math.floor((cur.prefix + nxt.prefix) / 2)
      if mid <= cur.prefix or mid >= nxt.prefix then
        M.normalize(dir) -- no gap left; re-space then recompute
        sheets = list_sheets(dir)
        for i, s in ipairs(sheets) do
          if s.base == cur.base then
            idx = i
            break
          end
        end
        cur, nxt = sheets[idx], sheets[idx + 1]
        mid = nxt and math.floor((cur.prefix + nxt.prefix) / 2) or (cur.prefix + 10)
      end
      newp = mid
    end
    local path = dir .. "/" .. fmt(newp) .. "-" .. slug .. ".md"
    vim.fn.writefile(render_template(slug, title), path)
    open(path)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("DviNew", M.new_sheet, { desc = "dvi: new sheet (numbered in book mode)" })
  vim.api.nvim_create_user_command("DviInsert", M.insert_after, { desc = "dvi: insert a sheet after the current one" })
  vim.api.nvim_create_user_command("DviMoveUp", function()
    M.move(-1)
  end, { desc = "dvi: move current sheet up" })
  vim.api.nvim_create_user_command("DviMoveDown", function()
    M.move(1)
  end, { desc = "dvi: move current sheet down" })
  vim.api.nvim_create_user_command("DviNormalize", function()
    M.normalize()
  end, { desc = "dvi: renumber sheets to clean gaps" })
end

return M
