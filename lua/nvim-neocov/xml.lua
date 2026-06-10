local M = {}

--- Parse XML from a file into a lua table
---@param path string Path on disk to parse
---@return any Lua table containing XML. Attributes are placed under and `_attr` tag.
M.to_table = function(path)
  local file = io.open(path, "r")
  if file == nil then return {} end
  local text = file:read("*a")
  file:close()

  local xml2lua = require("nvim-neocov.external.xml2lua.xml2lua")
  local handler = require("nvim-neocov.external.xml2lua.xmlhandler.tree"):new()
  local parser = xml2lua.parser(handler)
  parser:parse(text)
  return handler.root
end

return M
