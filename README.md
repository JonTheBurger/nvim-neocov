
--------------------------------------------------------------------------------

- vim.filetype.match({ filename = src_file })

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

- gcov -s /home/jon/Projects/c -lgxp CMakeFiles/ehsh.dir/src/ehsh.c.gcda
- -fprofile-abs-path -fcondition-coverage

# TODO
- Annotation Styles
- Multiple files, coverage per-file, etc.
- Hover for coverage report
- Evaluate `xq` instead of xml2lua (use nio and vim.json.decode())
- Overseer integration
- neotest integration
