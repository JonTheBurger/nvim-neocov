local M = {}

---Checks that the user config is valid
---@param opts nvim-neocov.Config Resolved plugin options
---@return boolean Success
---@return string? Error message
M.validate = function(opts)
  --TODO(JON): xq
  return true, ""
end

---Configures the plugin with the given options
---@param cfg nvim-neocov.Config
M.apply = function(cfg)
  local _ = cfg
end

---Set up the plugin with custom settings
---@param opts? nvim-neocov.Options Plugin options
M.setup = function(opts)
  M.config = vim.tbl_deep_extend("force", M.defaults, vim.g.nvim_neocov or {}, opts or {}) --[[@as nvim-neocov.Config]]
  M.apply(M.config)
end

---Read-only default user options
---@type nvim-neocov.Options
M.defaults = {
  parsers = {
    sonarqube = require("nvim-neocov.parse.sonarqube").parse
  }
}

M.setup()

return M
