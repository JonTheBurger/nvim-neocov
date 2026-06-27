# Neocov

🚧 Under Construction! 🚧

![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?logo=lua)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/jontheburger/nvim-neocov/ci.yml?branch=master)

A comprehensive code coverage plugin for NeoVim.

- [Features](#features)
    - [Formats](#formats)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
    - [Commands](#commands)
    - [API](#api)
- [Cookbook](#cookbook)
    - [Lualine](#lualine)
    - [Overseer](#overseer)
    - [NeoTest](#neotest)
- [Special Thanks](#cookbook)

# Features

### Line Decorations

### Branch Counts

### Summary

### Jump to Next/Previous Uncovered Line

### Quick Fix List

## Formats

| Format        | Reference        |
| ------------- | ------------------- |
| `sonarqube` |  |

# Installation

## [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "jontheburger/nvim-neocov",
  dependencies = {
    "nvim-neotest/nio",
  },
  ---@type nvim-neocov.Options
  opts = {
    -- See the Configuration section below
  },
  keys = {
    { "]u", TODO, desc = "Next uncovered line" },
    { "[u", TODO, desc = "Previous uncovered line" },
  },
  cmd = { "Neocov" },
}
```

## [vim.pack](https://neovim.io/doc/user/pack/#vim.pack-examples)

```lua

```

# Configuration

Configure plugin options by either calling `require("nvim-neocov").setup({...})`
or setting `vim.g.nvim_neocov = {...}` before plugin load.

```lua
-- These are the defaults - you do not need to specify these.
---@type nvim-neocov.Options
{

}
```

# Usage

Neocov provides a lot of flexibility to accommodate different coverage workflows.
Populating NeoVim with coverage information requires 2-3 steps:

1. Generate the coverage file(s). *This isn't necessary for every language.*†
2. Load the coverage file(s) into a common format Neocov recognizes.
3. Annotate Neovim buffers with the coverage information.

> [!TIP]
> † Generate entails running a command to post-process raw coverage data
> emitted by a unit test. For example, `gcov(r)` must post-process `.gcda`
> files. Some coverage tools like `coverage.py` can automatically generate
> coverage files upon running a test, obviating this step.

Each of these steps execute asynchronously.

## Commands

This plugin provides the `Neocov` EX Command with sub-commands:

| Command                  | Description                                      |
| ------------------------ | ------------------------------------------------ |
| `Neocov `        | ``                                  |


## API

For design notes, see [CONTRIBUTING.md](/CONTRIBUTING.md).

# Cookbook

This section details 3rd party integrations and useful snippets.

## Lualine

## Overseer

## NeoTest

## Noice

```lua
require("noice").setup({
  routes = {
    {
      -- Catch notifications containing our custom progress flag
      filter = {
        event = "notify",
        cond = function(msg)
          return msg.opts and msg.opts.progress == true
        end,
      },
      -- Skip adding these updates to the :Noice history list
      opts = { skip = true },
    },
  },
})
```

# Third-party licenses

This plugin includes [xml2lua](https://github.com/manoelcampos/xml2lua) by
Manoel Campos, licensed under the [MIT License](lua/nvim-neocov/external/xml2lua/LICENSE).

--------------------------------------------------------------------------------

- vim.prit(vim.fn.expand("%:.")) == vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
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

# Test
- neotest integration
- Handle file paths in coverage not matching nvim paths

# TODO
- Noice spinner
- Calling Neocov mutliple times annotates multiple times
- vim.notify progress
- Locking for generating code coverage (do not try and generate an output file while it is already being generated)
    - User-invoked should probably override this, e.g. opts = opts or { force = true }
- Multiple files, coverage per-file, etc.
- Report
- Decision coverage
- lcov

# Refactor
- Hoist nio.create into init.lua, make all others @async
- Use require("nvim-neocov.config").get() instead of config.config
- Move all of the `nvim-neocov` modules to `neocov`
- Annotate @private
- More ergonomic config
- Use file_exists function instead of `mtime` and `fs_stat`

## Overseer

-- -- Safely check if overseer is installed before registering
-- local has_overseer, overseer = pcall(require, "overseer")
-- if has_overseer then
--   -- Registers your file via its subpath format
--   overseer.register_template("neocov.generate")
-- end

-- User's Neovim configuration file
-- require("overseer").setup({
--   templates = { "builtin", "neocov.generate" },
-- })

-- local overseer = require("overseer")

-- overseer.add_template_hook({
--   -- Filter by the template provider module name (your plugin path)
--   module = "neocov.generate",
--   -- Or filter strictly by the name defined inside your template file
--   name = "NeoCov: Generate Coverage",
-- }, function(task_defn, util)
--   -- 1. Completely overwrite your components array
--   task_defn.components = { "default", { "on_complete_notify", statuses = { "SUCCESS" } } }
--
--   -- 2. Alternatively, use helper utilities to append components instead of erasing them
--   util.add_component(task_defn, { "on_output_quickfix", open = true })
--
--   -- 3. Or remove a specific component you bundled
--   util.remove_component(task_defn, "on_output_write_file")
-- end)

-- local overseer = require("overseer")
--
-- overseer.add_template_hook({
--   -- Catch tasks generated by the neotest overseer strategy adapter
--   module = "neotest",
-- }, function(task_defn, util)
--   -- Append a custom inline component to handle post-execution logic
--   util.add_component(task_defn, {
--     "on_complete",
--     on_complete = function(self, task)
--       -- Check if the tests passed successfully
--       if task.status == "SUCCESS" then
--         -- Run your coverage task using its registered module identifier
--         overseer.run_template({ name = "neocov.generate" }, function(cov_task)
--           if cov_task then
--             -- Optional: configure behavior when the coverage task runs
--           else
--             vim.notify("Failed to initiate neocov template", vim.log.levels.WARN)
--           end
--         end)
--       end
--     end,
--   })
-- end)

# Neotest
-- require("neotest").setup({
--   consumers = {
--     coverage = require("neotest.consumers.nvim-neocov"),
--   },
-- })

