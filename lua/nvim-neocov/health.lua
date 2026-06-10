local M = {}

---This function is used to check the health of the plugin
---It's called by `:checkhealth` command
M.check = function()
  vim.health.start("nvim-neocov health check")

  -- Check nvim version
  local v = vim.version
  local major, minor, patch = 0, 12, 2
  if (v.major < major) or (v.major == major) and (v.minor < minor) or (v.major == major) and (v.minor == minor) and (v.patch < patch) then
    vim.health.error("Neovim version is too old!", "Please upgrade to " .. tostring(major) .. "." .. tostring(minor) .. "." .. tostring(patch))
  else
    vim.health.ok("Neovim version is up to date")
  end

  -- Check config
  local config = require("nvim-neocov.config")
  local ok, err = config.validate(config.config)
  if not ok then
    vim.health.error("Invalid setup options: " .. err)
  else
    vim.health.ok("Setup options are valid")
  end
end

return M
