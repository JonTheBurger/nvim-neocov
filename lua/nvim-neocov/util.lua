local M = {}

--- Convert a string to an int or die trying
---@param str string
---@return int
M.toint = function(str)
  ---@diagnostic disable-next-line: param-type-mismatch
  return math.floor(tonumber(str))
end

---@param fg integer 0xRRGGBB
---@param bg integer 0xRRGGBB
---@param alpha number 0.0 (full bg) to 1.0 (full fg)
---@return integer
M.blend = function(fg, bg, alpha)
  local bit = require("bit")
  local r = math.floor(bit.band(bit.rshift(fg, 16), 0xFF) * alpha + bit.band(bit.rshift(bg, 16), 0xFF) * (1 - alpha))
  local g = math.floor(bit.band(bit.rshift(fg, 8), 0xFF) * alpha + bit.band(bit.rshift(bg, 8), 0xFF) * (1 - alpha))
  local b = math.floor(bit.band(fg, 0xFF) * alpha + bit.band(bg, 0xFF) * (1 - alpha))
  return bit.bor(bit.lshift(r, 16), bit.lshift(g, 8), b)
end

--- Gets visible buffers backed by actual files (these are likely to be code, and therefore may want coverage annotations)
---@param bufs? int|int[] Use nil, `bufs` will be returned as a list when non-nil.
---@return int[] List of file buffers
M.get_file_bufs = function(bufs)
  if type(bufs) == "number" then
    return { bufs }
  elseif type(bufs) == "table" then
    return bufs
  end

  bufs = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    -- Normal buffer, not a picker or terminal, etc.
    if vim.bo[buf].buftype == "" then table.insert(bufs, buf) end
  end
  return bufs
end

--- Centers text lines horizontally
---@param lines string[] Lines of text to center horizontally
---@param width int Number of columns
---@return string[] centered text
M.center_horizontal = function(lines, width)
  local result = {}
  for _, line in ipairs(lines) do
    local padding = math.floor((width - #line) / 2)
    table.insert(result, string.rep(" ", padding) .. line)
  end
  return result
end

--- Centers text lines vertically and horizontally
---@param lines string[] Lines of text to center
---@param width int Number of columns
---@param height int Number of rows
---@return string[] Padded lines
M.center = function(lines, width, height)
  local top_pad = math.floor((height - #lines) / 2)
  local padded = {}
  for _ = 1, top_pad do
    table.insert(padded, "")
  end
  for _, line in ipairs(M.center_horizontal(lines, width, height)) do
    table.insert(padded, line)
  end
  return padded
end

---@class nvim-neocov.open_hover_opts
---@field width? number Percentage of screen width in the range `(0.0,1.0]`
---@field height? number Percentage of screen height in the range `(0.0,1.0]`
---@field center? boolean `true` to center text, `false` (default) to leave unchanged.

--- Open a hover with the given lines
---@param lines string[] Lines
---@param opts nvim-neocov.open_hover_opts
---@return int, int Created Buffer,Window
M.open_hover = function(lines, opts)
  local width = math.floor(vim.o.columns * (opts.width or 0.5))
  local height = math.floor(vim.o.lines * (opts.height or 0.5))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  if opts.center then lines = M.center(lines, width, height) end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, nowait = true })

  return buf, win
end

--- Get the modified time of a file, or `nil` if the file did not exist or could not be read.
---@param path string File path
---@return int? Modified time in seconds
M.mtime = function(path)
  local stat = vim.uv.fs_stat(path)
  if stat == nil then return nil end
  return stat.mtime.sec
end

return M
