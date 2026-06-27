local M = {}

local nio = require("nio")
local util = require("nvim-neocov.util")

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
    nio.sleep(5)
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
      branches = util.toint(line._attr.branchesToCover)
      covered = util.toint(line._attr.coveredBranches)
    end

    lines[util.toint(line._attr.lineNumber)] = {
      branches = branches,
      covered = covered,
    }
  end

  return lines
end

--- Parse sonarqube xml
---@param cov string Coverage file being parsed.
---@return nvim-neocov.Coverage report parsed from the file.
M.parse = function(cov)
  local spinner = util.spinner("Generating sonar coverage")
  local xml = require("nvim-neocov.xml").to_table(cov)

  ---@type nvim-neocov.Coverage
  local report = {
    files = {},
  }

  if xml.coverage == nil then
    vim.notify("Neocov sonarqube: " .. cov .. " Missing tag <coverage>", vim.log.levels.ERROR)
    return report
  end
  if xml.coverage.file == nil then
    vim.notify("Neocov sonarqube: " .. cov .. " Missing tag <file>", vim.log.levels.ERROR)
    return report
  end
  if xml.coverage._attr.version ~= "1" then
    vim.notify(
      "Neocov sonarqube: "
        .. cov
        .. " Unsupported SonarQube XML verison: "
        .. tostring(xml.coverage._attr.version)
        .. " expected 1",
      vim.log.levels.ERROR
    )
    return report
  end

  local files = xml.coverage.file
  if files._attr ~= nil then
    -- One XML element
    files = { files }
  end

  for _, file in ipairs(files) do
    report.files[util.to_abspath(file._attr.path)] = { lines = M.parse_lines(file) }
    nio.sleep(0)
  end

  spinner()
  return report
end

return M
