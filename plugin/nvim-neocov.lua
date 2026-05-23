if vim.g.loaded_nvim_neocov then
  return
end
vim.g.loaded_nvim_neocov = true

vim.api.nvim_create_user_command("Neocov", function(opts)
  if opts.fargs[1] == "report" then
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
      return { "on", "off", "toggle" }
    elseif line:find("^Neocov%s+watch") then
      return { "on", "off", "toggle" }
    end
    return { "on", "off", "toggle", "report", "watch" }
  end,
})

vim.keymap.set("n", "<Plug>(nvim-neocov-TODO)", function()
end, { noremap = true, desc = "" })
