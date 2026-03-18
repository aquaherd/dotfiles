-- first things first
local g = vim.g
local opt = vim.opt
local o = vim.o
g.mapleader = ' '
g.maplocalleader = ' '
g.virtTextShow = true
opt.termguicolors = true   -- must be set before colorscheme loads
-- package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
		"--branch=stable", lazypath, })
end
vim.opt.rtp:prepend(lazypath)
local ft = {
	dap = { cppdbg = { 'c', 'cpp' } },
	fmt = { sh = { "shfmt" } },
	lsp = { 'c', 'cpp', 'lua', 'python', 'sh' },
	lsps = { 'bashls', 'clangd', 'lua_ls', 'copilot' },
	ts = { 'bash', 'sh', 'c', 'cpp', 'jsonc', 'lua', 'python' },
}
local ts_parsers = { 'bash', 'c', 'cpp', 'jsonc', 'lua', 'python', 'query' }
-- plugins
require("lazy").setup({
	-- sidekick: Copilot NES + embedded AI CLI
	{
		'folke/sidekick.nvim',
		cond = function() return vim.fn.executable('copilot-language-server') == 1 end,
		event = "VeryLazy",
		opts = {
			cli = {
				default = "copilot",  -- open Copilot CLI by default
				mux = {
					enabled = true,
				},
			},
		},
		keys = {
			-- NES: navigate/apply Next Edit Suggestions (normal mode, falls back to <Tab>)
			{ "<Tab>", function()
				if not require("sidekick").nes_jump_or_apply() then return "<Tab>" end
			end, expr = true, desc = "NES: goto/apply suggestion" },
			-- CLI panel
			{ "<C-.>",      function() require("sidekick.cli").toggle() end,                    mode = { "n", "t", "i", "x" }, desc = "Copilot: toggle" },
			{ "<leader>aa", function() require("sidekick.cli").toggle() end,                    desc = "Copilot: toggle CLI" },
			{ "<leader>as", function() require("sidekick.cli").select() end,                    desc = "Copilot: select CLI" },
			{ "<leader>af", function() require("sidekick.cli").send({ msg = "{file}" }) end,    desc = "Copilot: send file" },
			{ "<leader>av", function() require("sidekick.cli").send({ msg = "{selection}" }) end, mode = { "x" }, desc = "Copilot: send selection" },
			{ "<leader>ap", function() require("sidekick.cli").prompt() end,                    mode = { "n", "x" }, desc = "Copilot: prompt library" },
		},
	},
	-- git
	{
		'lewis6991/gitsigns.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		event = { "VimEnter" },
		keys = {
			{ '<leader>cg', ":Gitsigns setqflist<cr>", desc = "git changes" },
			{ '[c',         ":Gitsigns prev_hunk<cr>", desc = "prev hunk" },
			{ ']c',         ":Gitsigns next_hunk<cr>", desc = "next hunk" },
		},
		config = true
	},
	{
		"NeogitOrg/neogit",
		ft = ft.lsp,
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration
			"nvim-telescope/telescope.nvim", -- optional
		},
		keys = { { 'go', ":Neogit kind=auto<cr>", desc = "git open" }, },
		config = true
	},
	--telescope
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim',
			'jvgrootveld/telescope-zoxide',
			'nvim-telescope/telescope-ui-select.nvim'
		},
		event = { "VimEnter" },
		keys = {
			{ '<leader><space>', ":Telescope<cr>", desc = "telescope" },
			{ '<leader>F', ":Telescope find_files<cr>", desc = "ts: Find files" },
			{ '<leader>G', ":Telescope live_grep<cr>", desc = "ts: Live grep" },
			{ '<leader>W', ":Telescope lsp_dynamic_workspace_symbols<cr>", desc = "LSP: Workspace symbols" },
			{ '<leader>b',       ":Telescope buffers<cr>", desc = "ts: buffers" },
			{ '<leader>o', ":Telescope oldfiles<cr>", desc = "ts: oldfiles" },
			{ '<leader>R', ":Telescope resume<cr>", desc = "ts: resume" },
			{ '<leader>s', ":Telescope lsp_document_symbols<cr>", desc = "LSP: Document Symbols" },
			{ '<leader>z', ":Telescope zoxide list<cr>", desc = "ts: zoxide list" },
		},
		config = function()
			local l = require("telescope.actions.layout")
			local t = require('telescope')
			t.setup {
				defaults = {
					mappings = {
						n = { ["<M-p>"] = l.toggle_preview },
						i = { ["<M-p>"] = l.toggle_preview },
					},
					file_ignore_patterns = { "%.jpg", "%.jpeg", "%.png", "%.otf", "%.ttf", ".git" },
					prompt_prefix = "   ",
					selection_caret = "  ",
					entry_prefix = "  ",
					layout_strategy = "flex",
					layout_config = { horizontal = { preview_width = 0.6, }, },
				},
				extensions = {
					zoxide = {},
					["ui-select"] = { require("telescope.themes").get_dropdown { }}
				},
			}
			t.load_extension("ui-select")
			t.load_extension("zoxide")
		end
	},
	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = function()
			vim.cmd("TSUpdate " .. table.concat(ts_parsers, " "))
		end,
		config = function()
			require("nvim-treesitter").setup()
			vim.treesitter.language.register("bash", "sh")
			-- Start highlighting explicitly
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("ts-auto-start", {}),
				callback = function(ctx)
					local lang = vim.bo[ctx.buf].filetype == "sh" and "bash" or nil
					pcall(vim.treesitter.start, ctx.buf, lang)
					if vim.bo[ctx.buf].filetype == "sh" then
						vim.bo[ctx.buf].syntax = "sh"
					end
				end,
			})
			-- Indent / fold (optional)
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("ts-indent", {}),
				callback = function(ctx)
					if vim.tbl_contains({ "c", "cpp" }, vim.bo[ctx.buf].filetype) then
						vim.bo[ctx.buf].indentexpr = ""
						vim.bo[ctx.buf].cindent = true
						return
					end
					vim.bo[ctx.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
			vim.wo.foldmethod = "expr"
			vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		end,
	},
	-- Side panes
	{
		'nvim-neo-tree/neo-tree.nvim',
		dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'MunifTanjim/nui.nvim', 'miversen33/netman.nvim' },
		opts = { sources = { 'filesystem', 'buffers', 'git_status', 'netman.ui.neo-tree' } },
		cmd = { 'Neotree' }
	},
	{
		'akinsho/toggleterm.nvim',
		config = true,
		cmd = 'ToggleTerm',
		keys = {
			{ '<A-t>',     ":ToggleTerm<cr>", desc = "toggle terminal" },
			{ '<leader>T', ":ToggleTerm<cr>", desc = "toggle terminal" },
		}
	},
	{
		'stevearc/aerial.nvim',
		ft = ft.ts,
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			local kmap=vim.api.nvim_buf_set_keymap
			require('aerial').setup(
				{
					backends = { "treesitter" },
					on_attach = function(bufnr)
						kmap(bufnr, 'n', '<leader>az', '<cmd>AerialToggle!<CR>', {})
						kmap(bufnr, 'n', '{', '<cmd>AerialPrev<CR>', {})
						kmap(bufnr, 'n', '}', '<cmd>AerialNext<CR>', {})
					end
				})
			local lualine_require = require("lualine_require")
			local modules = lualine_require.lazy_require({ config_module = "lualine.config" })
			local current_config = modules.config_module.get_config()
			current_config.sections.lualine_c = { 'hostname', { 'filename', path = 1 }, 'aerial' }
			require("lualine").setup(current_config)
		end
	},
	-- lsp
	{ 'j-hui/fidget.nvim', ft = ft.lsp, config = true },
	{
		'hrsh7th/nvim-cmp',
		event = "InsertEnter",
		dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip',
			'hrsh7th/cmp-buffer', 'hrsh7th/cmp-omni', 'aquaherd/timewarrior.nvim' },
		opts = function() -- nvim-cmp setup
			local cmp = require 'cmp'
			local luasnip = require 'luasnip'
			luasnip.config.setup {}
			cmp.setup {
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert {
					['<C-d>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<Esc>'] = cmp.mapping.abort(),
					['<C-Space>'] = cmp.mapping.complete {},
					['<CR>'] = cmp.mapping.confirm {
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					},
					['<Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { 'i', 's' }),
					['<S-Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { 'i', 's' }),
				},
				sources = {
					{ name = 'buffer' },
					{ name = 'luasnip' },
					{ name = 'nvim_lsp' },
				},
			}
			cmp.setup.filetype("timewarrior", {
				sources = cmp.config.sources({
					{ name = "omni" },
					{ name = "buffer" },
				}),
			})
		end
	},
	{
		'stevearc/conform.nvim',
		ft = vim.tbl_keys(ft.fmt),
		opts = {
			formatters_by_ft = ft.fmt,
			default_format_opts = { lsp_format = "fallback" },
		},
		init = function()
			-- make = / =% / =G use conform (which uses LSP for lua/c/cpp)
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
	-- status
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons', 'aquaherd/timewarrior.nvim' },
		event = "VeryLazy",
		opts = {
			options = { globalstatus = true, component_separators = '', section_separators = '' },
			extensions = { 'aerial', 'fugitive', 'toggleterm', 'quickfix' },
			sections = {
				lualine_c = { 'hostname', { 'filename', path = 1 } },
				-- lualine_x = { 'timewarrior' }
			}
		}
	},
	-- theme
	{
		'olimorris/onedarkpro.nvim',
		priority = 1000,
		config = function()
			require('onedarkpro').setup({
				options = { transparency = false },
			})
			local function apply_theme()
				local ok, err = pcall(function()
					if vim.o.background == 'dark' then
						vim.cmd.colorscheme('onedark')
					else
						vim.cmd.colorscheme('onelight')
					end
				end)
				if not ok then vim.notify('onedarkpro: ' .. err, vim.log.levels.WARN) end
			end
			apply_theme()
			vim.api.nvim_create_autocmd('OptionSet', {
				pattern = 'background',
				callback = apply_theme,
			})
		end
	},
	{
		'f-person/auto-dark-mode.nvim',
		priority = 999,
		cond = function()
			if vim.fn.has("linux") == 1 or vim.fn.has("bsd") == 1 then
				return vim.fn.executable('dbus-send') == 1
			end
			return true -- windows and macos have desktop anyway
		end,
		opts = {
			set_dark_mode  = function() vim.o.background = 'dark' end,
			set_light_mode = function() vim.o.background = 'light' end,
			update_interval = 3000,
		},
	},
	-- misc
	{
		'aquaherd/timewarrior.nvim',
		cond = function() return vim.fn.executable('timew') == 1 end,
	},
	{
		'norcalli/nvim-colorizer.lua',
		config = true,
		cmd = 'ColorizerToggle',
	},
	{
		'folke/which-key.nvim',
		event = "VeryLazy",
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			local wk = require("which-key")
			if g.neovide then
				local zm = function() g.neovide_scale_factor = g.neovide_scale_factor - 0.1 end
				local zp = function() g.neovide_scale_factor = g.neovide_scale_factor + 0.1 end
				local zr = function() g.neovide_scale_factor = 1 end
				local fs = function() g.neovide_fullscreen = not g.neovide_fullscreen end
				wk.add({
					{ "<C-ScrollWheelDown>", zm, desc = "neovide: zoom --" },
					{ "<C-ScrollWheelUp>",   zp, desc = "neovide: zoom ++" },
					{ "zm",                  zm, desc = "neovide: zoom --" },
					{ "zp",                  zp, desc = "neovide: zoom ++" },
					{ "zr",                  zr, desc = "neovide: zoom reset" },
					{ "<F11>",               fs, desc = "neovide: toggle fullscreen" },
				})
			end
			wk.add({
				{
					mode = { "n" }, --normal mode
					{ "\\b",":let &background=(&background==#'dark'?'light':'dark')<cr>",desc="toggle background" },
					{ "<A-down>",   ":wincmd j<cr>",       desc = "window down" },
					{ "<A-left>",   ":wincmd h<cr>",       desc = "window left" },
					{ "<A-right>",  ":wincmd l<cr>",       desc = "window right" },
					{ "<A-up>",     ":wincmd k<cr>",       desc = "window up" },
					{ "<AS-down>",  ":wincmd -<cr>",       desc = "resize window down" },
					{ "<AS-left>",  ":wincmd <<cr>",       desc = "resize window left" },
					{ "<AS-right>", ":wincmd ><cr>",       desc = "resize window right" },
					{ "<AS-up>",    ":wincmd +<cr>",       desc = "resize window up" },
					{ "<C-n>",      ":cnext<cr>",          desc = "qflist next" },
					{ "<C-p>",      ":cprev<cr>",          desc = "qflist prev" },
					{ "<C-s>",      ":w<cr>",              desc = "save" },
					{ "<leader>e",  ":Neotree toggle<cr>", desc = "tree" },
					{ "<leader>tb", ":TimewarriorStartPick<cr>", desc = "timew start" },
					{ "<leader>td", ":TimewarriorToday<cr>", desc = "timew today" },
					{ "<leader>te", ":TimewarriorStop<cr>", desc = "timew stop" },
				},
				{
					mode = { "i" }, --insert mode
					{ "<C-a>", "<Home>",  desc = "go home" },
					{ "<C-b>", "<left>",  desc = "left" },
					{ "<C-e>", "<End>",   desc = "go end" },
					{ "<C-f>", "<right>", desc = "right" },
				},
				{
					mode = { "t" }, --terminal mode
					{ "<A-down>", "<C-\\><C-n><C-W>j",              desc = "window down" },
					{ "<A-t>",    "<C-\\><C-n><Cmd>ToggleTerm<CR>", desc = "toggle terminal" },
					{ "<A-up>",   "<C-\\><C-n><C-W>k",              desc = "window up" },
					{ "<C-h>",    "<C-\\><C-n><C-W>h",              desc = "window left" },
					{ "<C-j>",    "<C-\\><C-n><C-W>j",              desc = "window down" },
					{ "<C-k>",    "<C-\\><C-n><C-W>k",              desc = "window up" },
					{ "<C-l>",    "<C-\\><C-n><C-W>l",              desc = "window right" },
					{ "<Esc>",    "<C-\\><C-n>",                    desc = "normal mode" },
				}
			})
		end
	},
},
	{
		performance = {
			rtp = {
				disabled_plugins = {
					"gzip",
					"matchit",
					"matchparen",
					"netrwPlugin",
					"tarPlugin",
					"tohtml",
					"tutor",
					"zipPlugin",
				},
			},
		},
	}
)
-- unfinished business
-- basic
o.mouse = 'a'
o.title = true
o.clipboard = 'unnamedplus'
opt.swapfile = false
o.undofile = true
o.cmdheight = 1
o.showmode = false
-- timeout stuff
o.updatetime = 300
o.timeout = true
o.timeoutlen = 500
o.ttimeoutlen = 10
-- status, tab, number, sign line
o.ruler = false
o.laststatus = 3
-- opt.winbar = '%t'
o.showtabline = 1
o.number = true
o.numberwidth = 1
o.relativenumber = true
o.signcolumn = "yes"
o.wildmode = 'longest:full'
-- window, buffer, tabs
o.splitbelow = true
o.splitright = true
o.hidden = true
-- opt.fillchars.vert = "│"
o.cursorline = true
o.scrolloff = 8
-- text formatting (shiftwidth, tabstops etc: use .editorconfig, .clangd or modeline)
o.smartindent = true
o.showmatch = true
o.smartcase = true
opt.whichwrap:append "<>[]hl"
-- remove intro
opt.shortmess:append "sI"
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
-- neovide
if g.neovide then
	g.neovide_cursor_animation_length = 0.01
	g.neovide_padding_bottom = 18
	g.neovide_padding_left = 18
	g.neovide_padding_right = 18
	g.neovide_padding_top = 18
	g.neovide_remember_window_size = true
	g.neovide_scale_factor = 1.0
	g.neovide_theme = 'auto'
	g.neovide_opacity = 0.95
