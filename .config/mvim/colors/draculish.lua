-- We can have chicken
local hues = require("mini.hues")
local opts = {
	background = "#011A33",
	foreground = "#c0c8cb",
	accent = "azure",
}
hues.setup(opts)
local p = hues.make_palette(opts)
local hi = function(name, data)
	vim.api.nvim_set_hl(0, name, data)
end
hi("Comment", { fg = p.green, bg = nil, italic = true })
hi("DiagnosticUnderlineWarn", { undercurl = true })
hi("Keyword", { fg = p.blue, bg = nil, bold = true })
hi("Operator", { fg = p.cyan, bg = nil })
hi("Statement", { fg = p.blue, bg = nil, bold = true })
hi("Variable", { fg = p.cyan, bg = nil })
vim.g.colors_name = "draculish"
