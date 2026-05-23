local M = {}

M.ns = vim.api.nvim_create_namespace("nvim-neocov")

--- Create an extmark for a given coverage line in the buffer
---@param buf int to annotate
---@param row int 1-indexed line in file
---@param line nvim-neocov.Line Line data to annotate with
---@return int mark Handle to the created extmark
M.add = function(buf, row, line)

  local hl = "LspInlayHint"

  if line.covered == 0 and line.branches == 0 then
    hl = "OkMsg"
  elseif line.covered == 0 and line.branches > 0 then
    hl = "ErrorMsg"
  elseif line.covered < line.branches then
    hl = "WarningMsg"
  elseif line.covered == line.branches then
    hl = "OkMsg"
  end

  return vim.api.nvim_buf_set_extmark(buf, M.ns, row - 1, 0, {
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

--- Adds coverage annotations to a buffer
---@param buf int Buffer to annotate, 0 for the current buffer
---@param cov nvim-neocov.Report Coverage data
M.file = function(buf, cov)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
  local lines = cov.files[filename].lines
  for row = 1, vim.api.nvim_buf_line_count(buf) do
    if lines[row] ~= nil then
      M.add(buf, row, lines[row])
    else
      M.add(buf, row, {
        branches = 0,
        covered = 0,
      })
    end
  end
end

M.clear = function(buf)
end

return M
