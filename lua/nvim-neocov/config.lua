local M = {}

---Checks that the user config is valid
---@param opts nvim-neocov.Config Resolved plugin options
---@return boolean Success
---@return string? Error message
M.validate = function(opts)
  -- TODO(JON): Check if a coverage file can be found
  return true, ""
end

---Configures the plugin with the given options
---@param cfg nvim-neocov.Config
M.apply = function(cfg)
  vim.api.nvim_create_augroup("Neocov", { clear = true })
  if #cfg.autoload > 0 then
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = "Neocov",
      callback = function(args)
        if vim.list_contains(cfg.autoload, vim.bo[args.buf].filetype) then
          require("nvim-neocov").load(args.buf)
        end
      end
    })
  end
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
  },
  autoload = {},
}

M.setup()

return M
