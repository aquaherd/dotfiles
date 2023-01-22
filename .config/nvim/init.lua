-- install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local first_run = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    first_run = true
    vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    vim.cmd [[ packadd packer.nvim ]]
end

-- plugins
require('packer').startup(function(use)
    -- Self
    use 'wbthomason/packer.nvim'

    -- Theme
    local theme = 'dracula' -- 'tokyonight'
    use { 'Mofiqul/dracula.nvim',
        cond = theme == 'dracula',
        config = function()
            require('dracula').setup {
                italic_comment = true,
                transparent_bg = true,
                lualine_bg_color = "#282a36",
            }
            vim.api.nvim_command "colorscheme dracula"
        end
    }
    use { 'folke/tokyonight.nvim',
        cond = (theme == 'tokyonight'),
        config = function()
            require('tokyonight').setup {
                style = 'night',
                transparent = true,
                on_colors = function(colors)
                    colors.border = colors.blue0
                end
            }
            vim.api.nvim_command "colorscheme tokyonight"
        end
    }

    -- Coding
    use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('gitsigns').setup {
                signs = {
                    add = { hl = "DiffAdd", text = "│", numhl = "GitSignsAddNr" },
                    change = { hl = "DiffChange", text = "│", numhl = "GitSignsChangeNr" },
                    delete = { hl = "DiffDelete", text = "│", numhl = "GitSignsDeleteNr" },
                    topdelete = { hl = "DiffDelete", text = "│", numhl = "GitSignsDeleteNr" },
                    changedelete = { hl = "DiffChangeDelete", text = "│", numhl = "GitSignsChangeNr" },
                }
            }
        end
    }
    use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' },
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
                    file_ignore_patterns = {
                        "%.jpg",
                        "%.jpeg",
                        "%.png",
                        "%.otf",
                        "%.ttf",
                        ".git",
                    },
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
                extensions = {
                    zoxide = {}
                },
            }
            t.load_extension("zoxide")
        end
    }
    use 'jvgrootveld/telescope-zoxide'
    use { 'lukas-reineke/indent-blankline.nvim', disable = true }
    use { 'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup {}
        end
    }

    -- treesitter
    use { 'nvim-treesitter/nvim-treesitter',
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = { "bash", "c", "python", "cpp", "lua", "toml", "cmake" },
                highlight = {
                    enable = true, -- false will disable the whole extension
                    --disable = { "c", "rust" },  -- list of language that will be disabled
                },
                textobjects = {
                    select = {
                        enable = true,
                        -- Automatically jump forward to textobj, similar to targets.vim
                        lookahead = true,
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@comment.outer",
                            ["as"] = "@statement.outer",
                            ["ii"] = "@conditional.inner",
                            ["ai"] = "@conditional.outer",
                        },
                    },
                },
            }

        end
    }
    use 'nvim-treesitter/nvim-treesitter-textobjects'
    use { 'danymat/neogen', requires = { 'nvim-treesitter/nvim-treesitter' }, tag = '*',
        config = function()
            require('neogen').setup { snippet_engine = 'luasnip' }
        end,
        ft = 'c'
    }

    -- Side panes
    use { 'kyazdani42/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = function()
            require('nvim-tree').setup {
                view = {
                    width = 30,
                    side = "left",
                    hide_root_folder = true,
                },
                disable_netrw = true,
                hijack_cursor = true,
                update_cwd = true,
                update_focused_file = {
                    enable = true
                },
                diagnostics = {
                    enable = true,
                }
            }
        end
    }
    use { 'akinsho/toggleterm.nvim',
        config = function()
            require('toggleterm').setup {}
        end
    }
    use { 'stevearc/aerial.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = function()
            require('aerial').setup {
                backends = { "treesitter" },
                on_attach = function(bufnr)
                    -- Toggle the aerial window with <leader>a
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>a', '<cmd>AerialToggle!<CR>', {})
                    -- Jump forwards/backwards with '{' and '}'
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', '{', '<cmd>AerialPrev<CR>', {})
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', '}', '<cmd>AerialNext<CR>', {})
                    -- Jump up the tree with '[[' or ']]'
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', '[[', '<cmd>AerialPrevUp<CR>', {})
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', ']]', '<cmd>AerialNextUp<CR>', {})
                end
            }
        end
    }

    -- lsp
    use { 'VonHeikemen/lsp-zero.nvim',
        config = function()
            require('neodev').setup({})
            local lsp = require('lsp-zero')
            lsp.preset('recommended')
            lsp.on_attach(function(_, bufnr)
                local bind = vim.api.nvim_buf_set_keymap

                bind(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.format()<cr>', { desc = 'lsp: format' })
                bind(bufnr, 'n', '<leader>h', '<cmd>lua vim.diagnostic.open_float()<cr>',
                    { desc = 'lsp: show diagnostic on hover' })
                bind(bufnr, 'n', '<leader>R', '<cmd>lua vim.lsp.buf.rename()<cr>', { desc = 'lsp: rename' })
                bind(bufnr, 'n', '<leader>q', '<cmd>lua vim.diagnostic.setqflist()<cr>',
                    { desc = 'lsp: set diagnostics to qflist' })
                bind(bufnr, 'n', '<leader>Q',
                    '<cmd>lua vim..diagnostic.setqflist({severity=vim.diagnostic.severity.ERROR})<cr>',
                    { desc = 'lsp: set error diagnostics to qflist' })
            end)
            local cmp_map = lsp.defaults.cmp_mappings()
            cmp_map['<C-e>'] = nil
            lsp.setup_nvim_cmp({ mapping = cmp_map })
            lsp.setup()
        end,
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },
            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
            -- lua development
            { 'folke/neodev.nvim' }
        }
    }

    -- non-lua
    use { 'tpope/vim-fugitive', cmd = { "Git" } }
    use { 'mboughaba/i3config.vim', ft = { 'i3config' } }

    -- status
    use { 'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = function()
            require('lualine').setup {
                options = {
                    globalstatus = true,
                    component_separators = '',
                    section_separators = '',
                    theme = theme,
                    disabled_filetypes = { 'packer' },
                },
                extensions = {
                    'aerial',
                    'nvim-tree',
                    'fugitive',
                    'toggleterm',
                    'quickfix',
                },
                sections = {
                    lualine_c = { 'filename', 'aerial' },
                }
            }
        end
    }

    -- misc
    use { "ur4ltz/surround.nvim",
        config = function()
            require('surround').setup { mappings_style = "sandwich" }
        end
    }
    use { 'norcalli/nvim-colorizer.lua', cmd = 'ColorizerToggle' }
    use { 'folke/which-key.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = function()
            require("which-key").setup {}
        end
    }

    if first_run then
        require('packer').sync();
    end
