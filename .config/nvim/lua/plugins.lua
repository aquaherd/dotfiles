local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

vim.cmd [[ packadd packer.nvim ]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- use 'norcalli/nvim-base16.lua'
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  if ( vim.version().major > 0 or vim.version().minor  >= 6 ) then
    use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } } -- Just something one might use
    use 'jvgrootveld/telescope-zoxide'
    use 'cljoly/telescope-repo.nvim'
  end
  use 'lukas-reineke/indent-blankline.nvim'
  use 'numToStr/Comment.nvim'

  -- Completion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'saadparwaiz1/cmp_luasnip'
  use 'rafamadriz/friendly-snippets'
  use 'L3MON4D3/LuaSnip'

  -- Tree
  use 'kyazdani42/nvim-web-devicons' -- for file icons
  use 'kyazdani42/nvim-tree.lua'

  -- treesitter
  use 'nvim-treesitter/nvim-treesitter'
  use { 'danymat/neogen', requires = { 'nvim-treesitter/nvim-treesitter' }, tag = '*' }
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'stevearc/aerial.nvim'

  -- lsp
  use 'neovim/nvim-lspconfig'
  use { 'williamboman/nvim-lsp-installer', requires = 'neovim/nvim-lspconfig' }

  -- non-lua
  use 'tpope/vim-fugitive'
  use 'mboughaba/i3config.vim'

  -- status
  use { 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons', opt = true }}

  -- misc
  use 'akinsho/toggleterm.nvim'
  use 'Mofiqul/dracula.nvim'
  use 'ur4ltz/surround.nvim'
  use 'norcalli/nvim-colorizer.lua'
  use 'folke/which-key.nvim'
end)

