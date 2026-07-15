-- Paragraph focus with a gradient: the current paragraph stays at full
-- brightness; each paragraph further above/below fades toward the background.
-- (twilight dims everything outside the current block uniformly; this fades by
-- distance instead.)
local M = {}

local ns = vim.api.nvim_create_namespace("dvi_gradient")
M.enabled = true
M.levels = 0

-- Blend fg toward bg. a = 0 keeps fg, a = 1 becomes bg.
local function blend(fg, bg, a)
  local fr, fgc, fb = math.floor(fg / 65536) % 256, math.floor(fg / 256) % 256, fg % 256
  local br, bgc, bb = math.floor(bg / 65536) % 256, math.floor(bg / 256) % 256, bg % 256
  local r = math.floor(fr + (br - fr) * a + 0.5)
  local g = math.floor(fgc + (bgc - fgc) * a + 0.5)
  local b = math.floor(fb + (bb - fb) * a + 0.5)
  return r * 65536 + g * 256 + b
end

-- Precompute the dim highlight groups from the current Normal colors.
function M.define_hl()
  local n = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local fg = n.fg or 0xcad3f5
  local bg = n.bg or 0x24273a
  local alphas = { 0.40, 0.60, 0.74, 0.84 } -- distance 1..N, then clamped
  for i, a in ipairs(alphas) do
    vim.api.nvim_set_hl(0, "DviGrad" .. i, { fg = string.format("#%06x", blend(fg, bg, a)) })
  end
  M.levels = #alphas
end

local function group_for(d)
  return "DviGrad" .. math.min(d, M.levels)
end

-- Paragraphs (maximal runs of non-blank lines) intersecting [lo, hi].
local function paragraphs(buf, lo, hi)
  local lines = vim.api.nvim_buf_get_lines(buf, lo - 1, hi, false)
  local paras, start = {}, nil
  for i, l in ipairs(lines) do
    local ln = lo + i - 1
    if l:match("^%s*$") then
      if start then
        paras[#paras + 1] = { s = start, e = ln - 1 }
        start = nil
      end
    else
      start = start or ln
    end
  end
  if start then
    paras[#paras + 1] = { s = start, e = hi }
  end
  return paras
end

function M.refresh()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if not M.enabled or vim.bo[buf].filetype ~= "markdown" then
    return
  end
  if M.levels == 0 then
    M.define_hl()
  end

  local w0, w9 = vim.fn.line("w0"), vim.fn.line("w$")
  local last = vim.fn.line("$")
  local margin = 60 -- consider paragraphs a little past the viewport for stable distances
  local paras = paragraphs(buf, math.max(1, w0 - margin), math.min(last, w9 + margin))
  if #paras == 0 then
    return
  end

  local cur = vim.fn.line(".")
  local ci
  for i, p in ipairs(paras) do
    if cur >= p.s and cur <= p.e then
      ci = i
      break
    end
  end
  if not ci then -- cursor on a blank line: attach to the next paragraph
    for i, p in ipairs(paras) do
      if p.s > cur then
        ci = i
        break
      end
    end
    ci = ci or #paras
  end

  local vis = vim.api.nvim_buf_get_lines(buf, w0 - 1, w9, false)
  for i, p in ipairs(paras) do
    local d = math.abs(i - ci)
    if d > 0 then
      local grp = group_for(d)
      for ln = math.max(p.s, w0), math.min(p.e, w9) do
        local text = vis[ln - w0 + 1] or ""
        if #text > 0 then
          -- priority 200 so the dim wins over treesitter's syntax fg
          vim.api.nvim_buf_set_extmark(buf, ns, ln - 1, 0, {
            end_row = ln - 1,
            end_col = #text,
            hl_group = grp,
            priority = 200,
          })
        end
      end
    end
  end
end

function M.clear()
  vim.api.nvim_buf_clear_namespace(vim.api.nvim_get_current_buf(), ns, 0, -1)
end

function M.toggle()
  M.enabled = not M.enabled
  if M.enabled then
    M.refresh()
  else
    M.clear()
  end
  vim.notify("dvi: paragraph gradient " .. (M.enabled and "on" or "off"))
end

function M.setup()
  M.define_hl()
  local grp = vim.api.nvim_create_augroup("DviGradient", { clear = true })
  vim.api.nvim_create_autocmd(
    { "CursorMoved", "CursorMovedI", "WinScrolled", "BufWinEnter", "TextChanged", "TextChangedI" },
    { group = grp, callback = function() M.refresh() end }
  )
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = grp,
    callback = function()
      M.levels = 0
      M.define_hl()
      M.refresh()
    end,
  })
  vim.api.nvim_create_user_command("DviGradient", M.toggle, { desc = "dvi: toggle paragraph gradient focus" })
end

return M
