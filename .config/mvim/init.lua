-- Put this at the top of 'init.lua'
local path_package = vim.fn.stdpath('data') .. '/site'
local mini_path = path_package .. '/pack/deps/start/mini.nvim'
---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		'git', 'clone', '--filter=blob:none',
		-- Uncomment next line to use 'stable' branch
		-- '--branch', 'stable',
		'https://github.com/echasnovski/mini.nvim', mini_path
	}
	vim.fn.system(clone_cmd)
	vim.cmd('packadd mini.nvim | helptags ALL')
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end
-- Early setup
vim.g.mapleader = ' '       -- default
vim.g.maplocalleader = ' '  -- default
vim.o.relativenumber = true -- and relative line number
vim.g.virtTextShow = true   -- LSP

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = path_package } })

-- Use 'mini.deps'. `now()` and `later()` are helpers for a safe two-stage
-- startup and are optional.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Safely execute immediately
now(function()
	vim.o.termguicolors = true
	vim.cmd('colorscheme draculish')
end)
now(function()
	require('mini.notify').setup()
	vim.notify = require('mini.notify').make_notify()
end)
now(function() require('mini.basics').setup({ mappings = { windows = true } }) end)
now(function() require('mini.completion').setup() end)
now(function()
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
end)
now(function() require('mini.icons').setup() end)
now(function()
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
}) end)

-- Safely execute later
later(function() require('mini.ai').setup() end)
later(function() require('mini.comment').setup() end)
later(function() require('mini.diff').setup({
	view = {
		style = 'sign',
		signs = { add = '+', change = '~', delete = '-' },
	},
}) end)
later(function() require('mini.extra').setup() end)
later(function() require('mini.files').setup({ windows = { preview = true } }) end)
later(function() require('mini.git').setup() end)
later(function() require('mini.pick').setup()
	vim.ui.select = MiniPick.ui_select
	require('GitWorktrees')
end)
later(function() require('mini.surround').setup() end)

-- Non-minis
later(function()
	add({ source = 'zk-org/zk-nvim' })
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
end)
-- LSP
later(function()
	vim.lsp.enable({ 'clangd', 'bashls', 'lua_ls' })
	vim.diagnostic.config({
		virtual_text = true,
		virtual_lines = false
	})
end)
-- keymaps
later(function()
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
end)

-- autocommands
later(function()
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
			nmpb('grf', function() require 'conform'.format({ lsp_fallback = true }); end, 'Format (buffer)')
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
	vim.api.nvim_create_autocmd("FileType", {                                                                                       callback = function()
		local ok, _ = pcall(vim.treesitter.start)
		if ok then
			vim.cmd('setlocal foldenable foldmethod=expr foldlevel=999')
			vim.cmd('setlocal foldexpr=v:lua.vim.treesitter.foldexpr()')
		end
	end
})
end)
-- Somethings
later(function()
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
end)
