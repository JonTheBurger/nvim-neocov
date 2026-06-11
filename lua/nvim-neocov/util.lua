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

--- Get the modified time of a file, or `nil` if the file did not exist or could not be read.
---@param path string File path
---@return int? Modified time in seconds
M.mtime = function(path)
  local stat = vim.uv.fs_stat(path)
  if stat == nil then return nil end
  return stat.mtime.sec
end

return M
