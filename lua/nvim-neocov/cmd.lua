--- This file implements all of the ":Neocov ..." commands.
--- **NO FILE OTHER THAN** `plugin/nvim-neocov.lua` **SHOULD IMPORT THIS.**
local M = {}

local neocov = require("nvim-neocov")
local nio = require("nio")

M.neocov = function()
  nio.run(function() neocov.neocov() end)
end

M.generate = function()
  nio.run(function() neocov.generate() end)
end

M.load = function()
  nio.run(function() neocov.load() end)
end

M.show = function()
  nio.run(function() neocov.show() end)
end

M.hide = function()
  nio.run(function() neocov.hide() end)
end

M.toggle = function()
  nio.run(function() neocov.toggle() end)
end

---@param action? "show"|"hide" Toggles when nil
M.report = function(action)
  nio.run(function() neocov.report(action) end)
end

---@param direction? "next"|"prev"
M.jump = function(direction)
  nio.run(function() neocov.jump(direction) end)
end

M.qflist = function()
  nio.run(function() neocov.qflist() end)
end

---@param action? "on"|"off" Toggles when nil
M.watch = function(action)
  nio.run(function() neocov.watch(action) end)
end

return M
