-- first things first
local g = vim.g
local opt = vim.opt
local o = vim.o
g.mapleader = ' '
g.maplocalleader = ' '
g.virtTextShow = true
-- package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
		"--branch=stable", lazypath, })
end
vim.opt.rtp:prepend(lazypath)
local ft = {
	dap = { cppdbg = { 'c', 'cpp' } },
	doc = { 'markdown', 'asciidoc' },
	fmt = { sh = { "shfmt" } },
	lsp = { 'c', 'cpp', 'lua', 'python', 'sh' },
	sonar = { 'c', 'cpp', 'python' },
	ts = { 'c', 'cpp', 'jsonc', 'lua', 'python' },
}
-- plugins
require("lazy").setup({
		-- Theme
		{
			'Mofiqul/dracula.nvim',
			lazy = false,
			priority = 1000,
			config = function()
				---@diagnostic disable-next-line: missing-fields
				require('dracula').setup {
					italic_comment = true,
					transparent_bg = true,
					lualine_bg_color = "#282a36",
					overrides = {
						---@diagnostic disable-next-line: missing-fields
						MatchParen = { underline = false, fg = "#ffcc59", bg = "#2b2a2c" }
					},
				}
				vim.cmd.colorscheme 'dracula'
			end
		},
		-- git
		{
			'lewis6991/gitsigns.nvim',
			ft = ft.ts,
			dependencies = { 'nvim-lua/plenary.nvim' },
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
			dependencies = { 'nvim-lua/plenary.nvim', 'jvgrootveld/telescope-zoxide' },
			cmd = { 'Telescope' },
			keys = {
				{ '<leader><space>', ":Telescope<cr>",                               desc = "telescope" },
				{ '<leader>F',       ":Telescope find_files<cr>",                    desc = "ts: Find files" },
				{ '<leader>G',       ":Telescope live_grep<cr>",                     desc = "ts: Live grep" },
				{ '<leader>W',       ":Telescope lsp_dynamic_workspace_symbols<cr>", desc = "LSP: Workspace symbols" },
				{ '<leader>b',       ":Telescope buffers<cr>",                       desc = "ts: buffers" },
				{ '<leader>o',       ":Telescope oldfiles<cr>",                      desc = "ts: oldfiles" },
				{ '<leader>R',       ":Telescope resume<cr>",                        desc = "ts: resume" },
				{ '<leader>s',       ":Telescope lsp_document_symbols<cr>",          desc = "LSP: Document Symbols" },
				{ '<leader>z',       ":Telescope zoxide list<cr>",                   desc = "ts: zoxide list" },
			},
			config = function()
				local l = require("telescope.actions.layout")
				local t = require('telescope')
				t.setup {
					defaults = {
						mappings = {
							n = {
								["<M-p>"] = l.toggle_preview
							},
							i = {
								["<M-p>"] = l.toggle_preview
							},
						},
						file_ignore_patterns = { "%.jpg", "%.jpeg", "%.png", "%.otf", "%.ttf", ".git" },
						prompt_prefix = "   ",
						selection_caret = "  ",
						entry_prefix = "  ",
						layout_strategy = "flex",
						layout_config = {
							horizontal = {
								preview_width = 0.6,
							},
						},
					},
					extensions = { zoxide = {} },
				}
				t.load_extension("zoxide")
			end
		},
		-- treesitter
		{
			'nvim-treesitter/nvim-treesitter',
			ft = ft.ts,
			dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
			config = function()
				pcall(require('nvim-treesitter.install').update { with_sync = true })
				---@diagnostic disable-next-line: missing-fields
				require('nvim-treesitter.configs').setup {
					-- Add languages to be installed here that you want installed for treesitter
					ensure_installed = ft.ts,
					auto_install = false,
					highlight = { enable = true },
					indent = { enable = true, disable = { 'python' } },
					incremental_selection = {
						enable = true,
						keymaps = {
							init_selection = '<c-space>',
							node_incremental = '<c-space>',
							scope_incremental = '<c-s>',
							node_decremental = '<M-space>',
						},
					},
					textobjects = {
						select = {
							enable = true,
							lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
							keymaps = {
								-- You can use the capture groups defined in textobjects.scm
								['aa'] = '@parameter.outer',
								['ia'] = '@parameter.inner',
								['af'] = '@function.outer',
								['if'] = '@function.inner',
								['ac'] = '@class.outer',
								['ic'] = '@class.inner',
							},
						},
						move = {
							enable = true,
							set_jumps = true, -- whether to set jumps in the jumplist
							goto_next_start = {
								[']m'] = '@function.outer',
								[']]'] = '@class.outer',
							},
							goto_next_end = {
								[']M'] = '@function.outer',
								[']['] = '@class.outer',
							},
							goto_previous_start = {
								['[m'] = '@function.outer',
								['[['] = '@class.outer',
							},
							goto_previous_end = {
								['[M'] = '@function.outer',
								['[]'] = '@class.outer',
							},
						},
						swap = {
							enable = true,
							swap_next = {
								['<leader>p'] = '@parameter.inner',
							},
							swap_previous = {
								['<leader>P'] = '@parameter.inner',
							},
						},
					},
				}
			end,
		},
		{
			'danymat/neogen',
			dependencies = { 'nvim-treesitter/nvim-treesitter' },
			opts = { snippet_engine = 'luasnip' },
			ft = ft.sonar,
			cmd = { "Neogen" }
		},
		-- Side panes
		{
			'nvim-neo-tree/neo-tree.nvim',
			dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'MunifTanjim/nui.nvim',
				'miversen33/netman.nvim' },
			opts = { sources = { 'filesystem', 'buffers', 'git_status', 'netman.ui.neo-tree' } },
			cmd = { 'Neotree' }
		},
		{
			'akinsho/toggleterm.nvim',
			config = true,
			cmd = 'ToggleTerm',
			keys = {
				{ '<A-t>',     ":ToggleTerm<cr>", desc = "toggle terminal" },
				{ '<leader>t', ":ToggleTerm<cr>", desc = "toggle terminal" },
			}
		},
		{
			'stevearc/aerial.nvim',
			ft = ft.ts,
			dependencies = { 'nvim-tree/nvim-web-devicons' },
			config = function()
				require('aerial').setup(
					{
						backends = { "treesitter" },
						on_attach = function(bufnr)
							vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>a',
								'<cmd>AerialToggle!<CR>', {})
							vim.api.nvim_buf_set_keymap(bufnr, 'n', '{',
								'<cmd>AerialPrev<CR>', {})
							vim.api.nvim_buf_set_keymap(bufnr, 'n', '}',
								'<cmd>AerialNext<CR>', {})
						end
					})
				local lualine_require = require("lualine_require")
				local modules = lualine_require.lazy_require({ config_module = "lualine.config" })
				local current_config = modules.config_module.get_config()
				current_config.sections.lualine_c = { 'hostname', { 'filename', path = 1 }, 'aerial' }
				require("lualine").setup(current_config)
			end
		},
		{
			"toppair/peek.nvim",
			event = { "VeryLazy" },
			build = "deno task --quiet build:fast",
			config = function()
				require("peek").setup()
				vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
				vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
			end,
			ft = ft.doc,
		}, -- lsp
		{ 'folke/lazydev.nvim', ft = 'lua' },
		{
			'neovim/nvim-lspconfig',
			ft = ft.lsp,
			cmd = { "LspInfo", "LspInstall", "LspUninstall" },
			dependencies = {
				{ 'williamboman/mason.nvim', cmd = "Mason", config = true },
				'williamboman/mason-lspconfig.nvim',
				{ 'j-hui/fidget.nvim',       config = true, tag = 'legacy' },
			},
			config = function()
				local on_attach = function(_, bufnr)
					local nmap = function(keys, func, desc)
						if desc then
							desc = 'LSP: ' .. desc
						end
						vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
					end
					nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols,
						'[D]ocument [S]ymbols')
					nmap('<leader>wd', require('telescope.builtin').diagnostics,
						'[W]orkspace [D]iagnostics')
					nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols,
						'[W]orkspace [S]ymbols')
					nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
					nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
					nmap('<leader>H', function()
						vim.g.virtTextShow = not vim.g.virtTextShow
						vim.diagnostic.config({ virtual_text = vim.g.virtTextShow })
					end, 'Toggle [H]ints')
					nmap('<leader>Q', vim.diagnostic.setqflist, 'diagnostic setqflist all')
					nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
					nmap('<leader>f', function()
						require 'conform'.format({ lsp_fallback = true })
					end, '[F]ormat buffer')
					nmap('<leader>h', vim.diagnostic.open_float, 'Show [h]int')
					nmap('<leader>q', function()
							vim.fn.setqflist(vim.diagnostic.toqflist(vim.diagnostic.get(0)),
								'r')
							vim.api.nvim_command('botright cwindow')
						end,
						'diagnostic setqflist current buffer')
					nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
					nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
					nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder,
						'[W]orkspace [R]emove Folder')
					nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
					nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
					nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
					nmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
					nmap('<leader>wl', function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, '[W]orkspace [L]ist Folders')
					local cmp = require('cmp')
					local sources = cmp.get_config().sources
					for i = #sources, 1, -1 do
						if sources[i].name == 'buffer' then
							table.remove(sources, i)
						end
					end
					cmp.setup.buffer({ sources = sources })
				end
				local servers = {
					clangd = {},
					lua_ls = {
						Lua = {
							workspace = { checkThirdParty = false },
							telemetry = { enable = false },
						},
					},
				}
				local capabilities = vim.lsp.protocol.make_client_capabilities()
				capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
				capabilities.offsetEncoding = { "utf-16" }
				local mason_lspconfig = require 'mason-lspconfig'
				mason_lspconfig.setup {
					ensure_installed = vim.tbl_keys(servers),
				}
				mason_lspconfig.setup_handlers {
					function(server_name)
						require('lspconfig')[server_name].setup {
							capabilities = capabilities,
							on_attach = on_attach,
							settings = servers[server_name],
						}
					end,
				}
			end
		},
		{
			'hrsh7th/nvim-cmp',
			event = "InsertEnter",
			dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip',
				'hrsh7th/cmp-buffer', 'paopaol/cmp-doxygen' },
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
						{ name = 'copilot' },
						{ name = 'doxygen' },
					},
				}
			end
		},
		{
			'https://gitlab.com/schrieveslaach/sonarlint.nvim',
			opts = {
				server = {
					cmd = { 'sonarlint-language-server', '-stdio', '-analyzers',
						vim.fn.stdpath('data') ..
						"/mason/share/sonarlint-analyzers/sonarpython.jar",
						vim.fn.stdpath('data') ..
						"/mason/share/sonarlint-analyzers/sonarcfamily.jar",
					}
				},
				filetypes = ft.sonar
			},
			ft = ft.sonar
		},
		{
			'stevearc/conform.nvim',
			ft = vim.tbl_keys(ft.fmt),
			opts = { formatters_by_ft = { ft.fmt } }
		},
		-- dap
		{
			"mfussenegger/nvim-dap",
			ft = ft.dap.cppdbg,
			dependencies = {
				{
					"rcarriga/nvim-dap-ui",
					-- stylua: ignore
					keys = {
						{ "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
						{ "<leader>de", function() require("dapui").eval() end,     desc = "Eval",  mode = { "n", "v" } },
					},
					config = function(_, opts)
						require("dap.ext.vscode").load_launchjs(nil, ft.dap)
						local dap = require("dap")
						local dapui = require("dapui")
						dapui.setup(opts)
						dap.listeners.after.event_initialized["dapui_config"] = function()
							dapui.open({})
						end
						dap.listeners.before.event_terminated["dapui_config"] = function()
							dapui.close({})
						end
						dap.listeners.before.event_exited["dapui_config"] = function()
							dapui.close({})
						end
					end,
					dependencies = { 'nvim-neotest/nvim-nio' },
				},
				{
					"theHamsta/nvim-dap-virtual-text",
					config = true
				},
				{
					"folke/which-key.nvim",
					optional = true,
					opts = {
						defaults = {
							["<leader>d"] = { name = "+debug" },
						},
					},
				},
				{
					"jay-babu/mason-nvim-dap.nvim",
					dependencies = "mason.nvim",
					cmd = { "DapInstall", "DapUninstall" },
					opts = {
						automatic_installation = true,
						handlers = {},
						ensure_installed = {},
					},
				},
			},
			keys = {
				{
					"<leader>dB",
					function()
						require("dap").set_breakpoint(vim.fn.input(
							'Breakpoint condition: '))
					end,
					desc = "Breakpoint Condition"
				},
				{ "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
				{ "<leader>dO", function() require("dap").step_over() end,     desc = "Step Over" },
				{
					"<leader>da",
					function()
						require("dap").continue({
							before = function(config)
								local args = type(config.args) == "function" and
								    (config.args() or {}) or config.args or {}
								config = vim.deepcopy(config)
								config.args = function()
									local new_args = vim.fn.input("Run with args: ",
										table.concat(args, " "))
									return vim.split(vim.fn.expand(new_args), " ")
								end
								return config
							end

						})
					end,
					desc = "Run with Args"
				},
				{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
				{ "<leader>dc", function() require("dap").continue() end,          desc = "Continue" },
				{ "<leader>dg", function() require("dap").goto_() end,             desc = "Go to line (no execute)" },
				{ "<leader>di", function() require("dap").step_into() end,         desc = "Step Into" },
				{ "<leader>dj", function() require("dap").down() end,              desc = "Down" },
				{ "<leader>dk", function() require("dap").up() end,                desc = "Up" },
				{ "<leader>dl", function() require("dap").run_last() end,          desc = "Run Last" },
				{
					"<leader>dL",
					function()
						require("dap.ext.vscode").load_launchjs(nil,
							{ cppdbg = { 'c', 'cpp' } })
					end,
					desc = "import launch.json"
				},
				{ "<leader>do", function() require("dap").step_out() end,         desc = "Step Out" },
				{ "<leader>dp", function() require("dap").pause() end,            desc = "Pause" },
				{ "<leader>dr", function() require("dap").repl.toggle() end,      desc = "Toggle REPL" },
				{ "<leader>ds", function() require("dap").session() end,          desc = "Session" },
				{ "<leader>dt", function() require("dap").terminate() end,        desc = "Terminate" },
				{ "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
			},
			config = function()
				vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
				for _, lang in ipairs({ "c", "cpp" }) do
					local dap = require("dap")
					dap.configurations[lang] = {
						{
							type = "cppdbg",
							request = "launch",
							stopAtEntry = true,
							name = "Launch file",
							program = function()
								return vim.fn.input("Path to executable: ",
									vim.fn.getcwd() .. "/", "file")
							end,
							cwd = "${workspaceFolder}",
						},
						{
							type = "cppdbg",
							request = "attach",
							name = "Attach to process",
							processId = require("dap.utils").pick_process,
							cwd = "${workspaceFolder}",
						},
					}
				end
			end,
		},
		-- status
		{
			'nvim-lualine/lualine.nvim',
			dependencies = { 'nvim-tree/nvim-web-devicons' },
			event = "VeryLazy",
			opts = {
				options = { globalstatus = true, component_separators = '', section_separators = '' },
				extensions = { 'aerial', 'fugitive', 'toggleterm', 'quickfix' },
				sections = { lualine_c = { 'hostname', { 'filename', path = 1 } } }
			}
		},
		-- misc
		{
			"zbirenbaum/copilot.lua",
			cmd = "Copilot",
			config = function()
				require("copilot").setup({
					suggestion = { enabled = false },
					panel = { enabled = false },
				})
			end,
			event = "InsertEnter",
		},
		{
			"zbirenbaum/copilot-cmp",
			config = function()
				require("copilot_cmp").setup()
			end,
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
					wk.register({
						['<C-ScrollWheelUp>'] = { function()
							g.neovide_scale_factor = g.neovide_scale_factor +
							    0.1
						end,
							"neovide: zoom ++" },
						['zp'] = { function()
							g.neovide_scale_factor = g.neovide_scale_factor +
							    0.1
						end, "neovide: zoom ++" },
						['<C-ScrollWheelDown>'] = { function()
							g.neovide_scale_factor = g.neovide_scale_factor -
							    0.1
						end,
							"neovide: zoom --" },
						['zm'] = { function()
							g.neovide_scale_factor = g.neovide_scale_factor -
							    0.1
						end, "neovide: zoom --" },
						['zr'] = { function() g.neovide_scale_factor = 1 end, "neovide: zoom reset" },
					})
				end
				wk.register({
					['<A-down>'] = { ":wincmd j<cr>", "window down" },
					['<A-left>'] = { ":wincmd h<cr>", "window left" },
					['<A-right>'] = { ":wincmd l<cr>", "window right" },
					['<A-up>'] = { ":wincmd k<cr>", "window up" },
					['<AS-down>'] = { ":wincmd -<cr>", "resize window down" },
					['<AS-left>'] = { ":wincmd <<cr>", "resize window left" },
					['<AS-right>'] = { ":wincmd ><cr>", "resize window right" },
					['<AS-up>'] = { ":wincmd +<cr>", "resize window up" },
					['<C-n>'] = { ":cnext<cr>", "qflist next" },
					['<C-p>'] = { ":cprev<cr>", "qflist prev" },
					['<C-s>'] = { ":w<cr>", "save" },
					['<leader>cd'] = { ":Neogen<cr>", "generate doxygen" },
					['<leader>e'] = { ":Neotree toggle<cr>", "tree" },
				}) -- normal mode
				wk.register({
					['<C-a>'] = { [[<Home>]], "go home" },
					['<C-e>'] = { [[<End>]], "go end" },
					['<C-b>'] = { [[<left>]], "left" },
					['<C-f>'] = { [[<right>]], "right" },
				}, { mode = "i" }) -- insert mode
				wk.register({
					['<C-h>'] = { [[<C-\><C-n><C-W>h]], "window left" },
					['<C-j>'] = { [[<C-\><C-n><C-W>j]], "window down" },
					['<A-down>'] = { [[<C-\><C-n><C-W>j]], "window down" },
					['<C-k>'] = { [[<C-\><C-n><C-W>k]], "window up" },
					['<A-up>'] = { [[<C-\><C-n><C-W>k]], "window up" },
					['<C-l>'] = { [[<C-\><C-n><C-W>l]], "window right" },
					-- Normal Map
					['<Esc>'] = { [[<C-\><C-n>]], "normal mode" },
					['<A-t>'] = { [[<C-\><C-n><Cmd>ToggleTerm<CR>]], "toggle terminal" },
				}, { mode = "t" }) -- terminal mode
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
-- opt.termguicolors = true
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
-- neovide
opt.guifont = { 'Iosevka Nerd Font Mono', ':h12' }
if g.neovide then
	g.neovide_cursor_animation_length = 0.01
	g.neovide_padding_bottom = 18
	g.neovide_padding_left = 18
	g.neovide_padding_right = 18
	g.neovide_padding_top = 18
	g.neovide_remember_window_size = true
	g.neovide_scale_factor = 1.0
	g.neovide_theme = 'auto'
	g.neovide_transparency = 0.70
end
-- Auto commands
local user_group = vim.api.nvim_create_augroup('UserCommands', { clear = true })
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
-- custom filetypes
vim.filetype.add({
	extension = {
		mke = "make",
		json = "jsonc",
	},
	pattern = {
		[".clang.*"] = "yaml",
	}
})
-- lsp & cmp setup
local sign = function(opts)
	-- See :help sign_define()
	vim.fn.sign_define(opts.name, {
		texthl = opts.name,
		text = opts.text,
		numhl = ''
	})
end
sign({ name = 'DiagnosticSignError', text = '✘' })
sign({ name = 'DiagnosticSignWarn', text = '▲' })
sign({ name = 'DiagnosticSignHint', text = '⚑' })
sign({ name = 'DiagnosticSignInfo', text = '' })
local _border = "single"
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
	vim.lsp.handlers.hover, {
		border = _border
	}
)
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
	vim.lsp.handlers.signature_help, {
		border = _border
	}
)
vim.diagnostic.config {
	float = { border = _border }
}
-- dispatch left of the dial
vim.api.nvim_set_hl(0, 'NeoTreeNormal', { bg = 'NONE' })
vim.cmd.aunmenu([[PopUp.How-to\ disable\ mouse]])
vim.cmd.amenu([[PopUp.:Inspect <Cmd>Inspect<CR>]])
vim.cmd.amenu([[PopUp.:Telescope <Cmd>Telescope<CR>]])
vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = { only_current_line = true },
	signs = true,
	float = {
		border = "single",
		source = "if_many"
	},
})
