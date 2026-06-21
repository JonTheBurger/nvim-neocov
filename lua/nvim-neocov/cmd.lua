--- This file implements all of the ":Neocov ..." commands.
--- **NO FILE OTHER THAN** `plugin/nvim-neocov.lua` **SHOULD IMPORT THIS.**
local M = {}

local Coverage = require("nvim-neocov.coverage")
local annotate = require("nvim-neocov.annotate")
local config = require("nvim-neocov.config")
local log = require("nvim-neocov.log")
local util = require("nvim-neocov.util")

--- Omnibus function
M.neocov = function()
  M.generate()
  M.load()
  M.show()
end

M.generate = function()
  if
    vim.bo[0].filetype == ""
    or vim.bo[0].buftype == "nofile"
    or vim.bo[0].buftype == "terminal"
    or vim.bo[0].buftype == "prompt"
  then
    log.warning("Can't generate code coverage for buffer type ", vim.bo[0].buftype)
    return
  end

  local filename = vim.api.nvim_buf_get_name(0)
  log.infof("Generating info for %s...", filename)

  local covfile = Coverage.file(filename)
  require("nvim-neocov.coverage").generate(filename, covfile.kind)

  log.debugf("  DONE Generating info for %s...", filename)
end

M.load = function() Coverage.load(vim.api.nvim_buf_get_name(0)) end

M.show = function()
  local cov = Coverage.load(vim.api.nvim_buf_get_name(0))
  if cov == nil then
    vim.notify("No coverage data found! Did you `Neocov generate`?")
    return
  end
  annotate.buffer(0, cov, config.get().style.decorations)
end

M.hide = function() annotate.clear() end

M.toggle = function()
  if next(annotate.cache) == nil then
    M.show()
  else
    M.hide()
  end
end

---@param _action? "show"|"hide" Toggles when nil
M.report = function(_action)
  local coverage = require("nvim-neocov").load()
  if coverage == nil then return end
  local summary = require("nvim-neocov").summary(coverage)
  local lines = vim.split(tostring(summary), "\n", { plain = true })
  util.open_hover(lines)
end

---@param direction? "next"|"prev"
M.jump = function(direction)
  direction = direction or "next"
  require("nvim-neocov.coverage").jump(direction)
end

M.qflist = function()
  local coverage = require("nvim-neocov").load()
  if coverage == nil then return end
  require("nvim-neocov.annotate").qflist(coverage, "covered")
end

---@param _action? "on"|"off" Toggles when nil
M.watch = function(_action) end

return M
