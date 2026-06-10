-- require("neotest").setup({
--   consumers = {
--     coverage = require("neotest.consumers.nvim-neocov"),
--   },
-- })

return function(client)
  client.event.subscribe("results_update", function(adapter_id, results)
    -- Check if all results are passed (no failures)
    local any_failed = false
    for _, result in pairs(results) do
      if result.status == "failed" then
        any_failed = true
        break
      end
    end

    if not any_failed then
      -- require("overseer").new_task({
      --   cmd = { "pytest", "--cov", "--cov-report=xml" },
      --   name = "coverage",
      --   components = { "default" },
      -- }):start()
    end
  end)
end
