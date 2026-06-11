if vim.g.loaded_nvim_neocov then return end
vim.g.loaded_nvim_neocov = true

vim.api.nvim_set_hl(0, "NeocovThresholdTerrible", { link = "DiagnosticError" })
vim.api.nvim_set_hl(0, "NeocovThresholdBad", { link = "DiagnosticError" })
vim.api.nvim_set_hl(0, "NeocovThresholdOk", { link = "DiagnosticWarn" })
vim.api.nvim_set_hl(0, "NeocovThresholdGood", { link = "DiagnosticOk" })
vim.api.nvim_set_hl(0, "NeocovThresholdPerfect", { link = "DiagnosticInfo" })

vim.api.nvim_set_hl(0, "NeocovFgUncovered", { link = "ErrorMsg" })
vim.api.nvim_set_hl(0, "NeocovFgPartial", { link = "WarningMsg" })
vim.api.nvim_set_hl(0, "NeocovFgCovered", { link = "DiagnosticOk" })
vim.api.nvim_set_hl(0, "NeocovFgNoCode", { link = "NeocovCovered" })

local util = require("nvim-neocov.util")
local blend = 0.20 -- 20% of the non-background color
local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg or 0
local fg = 0

fg = vim.api.nvim_get_hl(0, { name = "NeocovFgUncovered", link = false }).fg or bg
vim.api.nvim_set_hl(0, "NeocovBgUncovered", { bg = util.blend(fg, bg, blend) })
fg = vim.api.nvim_get_hl(0, { name = "NeocovFgPartial", link = false }).fg or bg
vim.api.nvim_set_hl(0, "NeocovBgPartial", { bg = util.blend(fg, bg, blend) })
fg = vim.api.nvim_get_hl(0, { name = "NeocovFgCovered", link = false }).fg or bg
vim.api.nvim_set_hl(0, "NeocovBgCovered", { bg = util.blend(fg, bg, blend) })
fg = vim.api.nvim_get_hl(0, { name = "NeocovFgNoCode", link = false }).fg or bg
vim.api.nvim_set_hl(0, "NeocovBgNoCode", { bg = util.blend(fg, bg, blend) })

vim.api.nvim_create_user_command("Neocov", function(opts)
  if opts.fargs[1] == "load" then
    require("nvim-neocov").load()
    require("nvim-neocov").annotate()
  elseif opts.fargs[1] == "clear" then
    require("nvim-neocov").clear()
  elseif opts.fargs[1] == "report" then
    local coverage = require("nvim-neocov").load()
    if coverage ~= nil then
      local summary = require("nvim-neocov").summary(coverage)

      vim.print(tostring(summary))
      -- TODO(JON): Make a floating buffer with the stringified output
    end
  else
  end
end, {
  nargs = "+",
  ---Completion called when a space occurs between args
  ---@param _ nil Ignored arg_lead
  ---@param line string EX command line
  ---@param cursor integer Cursor position
  ---@return string[] auto-complete Suggestion list
  complete = function(_, line, cursor)
    line = line:sub(1, cursor)
    if line:find("^Neocov%s+report") then
      return { "show", "hide", "toggle" }
    elseif line:find("^Neocov%s+summary") then
      return { "show", "hide", "toggle" }
    elseif line:find("^Neocov%s+watch") then
      return { "on", "off", "toggle" }
    end
    return { "generate", "load", "clear", "toggle", "report", "summary", "watch" }
  end,
})
