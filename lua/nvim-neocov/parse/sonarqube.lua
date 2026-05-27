local M = {}

local toint = require("nvim-neocov.util").toint

---@param file any SonarQube XML <file> element
---@return nvim-neocov.LineCoverage[] line from element
M.parse_lines = function(file)
  local lines = {}
  if file.lineToCover == nil then return lines end

  local lines2cover = file.lineToCover
  if lines2cover._attr ~= nil then
    -- One XML element
    lines2cover = { lines2cover }
  end

  for _, line in ipairs(lines2cover) do
    local branches = 0
    local covered = 0

    if line._attr.branchesToCover == nil then
      branches = 1

      if line._attr.covered == "true" then
        covered = 1
      else
        covered = 0
      end
    else
      branches = toint(line._attr.branchesToCover)
      covered = toint(line._attr.coveredBranches)
    end

    lines[toint(line._attr.lineNumber)] = {
      branches = branches,
      covered = covered,
    }
  end

  return lines
end

--- Parse sonarqube xml
---@param cov string Coverage file being parsed.
---@param src? string Information about the file where this request originated.
---@return nvim-neocov.Coverage report parsed from the file.
M.parse = function(cov, src)
  local xml = require("nvim-neocov.xml").to_table(cov)

  ---@type nvim-neocov.Coverage
  local report = {
    files = {},
  }

  if xml.coverage == nil then
    vim.notify("Missing tag <coverage>", vim.log.levels.ERROR)
    return report
  end
  if xml.coverage.file == nil then
    vim.notify("Missing tag <file>", vim.log.levels.ERROR)
    return report
  end
  if xml.coverage._attr.version ~= "1" then
    vim.notify("Unsupported SonarQube XML verison: " .. tostring(xml.coverage._attr.version) .. " expected 1", vim.log.levels.ERROR)
    return report
  end

  local files = xml.coverage.file
  if files._attr ~= nil then
    -- One XML element
    files = { files }
  end

  for _, file in ipairs(files) do
    report.files[file._attr.path] = { lines = M.parse_lines(file) }
  end

  return report
end

return M
