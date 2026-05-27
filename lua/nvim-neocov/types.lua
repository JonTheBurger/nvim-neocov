---@meta
---See: https://luals.github.io/wiki/definition-files/
-- luacheck: ignore 631 (line-too-long)

---@alias nvim-neocov.MarkerKind '"sign"' | '"virt_text"' | '"both"' | string
---@alias nvim-neocov.ParserKind '"clover"' | '"cobertura"' | '"gcov-json"' | '"gcov"' | '"gcovr-csv"' | '"jacoco"' | '"lcov"' | '"sonarqube"'
---@alias nvim-neocov.ReportWin '"hover"' | '"horizontal"' | '"vertical"'
---@alias nvim-neocov.Threshold '"covered"' | '"partial"' | '"uncovered"' | '"nocode"'
---@alias nvim-neocov.VirtTextPos '"inline"' | '"right_align"' | string

---@class nvim-neocov.Annotation Decoration used to display coverage.
---@field text string Text used to annotate the coverage on the line. Should not exceed 2 characters.
---@field hl string Color of the annotation text.

---@class nvim-neocov.Options.Style User-configurable display options.
---@field report_win? ReportWin How a full coverage report should be displayed (hover, or in a split).
---@field report_width? float How wide a floating report or vertical split report should be, in percent (up to 100.0).
---@field report_height? float How tall a floating report or horizontal split report should be, in percent (up to 100.0).
---@field marker_kind? nvim-neocov.MarkerKind Controls how coverage lines are annotated. "sign" does not affect the text buffer but does not move when text is updated. "virt_text" uses extmarks, which move as text is updated.
---@field virt_text_pos? nvim-neocov.VirtTextPos See https://neovim.io/doc/user/api/#nvim_buf_set_extmark()
---@field covered? nvim-neocov.Annotation Style used when annotating a covered line.
---@field partial? nvim-neocov.Annotation Style used when annotating a partially covered line.
---@field uncovered? nvim-neocov.Annotation Style used when annotating a uncovered line.
---@field nocode? nvim-neocov.Annotation Style used when annotating a line without executable code.

---@class nvim-neocov.Config.Style Resolved display options.
---@field report_win ReportWin How a full coverage report should be displayed (hover, or in a split).
---@field report_width float How wide a floating report or vertical split report should be, in percent (up to 100.0).
---@field report_height?float How tall a floating report or horizontal split report should be, in percent (up to 100.0).
---@field marker_kind nvim-neocov.MarkerKind Controls how coverage lines are annotated. "sign" does not affect the text buffer but does not move when text is updated. "virt_text" uses extmarks, which move as text is updated.
---@field virt_text_pos nvim-neocov.VirtTextPos See https://neovim.io/doc/user/api/#nvim_buf_set_extmark()
---@field covered nvim-neocov.Annotation Style used when annotating a covered line.
---@field partial nvim-neocov.Annotation Style used when annotating a partially covered line.
---@field uncovered nvim-neocov.Annotation Style used when annotating a uncovered line.
---@field nocode nvim-neocov.Annotation Style used when annotating a line without executable code.

---@class nvim-neocov.LineCoverage Coverage data for a single line
---@field branches int Number of branches on the line
---@field covered int Number of covered branches on the line

---@class nvim-neocov.FileCoverage Coverage data for a file.
---@field lines table<int, nvim-neocov.LineCoverage> Line coverage data, 1 indexed.

---@class nvim-neocov.Coverage Coverage data for multiple files.
---@field files table<string, nvim-neocov.FileCoverage> Coverage data for each file.

---@class nvim-neocov.CoverageFile File that coverage data can be loaded from.
---@field path string Path to the coverage file on disk.
---@field kind nvim-neocov.ParserKind

---@class nvim-neocov.Options User-configurable options
---TODO(JON): Should this be per-ft?
---@field file? nvim-neocov.CoverageFile|nvim-neocov.CoverageFile[]|fun(src: string?): nvim-neocov.CoverageFile Path(s) or function used to find path(s) to the coverage report.
---@field cmd? fun(src: string?) Function invoked to run the coverage command(s). TODO(JON): Should this be a coroutine?
---@field style? nvim-neocov.Options.Style How coverage data should be displayed
---@field autoload? string[] filetypes to auto-load coverage data for, use `:set filetype?` to detect for a given file.
---@field parsers? table<string, fun(cov: string, src?: string): nvim-neocov.Coverage> Additional custom parsers. We recommend naming these in ALL_CAPS to avoid name clashes.
---
---@field watch? int Controls how frequently the "watch" command checks if the coverage file changed, in milliseconds. If 0 is supplied, a filesystem watcher is used instead.
---@field report? fun(src: string?, verbatim: boolean): string Function used to find the overall coverage report. If verbatim is true, the report will be loaded as-is. Otherwise, it will be parsed.
---@field eq? fun(string, string): boolean Function used to compare files mentioned in the coverage file with absolute paths on disk. If a coverage file only contains relative paths, you may need to normalize the 2 arguments and compare them as true.

---@class nvim-neocov.Config Resolved options.
---@field parsers table<string, fun(cov: string, src?: string): nvim-neocov.Coverage> Additional custom parsers. We recommend naming these in ALL_CAPS to avoid name clashes.
---TODO(JON): Re-copy when done
---@field style nvim-neocov.Config.Style How coverage data should be displayed
---@field file nvim-neocov.CoverageFile|nvim-neocov.CoverageFile[]|fun(src: string?): nvim-neocov.CoverageFile Path(s) or function used to find path(s) to the coverage report.
---@field cmd fun(src: string?) Function invoked to run the coverage command(s). TODO(JON): Should this be a coroutine?
---@field style nvim-neocov.Options.Style How coverage data should be displayed
---@field autoload string[] filetypes to auto-load coverage data for, use `:set filetype?` to detect for a given file.
