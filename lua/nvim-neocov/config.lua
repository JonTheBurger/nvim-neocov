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
  M.config = vim.tbl_deep_extend("force", M.defaults, vim.g.nvim_neocov or {}, opts or {}) --[[@as nvim-neocov.Config]]
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
      },
      partial = {
        {
          kind = "highlight",
        },
        {
          kind = "virt_text",
          pos = "eol_right_align",
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
      },
      nocode = {
        {
          kind = "virt_text",
          pos = "eol_right_align",
        },
      },
    },
  },
}

M.setup()

return M
