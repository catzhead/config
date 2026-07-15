-- Book mode: a folder is a "book" (ordered sheets) iff a `.dvibook` marker file
-- exists at or above it. Plain folders (blogs, article dirs) have no marker and
-- get none of the numbering machinery.
local M = {}

local MARKER = ".dvibook"
local cache = {} -- start-dir -> root (or false)

-- Walk up from `start` looking for the marker. Returns the book root dir, or nil.
function M.book_root(start)
  start = start or vim.fn.getcwd()
  start = vim.fn.fnamemodify(start, ":p")
  if cache[start] ~= nil then
    return cache[start] or nil
  end
  local dir = start
  while true do
    if vim.fn.filereadable(dir .. "/" .. MARKER) == 1 then
      cache[start] = dir
      return dir
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      break -- reached filesystem root
    end
    dir = parent
  end
  cache[start] = false
  return nil
end

-- Is the given path (default: cwd) inside a book?
function M.is_book(path)
  return M.book_root(path) ~= nil
end

-- Clear the cache (after :DviBookInit changes the answer).
function M.reset()
  cache = {}
end

function M.setup()
  vim.api.nvim_create_user_command("DviBookInit", function()
    local root = vim.fn.getcwd()
    local marker = root .. "/" .. MARKER
    if vim.fn.filereadable(marker) == 1 then
      vim.notify("dvi: already a book (" .. marker .. ")", vim.log.levels.INFO)
      return
    end
    local ok = pcall(vim.fn.writefile, { "# dvi book marker — presence enables ordered sheets" }, marker)
    if not ok then
      vim.notify("dvi: could not create " .. marker, vim.log.levels.ERROR)
      return
    end
    M.reset()
    vim.notify("dvi: book initialised at " .. root, vim.log.levels.INFO)
  end, { desc = "dvi: mark the current directory as a book (create .dvibook)" })
end

return M
