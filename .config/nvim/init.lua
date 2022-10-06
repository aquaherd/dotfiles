local modules = {
	'options',
	'plugins',
	'config',
	'mappings',
  'lsp'
}

for i, a in ipairs(modules) do
	local ok, err = pcall(require, a)
	if not ok then
		error("Error calling " .. a .. err .. i)
	end
end


-- Auto commands

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
vim.cmd [[ colorscheme dracula ]]

-- vim.api.nvim_create_autocmd("ColorScheme", {
--   pattern="*",
--   callback = function()
--     vim.api.nvim_set_hl(0, "CursorLineNr", { ctermbg=0, bold=true })
--   end,
-- })

-- vim.cmd [[
--   let dracula_italic_comment=v:true
--   augroup open-tabs
--     au!
--     au VimEnter * ++nested if !&diff | tab all | tabfirst | endif
--     au ColorScheme * highlight Normal ctermbg=NONE
--   augroup end
--   au TermOpen term://* setlocal nonumber norelativenumber signcolumn=no | setfiletype terminal
--   au BufEnter,BufWinEnter,WinEnter,CmdwinEnter * if bufname('%') == "NvimTree" | set laststatus=0 | else | set laststatus=3 | endif
--   colorscheme dracula
--   set guifont=Iosevka:h12
--   ]]
