local cfg = require("nvim-neocov.config").config

---@type overseer.TemplateFileDefinition
---@module "overseer.template"
return {
  name = "neocov: generate coverage",
  desc = "Generate coverage for a file and then load and annotate affected files",
  tags = { "TEST" },
  condition = {
    filetype = cfg.ft or nil,
  },
  params = {
    annotate = {
      desc = "Annotate open buffers after generating the coverage",
      type = "boolean",
      default = true,
    },
    file = {
      desc = "Source file to generate coverage for",
      type = "string",
    },
  },
  builder = function(params)
    local fullpath = vim.fn.fnamemodify(params.file or vim.fn.expand("%"), ":p")
    if require("nvim-neocov.util").mtime(fullpath) == nil then
      return { cmd = { "echo", string.format('Cannot generate coverage for non-existent file "%s"', fullpath) } }
    end

    local cmd = cfg.cmd(fullpath)
    if cmd == nil then return { cmd = { "echo", string.format('Ignoring coverage request for "%s"', fullpath) } } end

    local components = { "default" }
    if params.annotate then table.insert(components, 1, { "neocov.on_complete_coverage", file = fullpath }) end

    require("nvim-neocov.log").debug("Staring generate coverage task for", fullpath)
    ---@module "overseer.task"
    ---@type overseer.TaskDefinition
    return {
      name = "Generate Coverage for " .. vim.fn.fnamemodify(fullpath, ":t"),
      cmd = cmd.cmd,
      cwd = cmd.cwd,
      env = cmd.env,
      components = components,
      metadata = {},
    }
  end,
}
