-- Plugin manager: native `vim.pack` (Neovim 0.12+)
-- Manages plugins in stdpath('data')/site/pack/core/opt.
-- Run `:restart` after changing specs, `vim.pack.update()` to update.
-- zk-nvim is only loaded when the `zk` CLI is available.
local has_zk = vim.fn.executable('zk') == 1

local plugins = {
	{ src = 'https://github.com/echasnovski/mini.nvim' },
}
if has_zk then
	table.insert(plugins, { src = 'https://github.com/zk-org/zk-nvim' })
end
vim.pack.add(plugins)

-- Early setup
vim.g.mapleader = ' '       -- default
vim.g.maplocalleader = ' '  -- default
vim.o.relativenumber = true -- and relative line number
vim.g.virtTextShow = true   -- LSP

-- UI
vim.o.termguicolors = true
vim.cmd('colorscheme draculish')

-- mini.nvim modules (installed and packadded by vim.pack.add, so safe to require)
require('mini.notify').setup()
vim.notify = require('mini.notify').make_notify()

require('mini.basics').setup({ mappings = { windows = true } })

require('mini.completion').setup()

local miniclue = require('mini.clue')
miniclue.setup({
	triggers = {
		-- Leader triggers
		{ mode = 'n', keys = '<Leader>' },
		{ mode = 'x', keys = '<Leader>' },
		-- Built-in completion
		{ mode = 'i', keys = '<C-x>' },
		-- `g` key
		{ mode = 'n', keys = 'g' },
		{ mode = 'n', keys = '[' },
		{ mode = 'n', keys = '\\' },
		{ mode = 'n', keys = ']' },
		{ mode = 'x', keys = 'g' },
		-- Marks
		{ mode = 'n', keys = "'" },
		{ mode = 'n', keys = '`' },
		{ mode = 'x', keys = "'" },
		{ mode = 'x', keys = '`' },
		-- Registers
		{ mode = 'n', keys = '"' },
		{ mode = 'x', keys = '"' },
		{ mode = 'i', keys = '<C-r>' },
		{ mode = 'c', keys = '<C-r>' },
		-- Window commands
		{ mode = 'n', keys = '<C-w>' },
		-- `z` key
		{ mode = 'n', keys = 'z' },
		{ mode = 'x', keys = 'z' },
	},
	clues = {
		-- Enhance this by adding descriptions for <Leader> mapping groups
		{ mode = 'n', keys = '<leader>g', desc = 'Git commands' },
		{ mode = 'n', keys = 'gr', desc = 'Refactor commands' },
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
	},
})

require('mini.icons').setup()

local status = require('mini.statusline')
status.section_hostname = function(args)
	return MiniStatusline.is_truncated(args.trunc_width) and '' or vim.fn.hostname() or "localhost"
end
status.setup({
content = {
	active = function()
		local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
		local hostname      = MiniStatusline.section_hostname({ trunc_width = 75 })
		local git           = MiniStatusline.section_git({ trunc_width = 120 })
		local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
		local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
		local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
		local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
		local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
		local location      = MiniStatusline.section_location({ trunc_width = 75 })
		local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })
		return MiniStatusline.combine_groups({
			{ hl = mode_hl,                  strings = { mode } },
			{ hl = 'MiniStatuslineDevinfo',  strings = { hostname, git, diff, diagnostics, lsp } },
			'%<', -- Mark general truncate point
			{ hl = 'MiniStatuslineFilename', strings = { filename } },
			'%=', -- End left alignment
			{ hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
			{ hl = mode_hl,                  strings = { search, location } },
		})
	end,
}
})

require('mini.ai').setup()
require('mini.comment').setup()
require('mini.diff').setup({
	view = {
		style = 'sign',
		signs = { add = '+', change = '~', delete = '-' },
	},
})
require('mini.extra').setup()
require('mini.files').setup({ windows = { preview = true } })
require('mini.git').setup()
require('mini.pick').setup()
vim.ui.select = MiniPick.ui_select
require('GitWorktrees')
require('mini.surround').setup()

-- Non-minis
-- zk (configured only when the `zk` CLI is available)
if has_zk then
	require("zk").setup({
		picker = "select",
		lsp = { -- `config` is passed to `vim.lsp.start(config)`
			config = {
				name = "zk",
				cmd = { "zk", "lsp" },
				filetypes = { "markdown" },
			},
			auto_attach = {
				enabled = true,
			},
		},
	})
end

-- LSP
vim.lsp.enable({ 'clangd', 'bashls', 'lua_ls' })
vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = false
})