end)

if first_run then
    print 'hit enter, let packer sync go and restart nvim'
    return
end

-- unfinished business

local g = vim.g
local opt = vim.opt
local o = vim.o
g.mapleader = ' '
g.maplocalleader = ' '
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
opt.fillchars.vert = "│"
o.cursorline = true
o.scrolloff = 8

-- text formatting
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.showmatch = true
o.smartcase = true
opt.whichwrap:append "<>[]hl"

-- remove intro
opt.shortmess:append "sI"

-- neovide
opt.guifont = { 'Iosevka', ':h12' }
if g.neovide then
    g.neovide_transparency = 0.85
    g.neovide_cursor_animation_length = 0.01
end
-- disable inbuilt vim plugins
local built_ins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "matchit",
    "tar",
    "tarPlugin",
    "rrhelper",
    "spellfile_plugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
}

for _, plugin in pairs(built_ins) do
    g["loaded_" .. plugin] = 1
end

-- mappings
local wk = require("which-key")
wk.register({
    ['<A-t>'] = { ":ToggleTerm<cr>", "" },
    ['<C-n>'] = { ":cnext<cr>", "" },
    ['<C-p>'] = { ":cprev<cr>", "" },
    ['<C-s>'] = { ":w<cr>", "" },
    ['<S-TAB>'] = { ":tabprev<cr>", "" },
    ['<TAB>'] = { ":tabnext<cr>", "" },
    ['<leader><space>'] = { ":Telescope<cr>", "" },
    ['<leader>D'] = { ":lua require('neogen').generate()", "generate doxygen" },
    ['<leader>F'] = { ":Telescope find_files<cr>", "ts: Find files" },
    ['<leader>W'] = { ":Telescope lsp_dynamic_workspace_symbols<cr>", "lsp: Workspace symbols" },
    ['<leader>b'] = { ":Telescope buffers<cr>", "ts: buffers" },
    ['<leader>cc'] = { ":ColorizerToggle<cr>", "" },
    ['<leader>e'] = { ":NvimTreeToggle<cr>", "" },
    ['<leader>g'] = { ":Telescope live_grep<cr>", "ts: Live grep" },
    ['<leader>l'] = { ":Telescope repo list<cr>", "ts: Repository list" },
    ['<leader>o'] = { ":Telescope oldfiles<cr>", "ts: oldfiles" },
    ['<leader>s'] = { ":Telescope lsp_document_symbols<cr>", "lsp: Document Symbols" },
    ['<leader>t'] = { ":ToggleTerm<cr>", "" },
    ['<leader>z'] = { ":Telescope zoxide list<cr>", "ts: zoxide list" },
    ['<A-down>'] = { ":wincmd j<cr>", "" },
    ['<A-left>'] = { ":wincmd h<cr>", "" },
    ['<A-right>'] = { ":wincmd l<cr>", "" },
    ['<A-up>'] = { ":wincmd k<cr>", "" },
    ['<AS-down>'] = { ":wincmd -<cr>", "" },
    ['<AS-left>'] = { ":wincmd <<cr>", "" },
    ['<AS-right>'] = { ":wincmd ><cr>", "" },
    ['<AS-up>'] = { ":wincmd +<cr>", "" },
})
wk.register({
    ['<C-a>'] = { [[<Home>]], "go home" },
    ['<C-e>'] = { [[<End>]], "go end" },
    ['<C-b>'] = { [[<left>]], "left" },
    ['<C-f>'] = { [[<right>]], "right" },
}, { mode = "i" }) -- insert mode
wk.register({
    ['<C-h>'] = { [[<C-\><C-n><C-W>h]], "" },
    ['<C-j>'] = { [[<C-\><C-n><C-W>j]], "" },
    ['<A-down>'] = { [[<C-\><C-n><C-W>j]], "" },
    ['<C-k>'] = { [[<C-\><C-n><C-W>k]], "" },
    ['<A-up>'] = { [[<C-\><C-n><C-W>k]], "" },
    ['<C-l>'] = { [[<C-\><C-n><C-W>l]], "" },
    -- Normal Map
    ['<A-t>'] = { [[<C-\><C-n><Cmd>ToggleTerm<CR>]], "" },
}, { mode = "t" }) -- terminal mode
wk.register({
    ['<leader>f'] = { ":lua vim.lsp.buf.format()", "lsp: format selection" },
}, { mode = "v" }) -- visual mode

-- Auto commands
local user_group = vim.api.nvim_create_augroup('UserCommands', { clear = true })

vim.api.nvim_create_autocmd('BufWritePost', {
    command = 'source $MYVIMRC | PackerCompile',
    desc = 'reload config on save',
    group = user_group,
    pattern = vim.fn.expand('$MYVIMRC')
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

-- custom filetypes
vim.filetype.add({
    extension = {
        mke = "make",
    },
    pattern = {
        [".clang.*"] = "yaml"
    }
})
