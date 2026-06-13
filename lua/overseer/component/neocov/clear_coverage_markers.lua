---https://github.com/stevearc/overseer.nvim/blob/master/doc/guides.md#custom-components
---@module "overseer.component"
---@type overseer.ComponentFileDefinition
return {
  desc = "Clear Coverage Markers",
  params = {},
  editable = false,
  serializable = true,
  constructor = function(_params)
    return {
      --- Called when the task has reached a completed state.
      ---@param status overseer.Status Can be CANCELED, FAILURE, or SUCCESS
      ---@param result table A result table.
      on_complete = function(_self, task, status, _result)
        if status ~= "SUCCESS" then return end

        if task.metadata == nil then
          require("nvim-neocov").clear()
        else
          -- TODO(JON): Only clear for the buffer that actually is affected (requires remapping file paths in the report to local paths)
          require("nvim-neocov").clear()
        end
      end,
      --- Called when the task command has completed
      ---@param code number The process exit code
      on_exit = function(self, task, code) end,
    }
  end,
}
