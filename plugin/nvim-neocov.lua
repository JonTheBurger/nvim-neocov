if vim.g.loaded_nvim_neocov then return end
vim.g.loaded_nvim_neocov = true

vim.api.nvim_create_user_command("Neocov", function(opts)
  if #opts.fargs == 0 then
    require("nvim-neocov.cmd").neocov()
  else
    local handler = require("nvim-neocov.cmd")[opts.fargs[1]]
    if handler ~= nil then
      handler(opts.fargs[2])
    else
      vim.notify("Neocov: Invalid command: " .. opts.fargs[1], vim.log.levels.ERROR)
    end
  end
end, {
  nargs = "*",
  ---Completion called when a space occurs between args
  ---@param _ nil Ignored arg_lead
  ---@param line string EX command line
  ---@param cursor integer Cursor position
  ---@return string[] auto-complete Suggestion list
  complete = function(_, line, cursor)
    line = line:sub(1, cursor)
    if line:find("^Neocov%s+report") then
      return { "show", "hide" }
    elseif line:find("^Neocov%s+watch") then
      return { "on", "off" }
    elseif line:find("^Neocov%s+jump") then
      return { "next", "prev" }
    end
    return { "generate", "load", "show", "hide", "toggle", "report", "jump", "qflist", "watch" }
  end,
})
