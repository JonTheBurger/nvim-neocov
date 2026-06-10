local M = require("lualine.component"):extend()

local log = require("nvim-neocov.log")

--- Singleton instance of the lualine component
M.component = nil

--- Default on-click behavior
---@param _clicks int Number of clicks (e.g. 1 for single click, 2 for double click)
---@param button "l" | "r" | "m" Left, right, or middle click
---@param _modifiers string "    " 4 character string containing modifiers, e.g. 'a' for alt
function M.on_click(_clicks, button, _modifiers)
  local self = M.component
  if self == nil then return end

  if button == "l" then
    if self.layout_idx == #self.options.layouts then
      self.layout_idx = 1
    else
      self.layout_idx = self.layout_idx + 1
    end
  elseif button == "r" then
    vim.notify("Neocov Reloading")
    --TODO(JON): reload
  end
end

---@module "nvim-neocov"
---@type nvim-neocov.LuaLineOptions
local default_options = {
  layouts = {
    "${branches}",
    "${lines}",
    "${functions}"
  },
  empty_layout = "cov 󱔢",
  --TODO(JON): Percent %% isn't working?
  formats = {
    conditions = "%C/%T (%.1f%%)",
    branches = "%C/%T (%.1f%%)",
    lines = "%C/%T (%.1f%%)",
    blocks = "%C/%T (%.1f%%)",
    functions = "%C/%T (%.1f%%)",
    files = "%C/%T (%.1f%%)",
  },
  thresholds = {
    {
      percent = 0,
      hl = {
        fg = "NeocovThresholdTerrible",
      },
    },
    {
      percent = 30,
      hl = {
        fg = "NeocovThresholdBad",
      },
    },
    {
      percent = 60,
      hl = {
        fg = "NeocovThresholdOk",
      },
    },
    {
      percent = 80,
      hl = {
        fg = "NeocovThresholdGood",
      },
    },
    {
      percent = 100,
      hl = {
        fg = "NeocovThresholdPerfect",
      },
    },
  },
  icons = {
    conditions = "󰅲",
    branches = "",
    lines = "󰯟",
    blocks = "󰅩",
    functions = "󰊕",
    files = "",
  },
  no_icons = {
    conditions = "conds",
    branches = "branch",
    lines = "lines",
    blocks = "block",
    functions = "funcs",
    files = "files",
  },
  -- Inherited options
  on_click = M.on_click,
  icons_enabled = true,
}

function M:init(options)
  options = vim.tbl_deep_extend("keep", options or {}, default_options)
  -- Ensure thresholds are in descending order
  M.super.init(self, options)
  self.layout_idx = 1
  self.highlights = {}

  ---@type nvim-neocov.LuaLineOptions
  local opts = self.options
  log.trace(opts)

  for _, thresh in pairs(opts.thresholds) do
    -- Resolve highlight links
    local fg = vim.api.nvim_get_hl(0, { name = thresh.hl.fg }).fg or thresh.hl.fg
    if type(fg) == "number" then fg = string.format("#%06x", fg) end

    local bg = vim.api.nvim_get_hl(0, { name = thresh.hl.bg }).bg or thresh.hl.bg
    if type(bg) == "number" then bg = string.format("#%06x", bg) end

    self.highlights[#self.highlights + 1] = {
      percent = thresh.percent,
      hl = self:create_hl({
        fg = fg,
        bg = bg,
      }, "threshold_" .. thresh.percent),
    }
  end
  -- Sort in ascending order by percent
  table.sort(self.highlights, function(lhs, rhs) return lhs.percent > rhs.percent end)

  M.component = self
end

--- custom function
---@param percent number Percentage to look up
---@return any? Highlight
function M:get_highlight(percent)
  local highlights = self.highlights
  for _, rule in ipairs(highlights) do
    if percent >= rule.percent then return rule.hl end
  end
  return nil
end

function M:update_status()
  local neocov = require("nvim-neocov")
  if self.options == nil or neocov.coverage == nil then return "" end
  ---@type nvim-neocov.LuaLineOptions
  local opts = self.options

  --TODO(JON): We should not force load summary here, we need a cached summary
  local file = vim.fn.expand("%:~:.")
  local summary = neocov.summary(neocov.coverage, file)

  local rep = opts.layouts[self.layout_idx] or ""
  for _, scope in ipairs(neocov.scope_names) do
    -- Get per-percentage highlighting
    local fmt = ""
    local eof = ""
    local hl = self:get_highlight(summary[scope]:percent())
    if hl then
      fmt = self:format_hl(hl)
      eof = self:get_default_hl()
    end

    local part, substitutions = rep:gsub("${" .. scope .. "}", opts.icons[scope] .. " " .. summary[scope]:format(opts.formats[scope]))
    if substitutions > 0 then
      rep = fmt .. part .. eof
    end
  end

  return rep
end

return M
