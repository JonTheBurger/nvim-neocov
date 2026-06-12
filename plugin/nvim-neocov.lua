if vim.g.loaded_nvim_neocov then return end
vim.g.loaded_nvim_neocov = true

vim.api.nvim_create_user_command("Neocov", function(opts)
  if opts.fargs[1] == "generate" then
    --TODO(JON): generate
  elseif opts.fargs[1] == "load" then
    require("nvim-neocov").load()
    require("nvim-neocov").annotate()
  elseif opts.fargs[1] == "clear" then
    require("nvim-neocov").clear()
  elseif opts.fargs[1] == "report" then
    local coverage = require("nvim-neocov").load()
    if coverage ~= nil then
      local summary = require("nvim-neocov").summary(coverage)
      local lines = vim.split(tostring(summary), "\n", { plain = true })
      require("nvim-neocov.util").open_hover(lines, nil, nil, true)
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
