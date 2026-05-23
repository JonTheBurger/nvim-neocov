local ns = vim.api.nvim_create_namespace("nvim-neocov")
local m = -1

vim.api.nvim_create_user_command("JJ", function()
  m = vim.api.nvim_buf_set_extmark(0, ns, 2, 0, {
    strict = false,
    end_col = -1,
    -- right_gravity = false,
    -- end_right_gravity = false,
    invalidate = true,
    undo_restore = true,
    -- sign_text = "▏",
    -- sign_hl_group = "ErrorMsg",
    virt_text = {{"▏", "ErrorMsg"}},
    -- virt_text = {{"▕", "ErrorMsg"}},
    -- virt_text_pos = "eol_right_align",
    virt_text_pos = "inline",
    virt_text_repeat_linebreak = true,
  })
end, {})

vim.api.nvim_create_user_command("JK", function()
  local mark = vim.api.nvim_buf_get_extmark_by_id(0, ns, m, {details = true})
  vim.print(mark)
end, {})
