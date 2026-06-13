--- This file implements all of the ":Neocov ..." commands.
--- **NO FILE OTHER THAN** `plugin/nvim-neocov.lua` **SHOULD IMPORT THIS.**
local M = {}

local log = require("nvim-neocov.log")

M.generate = function()
  if vim.bo[0].filetype == "" or vim.bo[0].buftype == "nofile" or vim.bo[0].buftype == "terminal" or vim.bo[0].buftype == "prompt" then
    vim.notify("Can't generate code coverage for buffer type " .. vim.bo[0].buftype)
    return
  end

  local filename = vim.api.nvim_buf_get_name(0)

  local cfg = require("nvim-neocov.config").config
  local output = nil
  if type(cfg.file) == "string" then
    log.errorf('Invalid type `string` for `nvim-neocov.Options.file` Did you mean `{ path = "%s", kind = "..." }`?', cfg.file)
  elseif type(cfg.file) == "function" then
    output = cfg.file(filename)
  else
    output = (#cfg.file > 0) and cfg.file[1] or cfg.file
  end
  if output == nil then
    log.fatal("output should never be nil")
    return
  end

  log.infof("Generating info for %s...", filename)
  require("nvim-neocov.coverage").generate(filename, output.kind or "lcov")
  log.debugf("  DONE Generating info for %s...", filename)
end

return M
