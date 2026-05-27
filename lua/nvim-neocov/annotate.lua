---Uses extmarks to annotate coverage information in a file
local M = {}

--- Namespace for marks
M.ns = vim.api.nvim_create_namespace("nvim-neocov")

---@type int[]
M.annotated = {}

--- Adds coverage annotations to a buffer
---@param buf int Buffer to annotate, 0 for the current buffer
---@param cov nvim-neocov.Coverage Coverage data
M.buffer = function(buf, cov)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
  local lines = cov.files[filename].lines
  for line = 1, vim.api.nvim_buf_line_count(buf) do
    if lines[line] ~= nil then
      M.add(buf, line, lines[line])
    else
      M.add(buf, line, { branches = 0, covered = 0 })
    end
  end

  -- Track the buffers we annotate
  if not vim.tbl_contains(M.annotated, buf) then
    M.annotated[#M.annotated + 1] = buf
  end
end

--- Remove all coverage annotations from the buffer
---@param bufs? int|int[] Buffer to clear, 0 for the current buffer, or nil for all buffers
M.clear = function(bufs)
  if bufs == nil then
    bufs = M.annotated
  elseif type(bufs) == "number" then
    bufs = { bufs }
  end

  for _, buf in ipairs(bufs) do
    vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
  end
end

--- Create an extmark for a given coverage line in the buffer
---@param buf int to annotate
---@param line int 1-indexed line in file
---@param data nvim-neocov.LineCoverage Line data to annotate with
---@param style? string|string[]|vim.api.keyset.set_extmark[] TODO(JON): Use config items
---@return int mark Handle to the created extmark
M.add = function(buf, line, data, style)
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
      { "▍", hl }
    },
    -- virt_text = {{"▕", "ErrorMsg"}},
    -- virt_text_pos = "eol_right_align",
    virt_text_pos = "inline",
    virt_text_repeat_linebreak = true,
  })
end

return M
