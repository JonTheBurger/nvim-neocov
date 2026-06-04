local M = require("lualine.component"):extend()

function M:init(options)
  M.super.init(self, options)
end

function M:update_status()
  vim.notify("lualine nvim-neocov update_status")
end

return M
