---@meta
---See: https://luals.github.io/wiki/definition-files/
-- luacheck: ignore 631 (line-too-long)

---@alias nvim-neocov.Scope "conditions" | "branches" | "lines" | "blocks" | "functions" | "files" | string
---@alias nvim-neocov.ParserKind "clover" | "cobertura" | "gcov-json" | "gcov" | "jacoco" | "lcov" | "sonarqube" | string
---@alias nvim-neocov.ThresholdKind "covered" | "partial" | "uncovered" | "nocode"

---@alias nvim-neocov.VirtTextPos "eol" | "eol_right_align" | "overlay" | "right_align" | "inline" Where virtual text should be displayed
---@alias nvim-neocov.DecorationKind # How a coverage line should be annotated.
---| "sign" # Use the sign column - does not move when text is updated.
---| "virt_text" # Use virtual text extmarks - move as text is updated.
---| "highlight" # Highlight the line.
---| "branch" # Adds branch count virtual text at the end of lines containing branches.

---@class nvim-neocov.Highlight
---@field fg? string Foreground-only highlight, or the name of another highlight to link to.
---@field bg? string Background-only highlight, or the name of another highlight to link to.
---@field hl? string Background+Foreground highlight, or the name of another highlight to link to.

---@class nvim-neocov.Decoration Annotation style used to display coverage.
---@field kind? nvim-neocov.DecorationKind How a coverage line should be annotated. Nil to not decorate.
---@field text? string When `kind` is "sign", "virt_text", or "branch", denotes gutter symbol; should not exceed 2 characters.
---@field pos? nvim-neocov.VirtTextPos When `kind` is "virt_text", denotes position of rendered virtual text.
---@field hl_eol? boolean When `kind` is "highlight", `true` (default) continues highlighting until the edge of the window, `false` highlights only the text.

---@class nvim-neocov.CoverageCommand
---@field cmd string[]|string Command + arguments to run; when a string is provided it is executed as a shell command
---@field cwd? string Directory to run the command from
---@field env? table<string, string> Environment variables to append (or overwrite) when executing the coverage command

---@class nvim-neocov.Options.Style User-configurable display options.
---@field decorations? table<nvim-neocov.ThresholdKind, nvim-neocov.Decoration[]> Style(s) to use when annotating a covered line. Set to `{}` to erase.

---@class nvim-neocov.Options User-configurable options
---TODO(JON): Should this be per-ft?
---@field file? nvim-neocov.CoverageFile|nvim-neocov.CoverageFile[]|fun(src: string?): nvim-neocov.CoverageFile Path(s) or function used to find path(s) to the coverage report.
---@field cmd? fun(src: string?): nvim-neocov.CoverageCommand Command used to generate coverage for a file. If file is nil, generates for the full project
---@field ft? string[] Supported file types.
---@field style? nvim-neocov.Options.Style How coverage data should be displayed
---@field parsers? table<string, fun(cov: string): nvim-neocov.Coverage> Additional custom parsers. We recommend naming these in ALL_CAPS to avoid name clashes.
---@field path_cmp? fun(abspath: string, covpath: string): boolean Compares absolute paths on disk to paths referenced in a coverage report. Coverage reports may use paths relative to cwd where coverage was generated, output file path, input file path, etc.
---@field autoload? string[] filetypes to auto-load coverage data for, use `:set filetype?` to detect for a given file.

---TODO(JON): Re-copy when done
---@class nvim-neocov.Config.Style Resolved display options.
---@field decorations table<nvim-neocov.ThresholdKind, nvim-neocov.Decoration[]> Style(s) to use when annotating a covered line. Set to `{}` to erase.

---TODO(JON): Re-copy when done
---@class nvim-neocov.Config Resolved options.
---@field file nvim-neocov.CoverageFile|nvim-neocov.CoverageFile[]|fun(src: string?): nvim-neocov.CoverageFile Path(s) or function used to find path(s) to the coverage report.
---@field cmd fun(src: string?): nvim-neocov.CoverageCommand? Command used to generate coverage for a file. If file is nil, generates for the full project. If a nil command is returned, no suitable coverage command was found.
---@field ft string[] Supported file types
---@field style nvim-neocov.Config.Style How coverage data should be displayed
---@field autoload string[] filetypes to auto-load coverage data for, use `:set filetype?` to detect for a given file.
---@field parsers table<string, fun(cov: string): nvim-neocov.Coverage> Additional custom parsers. We recommend naming these in ALL_CAPS to avoid name clashes.

---@class nvim-neocov.Threshold
---@field percent number Percentage threshold for this highlight to apply.
---@field hl nvim-neocov.Highlight

---@class nvim-neocov.LuaLineOptions
---@field layouts string[] List of layouts to switch between when clicked on. A layout contains dollar-brace delimited `${<scope-name>}`s, @see nvim-neocov.Scope.
---@field empty_layout string String to display when no coverage data is loaded.
---@field formats table<nvim-neocov.Scope, string> The way each type of scope should be formatted, default. `%C/%T (%.1f%%)` @see nvim-neocov.Ratio.format.
---@field thresholds nvim-neocov.Threshold[] How to highlight >= a given percentage.
---@field icons table<nvim-neocov.Scope, string> Icons to show when icons are enabled.
---@field no_icons table<nvim-neocov.Scope, string> "Icons" to show when icons are disabled.

---TODO(JON): Supported fts
--@field watch? int Controls how frequently the "watch" command checks if the coverage file changed, in milliseconds. If 0 is supplied, a filesystem watcher is used instead.
--@field report? fun(src: string?, verbatim: boolean): string Function used to find the overall coverage report. If verbatim is true, the report will be loaded as-is. Otherwise, it will be parsed.
--@field eq? fun(string, string): boolean Function used to compare files mentioned in the coverage file with absolute paths on disk. If a coverage file only contains relative paths, you may need to normalize the 2 arguments and compare them as true.

--@alias nvim-neocov.ReportWin '"hover"' | '"horizontal"' | '"vertical"'
--@field report_win? ReportWin How a full coverage report should be displayed (hover, or in a split).
--@field report_width? float How wide a floating report or vertical split report should be, in percent (up to 100.0).
--@field report_height? float How tall a floating report or horizontal split report should be, in percent (up to 100.0).
