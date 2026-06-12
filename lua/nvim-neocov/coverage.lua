local cfg = require("nvim-neocov.config").config
local log = require("nvim-neocov.log")
local util = require("nvim-neocov.util")

---@class nvim-neocov.LineCoverage Coverage data for a single line
---@field branches int Number of branches on the line
---@field covered int Number of covered branches on the line
---@field execution_count int Number of times the line was executed

---@class nvim-neocov.FileCoverage Coverage data for a file.
---@field lines table<int, nvim-neocov.LineCoverage> Line coverage data, 1 indexed.

---@class nvim-neocov.CoverageFile File that coverage data can be loaded from.
---@field path string Path to the coverage file on disk.
---@field kind nvim-neocov.ParserKind Name of the parser to use when loading this coverage file.

---TODO(JON): This isn't close to having enough info for Summary
---@class nvim-neocov.Coverage Coverage data for multiple files.
---@field files table<string, nvim-neocov.FileCoverage> Coverage data for each file.
local Coverage = {}
Coverage.__index = Coverage

---@class nvim-neocov.CachedCoverageFile
---@field mtime int Time the coverage file was last modified on disk
---@field file nvim-neocov.CoverageFile

---@class nvim-neocov.CachedCoverage
---@field mtime int Time the last coverage file used to generate this coverage report was modified on disk
---@field data nvim-neocov.Coverage

---@class nvim-neocov.Cache
---@field files table<string, nvim-neocov.CachedCoverageFile>
---@field coverage table<string, nvim-neocov.CachedCoverage>

Coverage.new = function()
  local self = {
    files = {},
  }
  setmetatable(self, Coverage)
  return self
end

---@type nvim-neocov.Cache
Coverage.cache = {
  files = {},
  coverage = {},
}

--- Determines threshold of coverage for a line
---@param line_coverage nvim-neocov.LineCoverage
---@return nvim-neocov.ThresholdKind
Coverage.for_line = function(line_coverage)
  ---@type nvim-neocov.ThresholdKind
  local threshold = "nocode"
  if line_coverage.branches == 0 then
    threshold = "nocode"
  elseif line_coverage.covered == 0 then
    threshold = "uncovered"
  elseif line_coverage.covered < line_coverage.branches then
    threshold = "partial"
  elseif line_coverage.covered == line_coverage.branches then
    threshold = "covered"
  end
  return threshold
end

---Load a coverage report from using the cache
---@param src_file string Path to source file to look up coverage for
---@return nvim-neocov.Coverage?
Coverage.load = function(src_file)
  -- Ensure source file exists
  local src_mtime = util.mtime(src_file)
  if src_mtime == nil then
    log.infof('Source file "%s" does not exist', src_file)
    return nil
  end

  -- Look up what the corresponding coverage file should be
  local cached_file = Coverage.cache.files[src_file]
  if cached_file == nil then
    local cov_file = Coverage.find(src_file)
    if cov_file == nil then
      log.infof('Could not determine a corresponding coverage file for source "%s"')
      return nil
    end

    cached_file = {
      file = cov_file,
      mtime = 0,
    }
  end

  -- Ensure the coverage file exists on disk
  local cov_mtime = util.mtime(cached_file.file.path)
  if cov_mtime == nil or src_mtime > cov_mtime then
    if Coverage.generate(src_file, cached_file.file.kind, cached_file.file.path) == false then
      log.infof('Failed to generate coverage file "%s" for source "%s"', src_file)
      return nil
    else
      cov_mtime = util.mtime(cached_file.file.path)
      if cov_mtime == nil then
        log.infof('Generator did not produce coverage file "%s" for source "%s"', src_file)
        return nil
      end
    end
  end

  -- Return cached data or generate
  if cached_file.mtime >= cov_mtime then return Coverage.cache.coverage[cached_file.file.path].data end
  local coverage = Coverage.parse(cached_file.file.path, cached_file.file.kind, src_file)
  if coverage == nil then return nil end

  -- Store results in cache
  cached_file.mtime = cov_mtime
  Coverage.cache.coverage[cached_file.file.path] = {
    mtime = cov_mtime,
    data = coverage,
  }
  Coverage.cache.files[src_file] = cached_file

  return coverage
end

--- Clear the coverage cache
Coverage.unload = function()
  Coverage.cache.coverage = {}
  Coverage.cache.files = {}
end

--- Locates a coverage file on disk
---@param src string? File the corresponding coverage report is being requested for, or nil if for the full project. If your project contains both C++ and Python, this is used to determine which kind of report to look up.
---@return nvim-neocov.CoverageFile? Path to the coverage file, or nil if no coverage file was found
Coverage.find = function(src)
  if type(cfg.file) == "string" then
    log.errorf('Invalid type `string` for `nvim-neocov.Options.file` Did you mean `{ path = "%s", kind = "..." }`?', cfg.file)
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
      if #matches > 0 then return { path = matches[1], kind = file.kind } end
    elseif vim.uv.fs_stat(file.path) then
      -- Regular path exists check
      return file
    end
  end

  return nil
end

---@param coverage_file string Path to existing file containing coverage data
---@param kind nvim-neocov.ParserKind Name of parser to use
---@param source_file? string Code file coverage is being requested for
---@return nvim-neocov.Coverage
Coverage.parse = function(coverage_file, kind, source_file)
  local coverage = cfg.parsers[kind](coverage_file, source_file)
  vim.api.nvim_exec_autocmds("User", { pattern = "NeocovNewCoverageLoaded" })
  return coverage
end

---@param source_file string Code file coverage is being requested for
---@param kind nvim-neocov.ParserKind Name of parser to use
---@param coverage_file string Path to existing file containing coverage data
---@return boolean True for success, false for failure
Coverage.generate = function(source_file, kind, coverage_file) return false end

return Coverage
