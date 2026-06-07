---@class nvim-neocov.Ratio Ratio of (e.g. lines) covered to total.
---@field covered int Covered number of e.g. lines.
---@field total int Total number of e.g. lines (always >= covered).
local Ratio = {}

---@param covered? int Field. 0 by default.
---@param total? int Field. 0 by default.
---@return nvim-neocov.Ratio
function Ratio:new(covered, total)
  local obj = {
    covered = covered or 0,
    total = total or 0,
  }
  setmetatable(obj, self)
  self.__index = self
  return obj  ---@diagnostic disable-line: return-type-mismatch
end

---@return number percentage of covered / total, or 100 if 0/0 total lines are covered.
function Ratio:percent()
  if self.total == 0 then return 100 end
  return 100 * self.covered / self.total
end

---@param other nvim-neocov.Ratio
---@return nvim-neocov.Ratio
function Ratio:__add(other)
  return Ratio:new(
    self.covered + other.covered,
    self.total + other.total
  )
end

---@param fmt? string Form of "3/6 (50.0%)" by default. `%C` for covered, `%T` for total, `%f` for percent. Use e.g. `%.1f` for formatting percent with decimals.
---@return string
function Ratio:format(fmt)
  fmt = fmt or "%C/%T (%.1f%%)"
  fmt = fmt:gsub("%%C", self.covered)
  fmt = fmt:gsub("%%T", self.total)
  return string.format(fmt, self:percent())
end

---@return string representation in the form of "3/6 (50.0%)"
function Ratio:__tostring()
  return self:format()
end

return Ratio
