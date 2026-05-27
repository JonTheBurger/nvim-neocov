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

  if type(cfg.file) == "function" then
    return cfg.file(src)
  elseif type(cfg.file) == "table" and #cfg.file > 0 then
    --TODO(JON): vim.fn.glob("src/**/*.cpp", false, true)
    for _, file in ipairs(cfg.file) do
      if vim.uv.fs_stat(file) then
        return file
      end
    end
  elseif type(cfg.file) == "table" and type(cfg.file.path) == "string" then
    if vim.uv.fs_stat(cfg.file.path) then
      return cfg.file --[[@as nvim-neocov.CoverageFile]]
    end
  else
    vim.notify('Invalid type `' .. type(cfg.file) .. '` for nvim-neocov.Config.file. Did you mean `{ path = "...", kind = "..." }`?', vim.log.levels.ERROR)
  end

  return nil
end

--- Loads the coverage data and adds annotations for the given buffer
---@param bufs? int[] Buffers to annotate, or nil to annotate the currently visible buffers
M.load = function(bufs)
  bufs = bufs or require("nvim-neocov.util").get_file_bufs()

  if M.file == nil then
    local file = M.find()

    if file ~= nil then
      M.file = file
    else
      vim.notify("Could not find a coverage file!")
      return
    end
  end

  ---@diagnostic disable-next-line: need-check-nil
  local mtime = vim.uv.fs_stat(M.file.path).mtime.sec
  if mtime > M.mtime then
    M.coverage = require("nvim-neocov.config").config.parsers[M.file.kind](M.file.path)
    M.mtime = mtime

    for _, buf in ipairs(bufs) do
      require("nvim-neocov.annotate").buffer(buf, M.coverage)
    end
  end
end

--- Clears all coverage annotations.
M.clear = function()
  require("nvim-neocov.annotate").clear()
  M.mtime = 0
  M.file = nil
  M.coverage = nil
end

----------------------------------------------------------------------------------------
---@endsection
----------------------------------------------------------------------------------------

return M
