---Public API for nvim-neocov
local M = {}

----------------------------------------------------------------------------------------
---@section Globals
----------------------------------------------------------------------------------------

---@type nvim-neocov.Coverage? Most recently loaded coverage report.
M.coverage = nil

--TODO(JON): This only supports one report at a time. That doesn't work if you have C++ and python in the same codebase. Per-ft isn't perfect because C/C++ may share.
---@type nvim-neocov.CoverageFile? Path to file source for most recently loaded coverage report.
M.file = nil

---@type int? Modified time of the coverage file. Used to determine if a reload is necessary.
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
      local matches = vim.fn.glob(file.path, false, true)
      if #matches > 0 then
        return matches[1]
      end
    elseif vim.uv.fs_stat(file.path) then
      -- Regular path exists check
      return file
    end
  end

  return nil
end

--- Loads the coverage data and adds annotations the given buffers.
---@param bufs? int|int[] Buffer(s) to annotate, or nil to annotate the currently visible buffers.
M.load = function(bufs)
  if type(bufs) == "number" then
    bufs = { bufs }
  else
    bufs = bufs or require("nvim-neocov.util").get_file_bufs()
  end

  -- Find
  if M.file == nil then
    local file = M.find()
    if file ~= nil then
      M.file = file
    else
      return
    end
  end

  -- Load
  ---@diagnostic disable-next-line: need-check-nil
  local mtime = vim.uv.fs_stat(M.file.path).mtime.sec
  if mtime > M.mtime then
    M.coverage = require("nvim-neocov.config").config.parsers[M.file.kind](M.file.path)
    M.mtime = mtime
  end

  -- Annotate
  for _, buf in ipairs(bufs) do
    if not vim.tbl_contains(M.annotated, buf) then
      M.annotated[#M.annotated + 1] = buf
      require("nvim-neocov.annotate").buffer(buf, M.coverage)
    end
  end
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
end

----------------------------------------------------------------------------------------
---@endsection
----------------------------------------------------------------------------------------

return M
