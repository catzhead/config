-- dvi AI: a small, direct bridge to a local LM Studio server. No plugin, no
-- JSON protocol -- just raw text. A multi-turn streaming chat about the current
-- selection (with the whole file as context). It does not edit your document;
-- select text in the window and yank (y) to copy anything you want to keep.
local M = {}

local SYSTEM = table.concat({
  "You are a writing companion for long-form prose.",
  "You are given the full document for context and usually a focus passage the user is asking about.",
  "Discuss it, considering how it fits the whole document.",
}, " ")

-- If the file is bigger than this, send a window around the selection instead.
local MAX_CONTEXT_CHARS = 24000

-- Chat session state (one conversation at a time).
local S = { win = nil, buf = nil, messages = nil, focus = nil, busy = false, stream_text = nil }

local function base_url()
  return os.getenv("LMSTUDIO_URL") or "http://localhost:1234"
end

local function notify(msg, lvl)
  vim.notify("dvi ai: " .. msg, lvl or vim.log.levels.INFO)
end

-- Resolve the model id: $LMSTUDIO_MODEL, else the first model LM Studio reports.
local function with_model(cb)
  local env = os.getenv("LMSTUDIO_MODEL")
  if env and env ~= "" then
    cb(env)
    return
  end
  vim.system({ "curl", "-sS", base_url() .. "/v1/models" }, { text = true }, function(res)
    local id
    local ok, data = pcall(vim.json.decode, res.stdout or "")
    if ok and data and data.data and data.data[1] then
      id = data.data[1].id
    end
    vim.schedule(function()
      cb(id)
    end)
  end)
end

-- Parse one SSE line into a content delta (or nil). Pure -> testable.
function M._parse_delta(line)
  line = line:gsub("\r$", "")
  if line:sub(1, 6) ~= "data: " then
    return nil
  end
  local payload = line:sub(7)
  if payload == "[DONE]" then
    return nil
  end
  local ok, obj = pcall(vim.json.decode, payload)
  if ok and obj.choices and obj.choices[1] and obj.choices[1].delta then
    return obj.choices[1].delta.content
  end
  return nil
end

-- Streaming completion. on_delta(text) per chunk; on_done(ok, err) at the end.
local function stream(messages, on_delta, on_done)
  with_model(function(model)
    if not model then
      on_done(false, "no model loaded (is LM Studio running at " .. base_url() .. "?)")
      return
    end
    local body = vim.json.encode({ model = model, messages = messages, stream = true, temperature = 0.7 })
    local acc = ""
    vim.system({
      "curl", "-sS", "-N", "-X", "POST",
      base_url() .. "/v1/chat/completions",
      "-H", "Content-Type: application/json",
      "--data-binary", "@-",
    }, {
      text = true,
      stdin = body,
      stdout = function(_, data)
        if not data then
          return
        end
        acc = acc .. data
        while true do
          local nl = acc:find("\n")
          if not nl then
            break
          end
          local line = acc:sub(1, nl - 1)
          acc = acc:sub(nl + 1)
          local c = M._parse_delta(line)
          if c and c ~= "" then
            vim.schedule(function()
              on_delta(c)
            end)
          end
        end
      end,
    }, function(res)
      vim.schedule(function()
        if res.code ~= 0 then
          on_done(false, ((res.stderr or "request failed"):gsub("%s+$", "")))
        else
          on_done(true)
        end
      end)
    end)
  end)
end

