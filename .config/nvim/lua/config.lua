-- Gitsigns
local present, gitsigns = pcall(require, "gitsigns")
if present then
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
local present, telescope = pcall(require, "telescope")
if present then
  telescope.setup {
    defaults = {
      file_ignore_patterns = {
        "%.jpg",
        "%.jpeg",
        "%.png",
        "%.otf",
        "%.ttf",
        "node_modules",
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
local present, nvim_tree = pcall(require, "nvim-tree")
if present then
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
local present, lualine = pcall(require, "lualine")
if present then
  lualine.setup {
    options = {
      component_separators = '|',
      section_separators = '',
      theme = 'dracula',
    }
  }
end

-- which-key 
local present, whichkey = pcall(require, "which-key")
if present then
  whichkey.setup {
  }
end

-- treesitter
-- ????
-- neogen 
local present, neogen = pcall(require, "neogen")
if present then
  neogen.setup {
    snippet_engine = 'luasnip'
  }
end



