---https://github.com/stevearc/overseer.nvim/blob/master/doc/guides.md#custom-components
---@module "overseer.component"
---@type overseer.ComponentFileDefinition
return {
  desc = "Load coverage data for a file",
  params = {
    file = {
      desc = "Path to the file to load coverage data for. The corresponding coverage file is determined using nvim-neocov's options.",
      type = "string",
      validate = function(v) return require("nvim-neocov.util").mtime(v) ~= nil end,
    },
  },
  editable = false,
  serializable = true,
  constructor = function(params)
    return {
      --- Called when the task has reached a completed state.
      ---@param status overseer.Status Can be CANCELED, FAILURE, or SUCCESS
      ---@param result table A result table.
      on_complete = function(_self, _task, status, _result)
        if status ~= "SUCCESS" then return end
        local cov = require("nvim-neocov.coverage").load(params.file)
        if cov == nil then
          vim.notify("JON THIS SHOULDN'T HAPPEN")
          return
        end
        --TODO(JON): We need path mapping really badly!
        -- require("nvim-neocov").clear()
        local cfg = require("nvim-neocov.config").config
        require("nvim-neocov.annotate").buffer(nil, cov, cfg.style.decorations)
      end,
    }
  end,
}
