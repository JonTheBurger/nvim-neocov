--------------------------------------------------------------------------------

- vim.filetype.match({ filename = src_file })

- vim.print(vim.fn.expand("%:.")) == vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
- vim.filetype.match({ filename = "/path/to/file.cpp" })
- vim.fn.bufnr("/path/to/file")

- Autocommand load coverage
- Hover execution counts
- Neotest integration
    - command to run coverage
    - find file again after test runs
- Custom report style?

- gcov -s /home/jon/Projects/c -lgxp CMakeFiles/ehsh.dir/src/ehsh.c.gcda
- -fprofile-abs-path -fcondition-coverage

# TODO
- Hover report
- Multiple files, coverage per-file, etc.
- Hover for coverage report
- Evaluate `xq` instead of xml2lua (use nio and vim.json.decode())
- Overseer integration
- neotest integration