-- keymaps
local C = function(cmd) return "<Cmd>" .. cmd .. "<CR>" end
local nmp = function(key, cmd, desc) vim.keymap.set('n', key, cmd, { desc = desc }) end
nmp('<C-N>', C('cnext'), 'qflist next')
nmp('<C-P>', C("cprev"), 'qflist prev')
nmp('<ESC>', C("nohlsearch"), 'Clear search highlight')
nmp('<leader>?', C("Pick keymaps"), '? keymaps')
nmp('<leader>/', C("Pick grep_live"), 'grep live')
nmp('<leader>b', C("Pick buffers"), 'Pick buffer')
nmp('<leader>e', C("lua MiniFiles.open()"), 'Explore')
nmp('<leader>f', C("Pick files"), 'Pick Files')
nmp('<leader>gf', C("Pick git_files"), 'Pick Git Files')
nmp('<leader>gh', C("Pick git_hunks"), 'Pick Git Hunks')
nmp('<leader>h', C("Pick history"), 'Pick history')
nmp('<leader>o', C("Pick oldfiles"), 'Pick Oldfiles')
nmp('<leader>n', C("lua MiniNotify.show_history()"), 'Show notifications')
nmp('<leader>r', C("Pick resume"), 'Pick resume')
nmp('<leader>u', C('e ++ff=dos | set ff=unix | w!'), 'Save dos2unix')

-- autocommands
local user_group = vim.api.nvim_create_augroup('UserCommands', { clear = true })
-- lsp buffer attached
local setqf = function()
	vim.fn.setqflist(vim.diagnostic.toqflist(vim.diagnostic.get()), 'r')
	vim.api.nvim_command('botright cwindow');
end
local toggle_hints = function()
	vim.diagnostic.config({ virtual_lines = not vim.diagnostic.config().virtual_lines });
end
vim.api.nvim_create_autocmd('LspAttach', {
	group = user_group,
	callback = function(args)
		local C = function(cmd) return "<Cmd>" .. cmd .. "<CR>" end
		local nmpb = function(key, cmd, desc) vim.keymap.set('n', key, cmd, { desc = desc, buffer = args.buf }) end
		nmpb('\\O', C("lua MiniDiff.toggle_overlay()"), 'toggle diff overlay')
		nmpb('\\H', toggle_hints, 'toggle hints')
		nmpb('gD', vim.lsp.buf.declaration, 'go to declaration')
		nmpb('<leader>a', C("Pick lsp scope='document_symbol'"), 'Symbols')
		nmpb('<leader>w', C("Pick lsp scope='workspace_symbol'"), 'Workspace')
		nmpb('<leader>W', C("Pick git_worktrees"), 'Worktrees')
		nmpb('gd', vim.lsp.buf.definition, 'go to definition')
		nmpb('grQ', vim.diagnostic.setqflist, 'diagnostic setqflist')
		nmpb('grf', vim.lsp.buf.format, 'Format (buffer)')
		nmpb('grh', vim.diagnostic.open_float, 'diagnostic float')
		nmpb('grq', setqf, 'diagnostic setqflist current buffer')
	end,
})
-- fix cursor
vim.api.nvim_create_autocmd('VimLeave', {
	command = 'set guicursor= | call chansend(v:stderr, "\x1b[ q")',
	group = user_group
})
-- faster closes
vim.api.nvim_create_autocmd('FileType', {
	command = 'nnoremap <buffer> q <cmd>quit<cr>',
	group = user_group,
	pattern = { 'help', 'man', 'qf'}
})
vim.api.nvim_create_autocmd('FileType', {
	command = 'nnoremap <buffer> q <cmd>bdelete<cr>',
	group = user_group,
	pattern = { 'mininotify-history' }
})
-- fix header files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	callback = function() vim.bo.filetype = "c" end,
	group = user_group,
	pattern = "*.h"
})
-- start treesitter
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		local ok, _ = pcall(vim.treesitter.start)
		if ok then
			vim.cmd('setlocal foldenable foldmethod=expr foldlevel=999')
			vim.cmd('setlocal foldexpr=v:lua.vim.treesitter.foldexpr()')
		end
	end
})

-- Somethings
vim.opt.clipboard = 'unnamedplus'
local function paste() return {
	vim.split(vim.fn.getreg(''), '\n'),
	vim.fn.getregtype(''),
} end
if vim.env.SSH_TTY then
	vim.g.clipboard = {
		name = 'OSC 52',
		copy = {
			['+'] = require('vim.ui.clipboard.osc52').copy '+',
			['*'] = require('vim.ui.clipboard.osc52').copy '*',
		},
		paste = {
			['+'] = paste,
			['*'] = paste,
		},
	}
end
