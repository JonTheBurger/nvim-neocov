local M = {}

---Checks that the user config is valid
---@param opts nvim-neocov.Config Resolved plugin options
---@return boolean Success
---@return string? Error message
M.validate = function(opts)
  -- TODO(JON): Check if a coverage file can be found
  return true, ""
end

---Set up the plugin with custom settings
---@param opts? nvim-neocov.Options Plugin options
M.setup = function(opts)
  ---@private
  M.config = vim.tbl_deep_extend("force", M.defaults, vim.g.nvim_neocov or {}, opts or {}) --[[@as nvim-neocov.Config]]
  -- local has_overseer, overseer = pcall(require, "overseer")
  -- if has_overseer then
  --   overseer.register_template("neocov.generate")
  -- end
end

---Read-only default user options
---@type nvim-neocov.Options
M.defaults = {
  parsers = {
    sonarqube = require("nvim-neocov.parse.sonarqube").parse,
  },
  autoload = {},
  style = {
    decorations = {
      covered = {
        {
          kind = "highlight",
        },
        {
          kind = "virt_text",
          pos = "eol_right_align",
        },
        {
          kind = "branch",
        },
      },
      partial = {
        {
          kind = "highlight",
        },
        {
          kind = "virt_text",
          pos = "eol_right_align",
        },
        {
          kind = "branch",
        },
      },
      uncovered = {
        {
          kind = "highlight",
        },
        {
          kind = "virt_text",
          pos = "eol_right_align",
        },
        {
          kind = "branch",
        },
      },
      nocode = {
        {
          kind = "virt_text",
          pos = "eol_right_align",
        },
      },
    },
  },
  path_cmp = require("nvim-neocov.util").path_cmp,
}

--- Gets the current configuration
---@return nvim-neocov.Config
M.get = function() return M.config end

M.setup()

return M
