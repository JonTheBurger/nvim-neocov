local Coverage = require("nvim-neocov.coverage")
local log = require("nvim-neocov.log")

---Uses extmarks to annotate coverage information in a file
local M = {}

--- Namespace for marks
M.ns = vim.api.nvim_create_namespace("Neocov")

--- List of buffers that have been annotated
---@type table<int, bool> Hash key  = true to indicate a buffer is annotated
M.cache = {}

---Gets the foreground highlight color warranted by a line's coverage
---@type table<nvim-neocov.ThresholdKind, string>
M.fg = {
  nocode = "NeocovFgNoCode",
  uncovered = "NeocovFgUncovered",
  partial = "NeocovFgPartial",
  covered = "NeocovFgCovered",
}

---Gets the background highlight color warranted by a line's coverage
---@type table<nvim-neocov.ThresholdKind, string>
M.bg = {
  nocode = "NeocovBgNoCode",
  uncovered = "NeocovBgUncovered",
  partial = "NeocovBgPartial",
  covered = "NeocovBgCovered",
}

--- Defines the Neocov plugin highlights.
M.load_highlights = function()
  vim.api.nvim_set_hl(0, "NeocovThresholdTerrible", { link = "DiagnosticError" })
  vim.api.nvim_set_hl(0, "NeocovThresholdBad", { link = "DiagnosticError" })
  vim.api.nvim_set_hl(0, "NeocovThresholdOk", { link = "DiagnosticWarn" })
  vim.api.nvim_set_hl(0, "NeocovThresholdGood", { link = "DiagnosticOk" })
  vim.api.nvim_set_hl(0, "NeocovThresholdPerfect", { link = "DiagnosticInfo" })

  vim.api.nvim_set_hl(0, "NeocovFgUncovered", { link = "DiagnosticError" })
  vim.api.nvim_set_hl(0, "NeocovFgPartial", { link = "DiagnosticWarn" })
  vim.api.nvim_set_hl(0, "NeocovFgCovered", { link = "DiagnosticOk" })
  vim.api.nvim_set_hl(0, "NeocovFgNoCode", { link = "Normal" })

  local util = require("nvim-neocov.util")
  local blend = 0.20
  local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg or 0
  local fg = 0

  fg = vim.api.nvim_get_hl(0, { name = "NeocovFgUncovered", link = false }).fg or bg
  vim.api.nvim_set_hl(0, "NeocovBgUncovered", { bg = util.blend(fg, bg, blend) })
  fg = vim.api.nvim_get_hl(0, { name = "NeocovFgPartial", link = false }).fg or bg
  vim.api.nvim_set_hl(0, "NeocovBgPartial", { bg = util.blend(fg, bg, blend) })
  fg = vim.api.nvim_get_hl(0, { name = "NeocovFgCovered", link = false }).fg or bg
  vim.api.nvim_set_hl(0, "NeocovBgCovered", { bg = util.blend(fg, bg, blend) })
  fg = vim.api.nvim_get_hl(0, { name = "NeocovFgNoCode", link = false }).fg or bg
  vim.api.nvim_set_hl(0, "NeocovBgNoCode", { bg = util.blend(fg, bg, blend) })
end

--- Adds coverage annotations to one or more buffers. Already annotated buffers are ignored, @see unload
---@param bufs? int|int[] Buffer to annotate, 0 for the current buffer, nil for all loaded buffers.
---@param cov nvim-neocov.Coverage Coverage data
---@param decorations table<nvim-neocov.ThresholdKind, nvim-neocov.Decoration[]> Style rules
M.buffer = function(bufs, cov, decorations)
  bufs = require("nvim-neocov.util").get_file_bufs(bufs)

  for _, buf in ipairs(bufs) do
    if vim.api.nvim_buf_is_loaded(buf) and M.cache[buf] == nil then
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
      if cov.files[filename] == nil then return end

      local lines = cov.files[filename].lines
      for line = 1, vim.api.nvim_buf_line_count(buf) do
        local threshold = Coverage.for_line(lines[line] or { branches = 0, covered = 0, execution_count = 0 })
        M.mark(buf, line, {
          fg = M.fg[threshold],
          bg = M.bg[threshold],
        }, decorations[threshold])
      end
      M.cache[buf] = true
    else
      log.tracef("Attempted to annotate invalid buffer %d", buf)
      M.unload(buf)
    end
  end
end

--- Remove all coverage annotations from the given buffer
---@param bufs? int|int[] Buffer to clear annotations from, 0 for the current buffer, nil for all loaded buffers.
M.clear = function(bufs)
  M.unload(bufs)
  bufs = require("nvim-neocov.util").get_file_bufs(bufs)

  for _, buf in ipairs(bufs) do
    if vim.api.nvim_buf_is_loaded(buf) then
      vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
    else
      log.tracef("Attempted to de-annotate invalid buffer %d", buf)
    end
  end
end

--- Remove a buffer from the list of cached annotations
---@param bufs? int|int[] Buffer to clear annotations from, 0 for the current buffer, nil for all loaded buffers.
M.unload = function(bufs)
  if bufs == nil then
    M.cache = {}
  else
    bufs = require("nvim-neocov.util").get_file_bufs(bufs)
    for _, buf in ipairs(bufs) do
      M.cache[buf] = nil
    end
  end
end

--- Create extmarks for a given coverage line in the buffer
---@param buf int to annotate
---@param line int 1-indexed line in file
---@param hl nvim-neocov.Highlight Highlight group to apply
---@param decorations nvim-neocov.Decoration[] Style rules
---@return int[] marks Handles to the created extmarks
M.mark = function(buf, line, hl, decorations)
  local marks = {}
  for _, decore in ipairs(decorations) do
    ---@type vim.api.keyset.set_extmark
    local opts = {
      end_row = line,
      invalidate = true,
      sign_hl_group = hl.fg,
      strict = false,
      undo_restore = true,
      virt_text_repeat_linebreak = true,
    }

    if decore.kind == "sign" then
      opts.sign_text = decore.text or "▍"
    elseif decore.kind == "virt_text" then
      opts.virt_text = { { (decore.text or "▍"), (hl.fg or "Normal") } }
      opts.virt_text_pos = decore.pos or "inline"
    elseif decore.kind == "highlight" then
      opts.hl_mode = "blend"
      opts.hl_group = hl.bg or "Normal"
      opts.hl_eol = decore.hl_eol or true
    end

    if decore.kind ~= nil then marks[#marks + 1] = vim.api.nvim_buf_set_extmark(buf, M.ns, line - 1, 0, opts) end
  end
  return marks
end

return M
