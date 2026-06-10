local Ratio = require("nvim-neocov.ratio")

---@class nvim-neocov.Summary Report of overall coverage statistics for a project, file, etc. Fields missing from the underlying coverage report are 0/0.
---@field conditions nvim-neocov.Ratio Number of covered conditions.
---@field branches nvim-neocov.Ratio Number of covered branches.
---@field lines nvim-neocov.Ratio Number of covered lines.
---@field blocks nvim-neocov.Ratio Number of covered blocks.
---@field functions nvim-neocov.Ratio Number of covered functions.
---@field files nvim-neocov.Ratio Number of covered files. If the summary is for a file, it is 1/1 if there is any coverage.
local Summary = {}
Summary.__index = Summary

---@param conditions nvim-neocov.Ratio? Field.
---@param branches nvim-neocov.Ratio? Field.
---@param lines nvim-neocov.Ratio? Field.
---@param blocks nvim-neocov.Ratio? Field.
---@param functions nvim-neocov.Ratio? Field.
---@param files nvim-neocov.Ratio? Field.
---@return nvim-neocov.Summary
Summary.new = function(conditions, branches, lines, blocks, functions, files)
  local self = {
    conditions = conditions or Ratio.new(),
    branches = branches or Ratio.new(),
    lines = lines or Ratio.new(),
    blocks = blocks or Ratio.new(),
    functions = functions or Ratio.new(),
    files = files or Ratio.new(),
  }
  setmetatable(self, Summary)
  return self  ---@diagnostic disable-line: return-type-mismatch
end

---@param other nvim-neocov.Summary
---@return nvim-neocov.Summary
function Summary:__add(other)
  return Summary.new(
    (self.conditions + other.conditions),
    (self.branches + other.branches),
    (self.lines + other.lines),
    (self.blocks + other.blocks),
    (self.functions + other.functions),
    (self.files + other.files)
  )
end

---@param fmt? string Format of each line - see `Ratio:format`.
---@return string
function Summary:format(fmt)
  local rep = ""
  if self.conditions.total > 0 then rep = rep .. "Conditions: " .. self.conditions:format(fmt) .. "\n" end
  if self.branches.total > 0 then rep = rep .. "Branches: " .. self.branches:format(fmt) .. "\n" end
  if self.lines.total > 0 then rep = rep .. "Lines: " .. self.lines:format(fmt) .. "\n" end
  if self.blocks.total > 0 then rep = rep .. "Blocks: " .. self.blocks:format(fmt) .. "\n" end
  if self.functions.total > 0 then rep = rep .. "Functions: " .. self.functions:format(fmt) .. "\n" end
  if self.files.total > 0 then rep = rep .. "Files: " .. self.files:format(fmt) .. "\n" end
  return rep
end

---@return string
function Summary:__tostring()
  return self:format()
end

return Summary
