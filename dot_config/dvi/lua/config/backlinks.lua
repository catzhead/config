-- Prefix-agnostic backlinks. obsidian.nvim's own backlinks picker is
-- path/filename-based, so alias-only links can slip through. Instead we grep the
-- whole workspace for the current sheet's stable identity (slug + frontmatter
-- title/aliases) appearing inside a [[wiki link]].
local M = {}

-- Escape a string for use in a ripgrep (Rust regex) pattern.
local function rgesc(s)
  return (s:gsub("[%(%)%[%]%{%}%.%*%+%-%?%^%$%|\\/]", "\\%1"))
end

-- Pull title/aliases out of a sheet's YAML frontmatter (best-effort).
local function frontmatter_terms(file)
  local terms = {}
  local lines = vim.fn.filereadable(file) == 1 and vim.fn.readfile(file, "", 40) or {}
  if lines[1] ~= "---" then
    return terms
  end
  for i = 2, #lines do
    local l = lines[i]
    if l == "---" then
      break
    end
    local t = l:match("^title:%s*(.+)$")
    if t then
      table.insert(terms, (t:gsub('^["\']', ""):gsub('["\']$', "")))
    end
    local a = l:match("^aliases:%s*%[(.+)%]$")
    if a then
      for item in a:gmatch("[^,]+") do
        item = item:gsub("^%s*", ""):gsub("%s*$", ""):gsub('^["\']', ""):gsub('["\']$', "")
        if item ~= "" then
          table.insert(terms, item)
        end
      end
    end
  end
  return terms
end

function M.backlinks()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("dvi: no sheet in the current buffer", vim.log.levels.WARN)
    return
  end
  local slug = vim.fn.fnamemodify(file, ":t:r"):gsub("^%d+%-", "")
  local terms = { slug }
  vim.list_extend(terms, frontmatter_terms(file))

  local seen, uniq = {}, {}
  for _, t in ipairs(terms) do
    if t ~= "" and not seen[t] then
      seen[t] = true
      table.insert(uniq, rgesc(t))
    end
  end

  local pattern = "\\[\\[[^\\]]*(" .. table.concat(uniq, "|") .. ")"
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("dvi: telescope not available", vim.log.levels.ERROR)
    return
  end
  builtin.grep_string({ search = pattern, use_regex = true, prompt_title = "Backlinks → " .. slug })
end

return M
