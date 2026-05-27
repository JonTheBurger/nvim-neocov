-- TODO(POVIRK): remove
require("nvim-neocov")

if vim.g.loaded_nvim_neocov then
  return
end
vim.g.loaded_nvim_neocov = true

vim.api.nvim_set_hl(0, "NeocovUncovered", { link = "ErrorMsg" })
vim.api.nvim_set_hl(0, "NeocovParial", { link = "WarningMsg" })
vim.api.nvim_set_hl(0, "NeocovCovered", { link = "OkMsg" })
vim.api.nvim_set_hl(0, "NeocovNoCode", { link = "NeocovCovered" })

vim.api.nvim_create_user_command("Neocov", function(opts)
  if opts.fargs[1] == "load" then
    require("nvim-neocov").load()
  elseif opts.fargs[1] == "clear" then
    require("nvim-neocov").clear()
  elseif opts.fargs[1] == "watch" then
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
    elseif line:find("^Neocov%s+watch") then
      return { "on", "off", "toggle" }
    end
    return { "generate", "load", "clear", "toggle", "report", "watch" }
  end,
})

-- TODO(POVIRK): complete
vim.keymap.set("n", "<Plug>(nvim-neocov-TODO)", function()
end, { noremap = true, desc = "" })

--TODO(JON): Delete these debug commands
vim.api.nvim_create_user_command("JJ", function()
end, {})

vim.api.nvim_create_user_command("JK", function()
  require("nvim-neocov.annotate").clear(0)
end, {})

vim.api.nvim_create_user_command("JL", function()
  local cov = require("nvim-neocov.parse.sonarqube").parse("/home/jon/Projects/scratch/main.sonarqube.xml")
  vim.print(cov)
  require("nvim-neocov.annotate").buffer(0, cov)
end, {})