end
-- Auto commands
local user_group = vim.api.nvim_create_augroup('UserCommands', { clear = true })
-- Sync terminal pty size to its window on open and resize
local function resize_terminal(buf)
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(buf) then return end
		if vim.bo[buf].buftype ~= 'terminal' then return end
		local chan = vim.bo[buf].channel
		if not chan or chan <= 0 then return end
		local wins = vim.fn.win_findbuf(buf)
		if #wins > 0 then
			pcall(vim.fn.jobresize, chan,
				vim.api.nvim_win_get_width(wins[1]),
				vim.api.nvim_win_get_height(wins[1]))
		end
	end)
end
vim.api.nvim_create_autocmd('TermOpen', {
	group = user_group,
	callback = function(ev) resize_terminal(ev.buf) end,
})
vim.api.nvim_create_autocmd('WinResized', {
	group = user_group,
	callback = function()
		for _, buf in ipairs(vim.v.event and vim.v.event.windows and
			vim.tbl_map(vim.api.nvim_win_get_buf, vim.v.event.windows) or {}) do
			resize_terminal(buf)
		end
	end,
})
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight on yank',
	callback = function()
		vim.highlight.on_yank({ higroup = 'Visual', timeout = 300 })
	end,
	group = user_group,
	pattern = '*',
})
vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'help', 'man', 'qflist' },
	group = user_group,
	command = 'nnoremap <buffer> q <cmd>quit<cr>'
})
vim.api.nvim_create_autocmd('VimLeave', {
	group = user_group,
	command = 'set guicursor= | call chansend(v:stderr, "\x1b[ q")'
})
vim.api.nvim_create_autocmd('LspAttach', {
	group = user_group,
	callback = function(args)
		-- re-assert conform's formatexpr; vim.lsp.set_defaults() overrides it on every attach
		vim.bo[args.buf].formatexpr = "v:lua.require'conform'.formatexpr()"
		local nset = function(keys, func, desc)
			vim.keymap.set('n', keys, func, { buffer = args.buf, silent = true, desc = desc })
		end
		nset('gD', vim.lsp.buf.declaration, 'LSP: goto declaration')
		nset('gd', vim.lsp.buf.definition, 'LSP: goto definition')
		nset('grQ', vim.diagnostic.setqflist, 'diagnostic setqflist')
		nset('grf', function() require 'conform'.format({ lsp_format = "fallback" }); end, 'Format (buffer)')
		nset('grh', vim.diagnostic.open_float, 'diagnostic float')
		nset('grq',
			function()
				vim.fn.setqflist(vim.diagnostic.toqflist(vim.diagnostic.get(0)), 'r'); vim.api
				.nvim_command('botright cwindow');
			end, 'diagnostic setqflist current buffer')
		nset('gH',
			function()
				vim.diagnostic.config({
					virtual_text = not vim.diagnostic.config().virtual_text,
					virtual_lines = not
						vim.diagnostic.config().virtual_lines,
				});
			end, 'toggle hints')
		nset('gS', function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end, 'toggle diagnostic')
		local cmp = require('cmp')
		local sources = cmp.get_config().sources
		for i = #sources, 1, -1 do
			if sources[i].name == 'buffer' then
				table.remove(sources, i)
			end
		end
		cmp.setup.buffer({ sources = sources })
	end,
})

-- custom filetypes
vim.filetype.add({
	extension = {
		mke = "make",
		json = "jsonc",
	},
	pattern = {
		["eswbuild"] = "sh",
		[".clang.*"] = "yaml",
	}
})
-- lsp & cmp setup
vim.lsp.enable(ft.lsps)
vim.api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", { desc = "Check LSP" })
-- dispatch left of the dial
vim.api.nvim_set_hl(0, 'NeoTreeNormal', { bg = 'NONE' })
vim.cmd.aunmenu([[PopUp.How-to\ disable\ mouse]])
vim.cmd.amenu([[PopUp.:Inspect <Cmd>Inspect<CR>]])
vim.cmd.amenu([[PopUp.:Telescope <Cmd>Telescope<CR>]])
vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = '✘ ',
			[vim.diagnostic.severity.WARN] = '▲ ',
			[vim.diagnostic.severity.INFO] = '󰋽 ',
			[vim.diagnostic.severity.HINT] = '󰌶 ',
		},
	},
	float = {
		border = "single",
		source = "if_many"
	},
})
vim.opt.foldenable     = false
vim.opt.foldlevel      = 99
vim.opt.foldlevelstart = 99

