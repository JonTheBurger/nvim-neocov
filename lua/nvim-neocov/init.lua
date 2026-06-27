---Public API for nvim-neocov.
---This file should mostly just be a shim for other APIs.
---Only `plugin/` and third party integration modules should include this file.
local M = {}

local Coverage = require("nvim-neocov.coverage")
local Summary = require("nvim-neocov.summary")
local annotate = require("nvim-neocov.annotate")
local config = require("nvim-neocov.config")

----------------------------------------------------------------------------------------
---@section Globals
----------------------------------------------------------------------------------------

---@type nvim-neocov.Scope[]
M.scope_names = {
  "conditions",
  "branches",
  "lines",
  "blocks",
  "functions",
  "files",
}

----------------------------------------------------------------------------------------
---@endsection
---@section AutoCommands
----------------------------------------------------------------------------------------
annotate.load_highlights()

M.augroup = vim.api.nvim_create_augroup("Neocov", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Recalculate default Neocov Highlights when changing color schemes",
  group = M.augroup,
  callback = annotate.load_highlights,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Automatically load coverage data for files",
  group = M.augroup,
  callback = function(args)
    local cfg = config.get()
    if vim.list_contains(cfg.autoload, vim.bo[args.buf].filetype) then Coverage.load(0) end
  end,
})
vim.api.nvim_create_autocmd("BufWipeout", {
  desc = "Mark wiped out buffers as no longer covered",
  group = M.augroup,
  callback = function(args) annotate.unload(args.buf) end,
})

----------------------------------------------------------------------------------------
---@endsection
---@section Functions
----------------------------------------------------------------------------------------

--- Set up the plugin with custom settings
---@param opts? nvim-neocov.Options Plugin options
M.setup = function(opts) config.setup(opts) end

---@async
M.neocov = function()
  M.generate()
  M.load()
  M.show()
end

---@async
M.generate = function()
  if
    vim.bo[0].filetype == ""
    or vim.bo[0].buftype == "nofile"
    or vim.bo[0].buftype == "terminal"
    or vim.bo[0].buftype == "prompt"
  then
    log.warning("Can't generate code coverage for buffer type ", vim.bo[0].buftype)
    return
  end

  local filename = vim.api.nvim_buf_get_name(0)
  local covfile = Coverage.file(filename)
  require("nvim-neocov.coverage").generate(filename, covfile.kind)
end

---@async
M.load = function() return Coverage.load(0) end

---@async
M.show = function()
  local cov = Coverage.load(0)
  if cov == nil then
    vim.notify("No coverage data found! Did you `Neocov generate`?")
    return
  end
  annotate.buffer(0, cov, config.get().style.decorations)
end

---@async
M.hide = function() annotate.clear() end

---@async
M.toggle = function()
  if next(annotate.cache) == nil then
    M.show()
  else
    M.hide()
  end
end

---@async
---@param _action? "show"|"hide" Toggles when nil
M.report = function(_action)
  local coverage = M.load()
  if coverage == nil then return end
  local summary = require("nvim-neocov").summary(coverage)
  local lines = vim.split(tostring(summary), "\n", { plain = true })
  util.open_hover(lines)
end

---@async
---@param direction? "next"|"prev"
M.jump = function(direction)
  direction = direction or "next"
  require("nvim-neocov.coverage").jump(direction)
end

---@async
M.qflist = function()
  local coverage = M.load()
  if coverage == nil then return end
  require("nvim-neocov.annotate").qflist(coverage, "covered")
end

---@async
---@param _action? "on"|"off" Toggles when nil
M.watch = function(_action) end

-- TODO(JON): Move summary to the summary file
---@param cov nvim-neocov.FileCoverage
---@return nvim-neocov.Summary
M._file_summary = function(cov)
  local summary = Summary.new()
  summary.files.total = 1

  for _, line in pairs(cov.lines) do
    summary.lines.total = summary.lines.total + 1
    if line.covered > 0 then
      summary.lines.covered = summary.lines.covered + 1
      summary.files.covered = 1
    end

    -- We say that every line has at least 1 "branch" - 2+ branches implies a split
    if line.branches > 1 then
      summary.branches.total = summary.branches.total + line.branches - 1
      summary.branches.covered = summary.branches.covered + line.covered - 1
    end
  end

  return summary
end

--- Generate a summary for the provided coverage data. Most recent conversion is cached.
---@param coverage nvim-neocov.Coverage
---@param file? string Name of the file to get a summary for, or nil for the full project. TODO(JON): How is file compared?
---@return nvim-neocov.Summary
M.summary = function(coverage, file)
  file = file or ""
  -- Invalidate Cache
  if coverage ~= M._summaries_coverage then
    M._file_summaries = {}
    M._summaries_coverage = coverage
  end

  -- Fetch from cache
  if M._file_summaries[file] ~= nil then return M._file_summaries[file] end

  -- Load
  local summary = Summary.new()

  if file == "" then
    -- Project Summary
    for _, cov in pairs(coverage.files) do
      local file_summary = M._file_summary(cov)
      summary = summary + file_summary
    end
  else
    -- File Summary
    if coverage.files[file] ~= nil then summary = M._file_summary(coverage.files[file]) end
  end

  -- Cache
  M._file_summaries[file] = summary
  return summary
end

----------------------------------------------------------------------------------------
---@endsection
----------------------------------------------------------------------------------------

return M
