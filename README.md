
--------------------------------------------------------------------------------

- vim.print(vim.fn.expand("%:.")) == vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
- vim.filetype.match({ filename = "/path/to/file.cpp" })
- vim.fn.bufnr("/path/to/file")
    - if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then

- Autocommand load coverage
- Formats
- Hover
- End of line annotations
- Neotest integration
    - command to run coverage
    - find file again after test runs
- Custom report style?
- Multiple branch coverage thresholds?
- Show 1/2 (branch coverage)?
- lualine/components (see overseer for an example?)
