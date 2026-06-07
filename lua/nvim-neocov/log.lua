local M = {}

---@alias nvim-neocov.LogLevel "trace" | "debug" | "info" | "warn" | "error" | "fatal"

---@class nvim-neocov.LevelCfg
---@field verbosity int Larger = more verbose
---@field hl string Highlight link to use for console logging

---@class nvim-neocov.LogOptions
---@field console boolean true to enable logging to :messages
---@field level string levels more verbose than this will not be logged

----------------------------------------------------------------------------------------
---@section Constants
----------------------------------------------------------------------------------------
---@type string Name of the logger
M.name = "nvim-neocov"

---@type nvim-neocov.LogOptions
M.config = {
  console = true,
  level = "debug",
}

--- Configuration for the various log levels
---@type table<nvim-neocov.LogLevel, nvim-neocov.LevelCfg>
M.levels = {
  fatal = {
    verbosity = 1,
    hl = "ErrorMsg",
  },
  error = {
    verbosity = 2,
    hl = "DiagnosticError",
  },
  warn = {
    verbosity = 3,
    hl = "DiagnosticWarn",
  },
  info = {
    verbosity = 4,
    hl = "DiagnosticInfo",
  },
  debug = {
    verbosity = 5,
    hl = "DiagnosticOk",
  },
  trace = {
    verbosity = 6,
    hl = "Comment",
  },
}
---@type string Where the plugin logs to, `~/.local/state/nvim/...log`
M.file = string.format("%s/%s.log", vim.fn.stdpath("log"), M.name)
---@type string Log message template `[LEVEL] [TIME] [FILE:LINE]: MESSAGE`
M.template = "[%-5s] [%s] [%s]: %s"

----------------------------------------------------------------------------------------
---@endsection
---@section Formatting Functions
----------------------------------------------------------------------------------------

---@return string Time of log message
M.time = function()
  return os.date("%H:%M:%S")
end

--- Gets the "file:line" of the given scope
---@param at? int Scope, 1 for current, 2 for frame below, etc.
---@return string file:line
M.file_line = function(at)
  at = at or 2
  local info = debug.getinfo(at, "Sl")
  if info == nil then return "?:?" end

  local file = info.short_src
  local start = file:find(vim.pesc(M.name .. "/lua"))
  if start ~= nil then
    file = "." .. file:sub(start + #M.name + #"/lua")
  end
  return file .. ":" .. tostring(info.currentline)
end

---@param x number to round
---@param increment number Decimal point to round to (e.g. 0.1, 0.01), 1 by default.
---@return number rounded
M.round = function(x, increment)
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)) * increment
end

---@param obj any Object to stringify
---@return string log-friendly string
M.stringify = function(obj)
  if type(obj) == "table" then
    return vim.inspect(obj)
  elseif type(obj) == "number" then
    return tostring(M.round(obj, 0.01))
  else
    return tostring(obj)
  end
end

--- Formats a log message
---@param level string Log level to log (verbosity ignored)
---@param msg string Diagnostic text to log
---@param at? int Scope, 1 for current, 2 for frame below, etc.
---@return string Formatted log message
M.format = function(level, msg, at)
  at = at or 5
  return string.format(M.template, level:upper(), M.time(), M.file_line(at), msg)
end

----------------------------------------------------------------------------------------
---@endsection
---@section Logging Functions
----------------------------------------------------------------------------------------

--- Appends a string to the log file
---@param str string to write to log file
M.to_file = function(str)
  local f = io.open(M.file, "a")
  if f == nil then return end
  f:write(str)
  f:write("\n")
  f:close()
end

--- Writes a string to the console (see `:messages`)
---@param level nvim-neocov.LogLevel Looks up highlight rule for console
---@param str string to write to console
M.to_console = function(level, str)
  ---@diagnostic disable-next-line: unnecessary-if
  if M.config.console ~= true then return end

  vim.cmd(str.format("echohl %s", M.levels[level].hl))

  local lines = vim.split(str, "\n")
  for _, line in ipairs(lines) do
    vim.cmd(string.format([[echom "[%s] %s"]], M.name, vim.fn.escape(line, '"')))
  end

  vim.cmd.echohl("NONE")
end

--- Writes comma-separated variables to the log
---@param level nvim-neocov.LogLevel
---@vararg Any lua objects
M.log = function(level, ...)
  if M.levels[level].verbosity > M.levels[M.config.level].verbosity then return end
  local msg = M.format(level, table.concat(vim.tbl_map(M.stringify, { ... }), " "))
  M.to_file(msg)
  M.to_console(level, msg)
end

--- Using @see string.format to format a log message
---@param level nvim-neocov.LogLevel
---@vararg Any lua objects
M.logf = function(level, fmt, ...)
  if M.levels[level].verbosity > M.levels[M.config.level].verbosity then return end
  local msg = M.format(level, string.format(fmt, ...))
  M.to_file(msg)
  M.to_console(level, msg)
end

M.trace = function(...)
  M.log("trace", ...)
end

M.debug = function(...)
  M.log("debug", ...)
end

M.info = function(...)
  M.log("info", ...)
end

M.warn = function(...)
  M.log("warn", ...)
end

M.error = function(...)
  M.log("error", ...)
end

M.fatal = function(...)
  M.log("fatal", ...)
end

M.tracef = function(fmt, ...)
  M.logf("trace", fmt, ...)
end

M.debugf = function(fmt, ...)
  M.logf("debug", fmt, ...)
end

M.infof = function(fmt, ...)
  M.logf("info", fmt, ...)
end

M.warnf = function(fmt, ...)
  M.logf("warn", fmt, ...)
end

M.errorf = function(fmt, ...)
  M.logf("error", fmt, ...)
end

M.fatalf = function(fmt, ...)
  M.logf("fatal", fmt, ...)
end

----------------------------------------------------------------------------------------
---@endsection
----------------------------------------------------------------------------------------

return M
