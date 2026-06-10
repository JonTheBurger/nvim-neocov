local M = {}

--- Convert a string to an int or die trying
---@param str string
---@return int
M.toint = function(str)
  ---@diagnostic disable-next-line: param-type-mismatch
  return math.floor(tonumber(str))
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
    if vim.bo[buf].buftype == "" then
      table.insert(bufs, buf)
    end
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
