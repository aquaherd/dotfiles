-- install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    is_bootstrap = true
    vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    vim.cmd [[ packadd packer.nvim ]]
end


require('packer').startup(function(use)

    -- Coding
    use 'wbthomason/packer.nvim'
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
            local t = require('telescope')
            t.setup {
                defaults = {
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
                    border = {},
                    -- borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                },
                extensions = {
                    zoxide = {},
                    repo = {},
                },
            }
            t.load_extension("zoxide")
            t.load_extension("repo")
        end
    }
    use 'jvgrootveld/telescope-zoxide'
    use 'cljoly/telescope-repo.nvim'
    --  use 'lukas-reineke/indent-blankline.nvim'
    use { 'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup {}
        end
    }

    -- Completion
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'saadparwaiz1/cmp_luasnip'
    use 'rafamadriz/friendly-snippets'
    use 'L3MON4D3/LuaSnip'

    -- treesitter
    use { 'nvim-treesitter/nvim-treesitter' } -- move?
    use 'nvim-treesitter/nvim-treesitter-textobjects'
    use { 'danymat/neogen', requires = { 'nvim-treesitter/nvim-treesitter' }, tag = '*',
        config = function()
            require('neogen').setup { snippet_engine = 'luasnip' }
        end
    }

    -- Side panes
    use 'kyazdani42/nvim-web-devicons' -- for file icons
    use { 'kyazdani42/nvim-tree.lua' }
    use { 'akinsho/toggleterm.nvim',
        config = function()
            require('toggleterm').setup {}
        end
    }
    use { 'stevearc/aerial.nvim',
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
    use 'neovim/nvim-lspconfig'
    use { 'williamboman/nvim-lsp-installer', requires = 'neovim/nvim-lspconfig' }

    -- non-lua
    use { 'tpope/vim-fugitive', cmd = { "Git" } }
    use { 'mboughaba/i3config.vim', ft = { 'i3config' } }

    -- status
    use { 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function()
            require('lualine').setup {
                options = {
                    globalstatus = true,
                    component_separators = '',
                    section_separators = '',
                    theme = 'dracula-nvim',
                    disabled_filetypes = { 'packer' },
                },
                extensions = {
                    'aerial',
                    'nvim-tree',
                    -- 'symbols-outline',
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
    use 'Mofiqul/dracula.nvim'
    use { "ur4ltz/surround.nvim",
        config = function()
            require('surround').setup { mappings_style = "sandwich" }
        end
    }
    use 'norcalli/nvim-colorizer.lua'
    use 'folke/which-key.nvim'

    if is_bootstrap then
        require('packer').sync();
    end
end)

if is_bootstrap then
    print 'hit enter, let packer sync go and restart nvim'
    return
end
