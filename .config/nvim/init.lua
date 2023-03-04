-- first things first
local g = vim.g
local opt = vim.opt
local o = vim.o
g.mapleader = ' '
g.maplocalleader = ' '
-- package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath, })
end
vim.opt.rtp:prepend(lazypath)
-- plugins
require("lazy").setup({
    -- Theme
    {
        'Mofiqul/dracula.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('dracula').setup {
                italic_comment = true,
                transparent_bg = true,
                lualine_bg_color = "#282a36",
            }
            vim.cmd.colorscheme 'dracula'
        end
    },
    -- Coding
    {
        'lewis6991/gitsigns.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            signs = {
                add = { text = "+", numhl = "GitSignsAddNr" },
                change = { text = "~", numhl = "GitSignsChangeNr" },
                delete = { text = "-", numhl = "GitSignsDeleteNr" },
                topdelete = { text = "_", numhl = "GitSignsDeleteNr" },
                changedelete = { text = "~", numhl = "GitSignsChangeNr" },
            }
        }
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
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
    },
    'jvgrootveld/telescope-zoxide',
    { 'numToStr/Comment.nvim',   opts = {}, },
    {
        'lukas-reineke/indent-blankline.nvim',
        opts = {
            char = '┊',
            show_trailing_blankline_indent = false,
        },
    },
    -- treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        config = function()
            pcall(require('nvim-treesitter.install').update { with_sync = true })
        end,
    },
    {
        'danymat/neogen',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        opts = { snippet_engine = 'luasnip' },
        ft = 'c',
        cmd = { "Neogen" }
    },
    -- Side panes
    {
        'kyazdani42/nvim-tree.lua',
        cmd = 'NvimTreeToggle',
        dependencies = { 'kyazdani42/nvim-web-devicons' },
        opts = {
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
    },
    { 'akinsho/toggleterm.nvim', opts = {}, },
    {
        'stevearc/aerial.nvim',
        dependencies = { 'kyazdani42/nvim-web-devicons' },
        opts = {
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
    },
    -- lsp
    {
        'neovim/nvim-lspconfig',
        dependencies = { 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim',
            { 'j-hui/fidget.nvim', opts = {} }, 'folke/neodev.nvim', },
    },
    { 'hrsh7th/nvim-cmp',       dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' }, },
    -- non-lua
    { 'tpope/vim-fugitive',     cmd = { "Git" } },
    { 'mboughaba/i3config.vim', ft = { 'i3config' } },
    -- status
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'kyazdani42/nvim-web-devicons' },
        opts = {
            options = {
                globalstatus = true,
                component_separators = '',
                section_separators = '',
                theme = 'dracula',
            },
            extensions = {
                'aerial',
                -- 'nvim-tree',
                'fugitive',
                'toggleterm',
                'quickfix',
            },
            sections = {
                lualine_c = { { 'filename', path = 1 }, 'aerial' },
            }
        }
    },
    -- misc
    { 'norcalli/nvim-colorizer.lua', cmd = 'ColorizerToggle' },
    { 'folke/which-key.nvim',        dependencies = { 'kyazdani42/nvim-web-devicons' }, opts = {} },
})
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
        ['<A-down>'] = { ":wincmd j<cr>", "window down" },
        ['<A-left>'] = { ":wincmd h<cr>", "window left" },
        ['<A-right>'] = { ":wincmd l<cr>", "window right" },
        ['<A-t>'] = { ":ToggleTerm<cr>", "toggle terminal" },
        ['<A-up>'] = { ":wincmd k<cr>", "window up" },
        ['<AS-down>'] = { ":wincmd -<cr>", "resize window down" },
        ['<AS-left>'] = { ":wincmd <<cr>", "resize window left" },
        ['<AS-right>'] = { ":wincmd ><cr>", "resize window right" },
        ['<AS-up>'] = { ":wincmd +<cr>", "resize window up" },
        ['<C-n>'] = { ":cnext<cr>", "qflist next" },
        ['<C-p>'] = { ":cprev<cr>", "qflist prev" },
        ['<C-s>'] = { ":w<cr>", "save" },
        ['<S-TAB>'] = { ":tabprev<cr>", "previous tab" },
        ['<TAB>'] = { ":tabnext<cr>", "next tab" },
        ['<leader><space>'] = { ":Telescope<cr>", "telescope" },
        ['<leader>cg'] = { ":Gitsigns setqflist<cr>", "git changes" },
        ['<leader>cd'] = { ":Neogen<cr>", "generate doxygen" },
        ['<leader>F'] = { ":Telescope find_files<cr>", "ts: Find files" },
        ['<leader>W'] = { ":Telescope lsp_dynamic_workspace_symbols<cr>", "LSP: Workspace symbols" },
        ['<leader>b'] = { ":Telescope buffers<cr>", "ts: buffers" },
        ['<leader>cc'] = { ":ColorizerToggle<cr>", "colorizer" },
        ['<leader>e'] = { ":NvimTreeToggle<cr>", "tree" },
        ['<leader>g'] = { ":Telescope live_grep<cr>", "ts: Live grep" },
        ['<leader>o'] = { ":Telescope oldfiles<cr>", "ts: oldfiles" },
        ['<leader>s'] = { ":Telescope lsp_document_symbols<cr>", "LSP: Document Symbols" },
        ['<leader>t'] = { ":ToggleTerm<cr>", "toggle terminal" },
        ['<leader>z'] = { ":Telescope zoxide list<cr>", "ts: zoxide list" },
        ['[c'] = { ":Gitsigns prev_hunk<cr>", "prev hunk" },
        [']c'] = { ":Gitsigns next_hunk<cr>", "next hunk" },
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
        ['<A-t>'] = { [[<C-\><C-n><Cmd>ToggleTerm<CR>]], "toggle terminal" },
}, { mode = "t" }) -- terminal mode
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
local on_attach = function(_, bufnr)
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end
    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>f', vim.lsp.buf.format, '[F]ormat buffer')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')
end
local servers = {
    clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    -- tsserver = {},
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
}
require('neodev').setup()
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
require('mason').setup()
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
-- nvim-cmp setup
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
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
}
-- treesitter setup
require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'jsonc', 'lua', 'python', 'rust', 'help', 'vim' },
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
