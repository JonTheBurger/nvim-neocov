local M = {}

--- Convert a string to an int or die trying
---@param str string
---@return int
M.toint = function(str)
  ---@diagnostic disable-next-line: param-type-mismatch
  return math.floor(tonumber(str))
end

return M