-- Build the message list (system carries document + focus). Pure -> testable.
function M._build(file_lines, l1, l2)
  local file_text = table.concat(file_lines, "\n")
  local focus
  if l1 and l1 > 0 and l2 and l2 >= l1 then
    focus = table.concat(vim.list_slice(file_lines, l1, l2), "\n")
  end
  local ctx = file_text
  if #ctx > MAX_CONTEXT_CHARS and focus then
    local a = math.max(1, l1 - 100)
    local b = math.min(#file_lines, l2 + 100)
    ctx = table.concat(vim.list_slice(file_lines, a, b), "\n")
  end
  local content = SYSTEM .. "\n\nFULL DOCUMENT (context):\n" .. ctx
  if focus then
    content = content .. "\n\nFOCUS PASSAGE (what the user is asking about):\n" .. focus
  end
  return { { role = "system", content = content } }, focus
end

local function render()
  if not (S.buf and vim.api.nvim_buf_is_valid(S.buf)) then
    return
  end
  local lines = {}
  if S.focus then
    local snip = S.focus.text:gsub("%s+", " "):sub(1, 64)
    table.insert(lines, "▎ focus: " .. snip .. (#S.focus.text > 64 and "…" or ""))
    table.insert(lines, "")
  end
  for i = 2, #S.messages do -- skip the system/context message
    local m = S.messages[i]
    table.insert(lines, (m.role == "user" and "You:" or "AI:"))
    for _, l in ipairs(vim.split(m.content, "\n", { plain = true })) do
      table.insert(lines, "  " .. l)
    end
    table.insert(lines, "")
  end
  if S.busy then
    table.insert(lines, "AI:")
    local t = S.stream_text
    if t and t ~= "" then
      for _, l in ipairs(vim.split(t, "\n", { plain = true })) do
        table.insert(lines, "  " .. l)
      end
    else
      table.insert(lines, "  …")
    end
  end
  if not S.busy then
    table.insert(lines, "")
    table.insert(lines, "· i ask · select + y to copy · gx clear · q close")
  end
  if #lines == 0 then
    lines = { "(press i to ask, q to close)" }
  end
  vim.bo[S.buf].modifiable = true
  vim.api.nvim_buf_set_lines(S.buf, 0, -1, false, lines)
  vim.bo[S.buf].modifiable = false
  if S.win and vim.api.nvim_win_is_valid(S.win) then
    vim.api.nvim_win_set_cursor(S.win, { #lines, 0 })
  end
end

local function open_window()
  if S.win and vim.api.nvim_win_is_valid(S.win) then
    vim.api.nvim_set_current_win(S.win)
    return
  end
  S.buf = vim.api.nvim_create_buf(false, true)
  -- neutral filetype keeps render-markdown, the gradient and spell out of the chat
  vim.bo[S.buf].filetype = "dvichat"
  vim.bo[S.buf].bufhidden = "hide"
  local w = math.min(80, vim.o.columns - 8)
  local h = math.min(24, vim.o.lines - 6)
  S.win = vim.api.nvim_open_win(S.buf, true, {
    relative = "editor",
    width = w,
    height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = "minimal",
    border = "rounded",
    title = " dvi · chat ",
    title_pos = "center",
  })
  vim.wo[S.win].wrap = true
  vim.bo[S.buf].modifiable = false
  local o = { buffer = S.buf, silent = true, nowait = true }
  vim.keymap.set("n", "i", M.prompt, o)
  vim.keymap.set("n", "q", M.close, o)
  vim.keymap.set("n", "<Esc>", M.close, o)
  vim.keymap.set("n", "gx", M.reset, o)
  render()
end

-- Ask for a message and stream the reply.
function M.prompt()
  if S.busy then
    notify("still thinking…")
    return
  end
  vim.ui.input({ prompt = "You: " }, function(text)
    if not text or text == "" then
      return
    end
    table.insert(S.messages, { role = "user", content = text })
    S.busy = true
    S.stream_text = ""
    render()
    stream(S.messages, function(delta)
      S.stream_text = S.stream_text .. delta
      render()
    end, function(ok, err)
      table.insert(S.messages, {
        role = "assistant",
        content = ok and S.stream_text or ("[error] " .. (err or "unknown")),
      })
      S.stream_text = nil
      S.busy = false
      render()
    end)
  end)
end

function M.close()
  if S.win and vim.api.nvim_win_is_valid(S.win) then
    vim.api.nvim_win_close(S.win, true)
  end
  S.win = nil
end

function M.reset()
  if S.messages then
    S.messages = { S.messages[1] } -- keep the system/context, drop the turns
  end
  render()
end

-- Entry point, mode-aware. Visual selection -> focus passage; normal -> whole file.
function M.open_chat()
  local m = vim.fn.mode()
  local l1, l2 = 0, 0
  if m == "v" or m == "V" or m == "\22" then
    l1 = vim.fn.getpos("v")[2]
    l2 = vim.fn.getpos(".")[2]
    if l1 > l2 then
      l1, l2 = l2, l1
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end
  local buf = vim.api.nvim_get_current_buf()
  local file_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local msgs, focus_text = M._build(file_lines, l1, l2)
  S.messages = msgs
  S.focus = focus_text and { text = focus_text } or nil
  open_window()
  vim.schedule(M.prompt)
end

return M
