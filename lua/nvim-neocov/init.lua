---Public API for nvim-neocov
local M = {}

local Summary = require("nvim-neocov.summary")

----------------------------------------------------------------------------------------
---@section Globals
----------------------------------------------------------------------------------------

---@type table<string, nvim-neocov.Summary> Cache of summaries for each file, or `""` key for the full project summary.
M._file_summaries = {}

---@type nvim-neocov.Coverage? Most recently loaded coverage report used to generate a summary.
M._summaries_coverage = nil

---@type nvim-neocov.Coverage? Most recently loaded coverage report.
M.coverage = nil

--TODO(JON): This only supports one report at a time. That doesn't work if you have C++ and python in the same codebase. Per-ft isn't perfect because C/C++ may share.
---@type nvim-neocov.CoverageFile? Path to file source for most recently loaded coverage report.
M.file = nil

---@type int Modified time of the coverage file used for the most recent `M.coverage` load. Used to determine if a reload is necessary.
M.mtime = 0

--- List of buffers that have been annotated
---@type int[]
M.annotated = {}

----------------------------------------------------------------------------------------
---@endsection
---@section Functions
----------------------------------------------------------------------------------------

--- Set up the plugin with custom settings
---@param opts? nvim-neocov.Options Plugin options
M.setup = function(opts)
  require("nvim-neocov.config").setup(opts)
end

--- Locates a coverage file on disk
---@param src string? File the corresponding coverage report is being requested for, or nil if for the full project. If your project contains both C++ and Python, this is used to determine which kind of report to look up.
---@return nvim-neocov.CoverageFile? Path to the coverage file, or nil if no coverage file was found
M.find = function(src)
  local cfg = require("nvim-neocov.config").config
  if type(cfg.file) == "string" then
    vim.notify('Invalid type `string` for `nvim-neocov.Config.file` Did you mean `{ path = "' .. cfg.file .. '", kind = "..." }`?', vim.log.levels.ERROR)
    return nil
  elseif type(cfg.file) == "function" then
    return cfg.file(src)
  end

  ---@diagnostic disable-next-line: assign-type-mismatch
  ---@type nvim-neocov.CoverageFile[]
  local files = (#cfg.file > 0) and cfg.file or { cfg.file }
  for _, file in ipairs(files) do
    if file.path:find("%*") then
      -- Glob support
      ---@type string[]
      local matches = vim.fn.glob(file.path, false, true)
      if #matches > 0 then
        return { path = matches[1], kind = file.kind }
      end
    elseif vim.uv.fs_stat(file.path) then
      -- Regular path exists check
      return file
    end
  end

  return nil
end

--- Loads the coverage data and adds annotations the given buffers.
---@return nvim-neocov.Coverage?
M.load = function()
  -- Find
  if M.file == nil then
    M.file = M.find()
    if M.file == nil then return nil end
  end

  -- Load
  ---@diagnostic disable-next-line: need-check-nil
  local mtime = vim.uv.fs_stat(M.file.path).mtime.sec
  if mtime > M.mtime then
    M.coverage = require("nvim-neocov.config").config.parsers[M.file.kind](M.file.path)
    M.mtime = mtime
  end

  return M.coverage
end

--- Annotated buffer(s) with the most recently loaded coverage information.
---@param bufs? int|int[] Buffer(s) to annotate, or nil to annotate the currently visible buffers.
M.annotate = function(bufs)
  if M.coverage == nil then
    vim.notify('No coverage data was loaded (did you call `require("neocov").load()`)')
    return
  end

  if type(bufs) == "number" then
    bufs = { bufs }
  else
    bufs = bufs or require("nvim-neocov.util").get_file_bufs()
  end

  -- Annotate
  for _, buf in ipairs(bufs) do
    if not vim.tbl_contains(M.annotated, buf) then
      M.annotated[#M.annotated + 1] = buf
      require("nvim-neocov.annotate").buffer(buf, M.coverage)
    end
  end
end

---@param cov nvim-neocov.FileCoverage
---@return nvim-neocov.Summary
M._file_summary = function(cov)
  local summary = Summary:new()
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
  if M._file_summaries[file] ~= nil then
    return M._file_summaries[file]
  end

  -- Load
  local summary = Summary:new()

  if file == "" then
    -- Project Summary
    for _, cov in pairs(coverage.files) do
      local file_summary = M._file_summary(cov)
      summary = summary + file_summary
    end
  else
    -- File Summary
    if coverage.files[file] ~= nil then
      summary = M._file_summary(coverage.files[file])
    end
  end

  -- Cache
  M._file_summaries[file] = summary
  return summary
end

--- Clears all coverage annotations and disables the `autoload` feature.
M.clear = function()
  for _, buf in ipairs(M.annotated) do
    require("nvim-neocov.annotate").clear(buf)
  end
  vim.api.nvim_create_augroup("Neocov", { clear = true })

  M.annotated = {}
  M.mtime = 0
  M.file = nil
  M.coverage = nil
  M._summaries_coverage = nil
  M._file_summaries = {}
end

----------------------------------------------------------------------------------------
---@endsection
----------------------------------------------------------------------------------------

return M
