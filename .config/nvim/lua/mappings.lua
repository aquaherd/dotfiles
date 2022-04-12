local active = false

local function map (mode, keys, command)
  vim.api.nvim_set_keymap(mode, keys, command, { noremap = true, silent = true })
end

local function nmap(keys, command)
  map("n", keys, command .. " <CR>")
end

local function vmap(keys, command)
  map("v", keys, command .. " <CR>")
end

local function imap(keys, command)
  map("i", keys, command)
end

local function tmap(keys, command)
  map("t", keys, command)
end

function Minimal()
  if active then
    vim.cmd [[
      set number relativenumber noshowmode showtabline=1 laststatus=2 signcolumn=yes foldcolumn=0 
      au WinEnter,BufEnter, * set number relativenumber 
    ]]
    active = false
  else
    vim.cmd [[
      set nonumber norelativenumber showmode showtabline=0 laststatus=0 signcolumn=no foldcolumn=1
      au WinEnter,BufEnter, * set nonumber norelativenumber 
    ]]
    active = true
  end
end

-- Normal Map
nmap("<TAB>", ":tabnext")
nmap("<S-TAB>", ":tabprev")
nmap("<leader>t", ":ToggleTerm")

nmap("<leader>x", ":q")
nmap("<C-S>", ":w")

nmap("<C-N>", ":cnext")
nmap("<C-P>", ":cprev")
-- nmap("<A-O>", ":colder")

-- Minimal toggle
nmap("<leader>m", ":lua Minimal()")

-- Telescope
nmap("<leader>/", ":lua require('Comment.api').toggle_current_linewise()")
nmap("<leader><space>", ":Telescope")
nmap("<leader>F", ":Telescope find_files")
nmap("<leader>b", ":Telescope buffers")
nmap("<leader>o", ":Telescope oldfiles")
nmap("<leader>s", ":Telescope lsp_document_symbols")
nmap("<leader>W", ":Telescope lsp_workspace_symbols")


-- NvimTree
nmap("<leader>e", ":NvimTreeToggle")

-- Neogen
nmap("<leader>rd", ":lua require('neogen').generate()")

-- Visual Map
vmap("<leader>/", ":lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())")

-- Terminal map
-- tmap("<esc>", [[<C-\><C-n>]])
tmap('<C-h>', [[<C-\><C-n><C-W>h]])
tmap('<C-j>', [[<C-\><C-n><C-W>j]])
tmap('<C-k>', [[<C-\><C-n><C-W>k]])
tmap('<C-l>', [[<C-\><C-n><C-W>l]])

-- insert mode
imap ('<C-a>', [[<Home>]])
imap ('<C-e>', [[<End>]])
imap ('<C-b>', [[<left>]])
imap ('<C-f>', [[<right>]])
