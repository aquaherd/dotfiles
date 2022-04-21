-- Gitsigns
local present0, gitsigns = pcall(require, "gitsigns")
if present0 then
  gitsigns.setup {
    signs = {
      add = { hl = "DiffAdd", text = "│", numhl = "GitSignsAddNr" },
      change = { hl = "DiffChange", text = "│", numhl = "GitSignsChangeNr" },
      delete = { hl = "DiffDelete", text = "│", numhl = "GitSignsDeleteNr" },
      topdelete = { hl = "DiffDelete", text = "│", numhl = "GitSignsDeleteNr" },
      changedelete = { hl = "DiffChangeDelete", text = "│", numhl = "GitSignsChangeNr" },
    },
  }
end

-- Telescope
local present1, telescope = pcall(require, "telescope")
if present1 then
  telescope.setup {
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
  }
end

-- Nvim tree
local present2, nvim_tree = pcall(require, "nvim-tree")
if present2 then
  nvim_tree.setup {
    view = {
      width = 30,
      side = "left",
      hide_root_folder = true,
    },
    disable_netrw = true,
    hijack_cursor = true,
    update_cwd = true,
    update_to_buf_dir = {
      auto_open = false,
    },
  }
  vim.g.nvim_tree_indent_markers = 1
end

-- lualine
local present3, lualine = pcall(require, "lualine")
if present3 then
  lualine.setup {
    options = {
      component_separators = '|',
      section_separators = '',
      theme = 'dracula-nvim',
    },
      extensions = {
        'aerial',
        'nvim-tree',
        -- 'symbols-outline',
        'fugitive'
      },
  }
end

-- which-key
local present4, whichkey = pcall(require, "which-key")
if present4 then
  whichkey.setup {
  }
end

-- treesitter
local presentTT, treesitter = pcall(require, "nvim-treesitter.configs")
if presentTT then
  treesitter.setup {
    -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ensure_installed = {"bash", "c", "python", "cpp", "lua", "toml", "cmake"},
    --ignore_install = { "javascript" }, -- List of parsers to ignore installing
    highlight = {
      enable = true,              -- false will disable the whole extension
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

-- neogen
local present5, neogen = pcall(require, "neogen")
if present5 then
  neogen.setup {
    snippet_engine = 'luasnip'
  }
end

-- aerial
local present6, aerial = pcall(require, "aerial")
if present6 then
  aerial.setup {
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

-- toggleterm
local present7, toggleterm = pcall(require, "toggleterm")
if present7 then
  toggleterm.setup {
  }
end

-- surround
local haveSurround, surround = pcall(require, "surround")
if haveSurround then
  surround.setup {
    mappings_style = "sandwich" 
  }
end
