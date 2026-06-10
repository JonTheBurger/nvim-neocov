local log = require("nvim-neocov.log")

---Uses extmarks to annotate coverage information in a file
local M = {}

--- Namespace for marks
M.ns = vim.api.nvim_create_namespace("Neocov")

--- List of buffers that have been annotated
---@type table<int, bool> Hash key  = true to indicate a buffer is annotated
M.cache = {}

--- Adds coverage annotations to one or more buffers
---@param bufs? int|int[] Buffer to annotate, 0 for the current buffer, nil for all loaded buffers.
---@param cov nvim-neocov.Coverage Coverage data
M.buffer = function(bufs, cov)
  bufs = require("nvim-neocov.util").get_file_bufs(bufs)

  for _, buf in ipairs(bufs) do
    if vim.api.nvim_buf_is_loaded(buf) and M.cache[buf] == nil then
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
      if cov.files[filename] == nil then return end

      local lines = cov.files[filename].lines
      for line = 1, vim.api.nvim_buf_line_count(buf) do
        if lines[line] ~= nil then
          M.mark(buf, line, lines[line])
        else
          M.mark(buf, line, { branches = 0, covered = 0, execution_count = 0 })
        end
      end
      M.cache[buf] = true
    else
      log.tracef("Attempted to annotate invalid buffer %d", buf)
      --TODO(JON): bwipeout event should probably M.unload(buf)
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

--- Create an extmark for a given coverage line in the buffer
---@param buf int to annotate
---@param line int 1-indexed line in file
---@param data nvim-neocov.LineCoverage Line data to annotate with
---@param style? string|string[]|vim.api.keyset.set_extmark[] TODO(JON): Use config items
---@return int mark Handle to the created extmark
M.mark = function(buf, line, data, style)
  local hl = "LspInlayHint"

  if data.branches == 0 then
    hl = "NeocovNoCode"
  elseif data.covered == 0 then
    hl = "NeocovUncovered"
  elseif data.covered < data.branches then
    hl = "NeocovPartial"
  elseif data.covered == data.branches then
    hl = "NeocovCovered"
  end

  return vim.api.nvim_buf_set_extmark(buf, M.ns, line - 1, 0, {
    strict = false,
    end_col = -1,
    -- right_gravity = false,
    -- end_right_gravity = false,
    invalidate = true,
    undo_restore = true,
    -- sign_text = "▏",
    -- sign_hl_group = "ErrorMsg",
    virt_text = {
      { "▍", hl },
    },
    -- virt_text = {{"▕", "ErrorMsg"}},
    -- virt_text_pos = "eol_right_align",
    virt_text_pos = "inline",
    virt_text_repeat_linebreak = true,
  })
end

return M
