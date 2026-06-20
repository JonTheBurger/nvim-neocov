---@private
---@module "neotest.types.tree"
---@param node neotest.Tree
---@return boolean
local _skip_file_node_children = function(node) return node:data().type ~= "file" end

---@module "neotest.client"
---@param client neotest.Client
return function(client)
  ---@module "neotest"
  ---@param adapter_id string
  ---@param results table<string, neotest.Result>
  ---@param partial boolean
  local on_results = function(adapter_id, results, partial)
    if partial then return end

    local all_passed = true
    for _, result in ipairs(results) do
      if result.status == "failed" then
        all_passed = false
        break
      end
    end

    if all_passed then
      ---@type table<string, bool>
      local files = {}
      local tree = client:get_position(nil, { adapter = adapter_id })
      for _, node in tree:iter_nodes({ continue = _skip_file_node_children }) do
        if node:data().type == "file" then files[node:data().path] = true end
      end

      local cfg = require("nvim-neocov.config").get()
      for file, _ in pairs(files) do
        local ft = vim.filetype.match({ filename = file })
        if cfg.ft == nil or cfg.ft[ft] then require("nvim-neocov.coverage").generate(file) end
      end
    end
  end

  client.listeners.results = on_results
end
