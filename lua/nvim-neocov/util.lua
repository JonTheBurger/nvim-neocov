local M = {}

--- Convert a string to an int or die trying
---@param str string
---@return int
M.toint = function(str)
  ---@diagnostic disable-next-line: param-type-mismatch
  return math.floor(tonumber(str))
end

--- Gets visible buffers backed by actual files (these are likely to be code, and therefore may want coverage annotations)
---@return int[] List of file buffers
M.get_file_bufs = function()
  local bufs = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    -- Normal buffer, not a picker or terminal, etc.
    if vim.bo[buf].buftype == "" then
      table.insert(bufs, buf)
    end
  end
  return bufs
end

return M
