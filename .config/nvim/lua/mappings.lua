local active = false
local hwk, wk = pcall(require, "which-key")

local function map (mode, keys, command, desc)
  vim.api.nvim_set_keymap(mode, keys, command, { noremap = true, silent = true, desc = desc })
  if hwk and not desc == nil then
    wk.register({keys = { desc }}, { mode = mode})
  end
end

local function nmap(keys, command, desc)
  map("n", keys, command .. " <CR>", desc)
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
      set number relativenumber noshowmode showtabline=1 laststatus=3 signcolumn=yes foldcolumn=0 
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
nmap("<leader>m", ":lua Minimal()", "Minimal mode")

-- Telescope
nmap("<leader><space>", ":Telescope")
nmap("<leader>F", ":Telescope find_files")
nmap("<leader>W", ":Telescope lsp_dynamic_workspace_symbols")
nmap("<leader>b", ":Telescope buffers")
nmap("<leader>c", ":ColorizerToggle")
nmap("<leader>g", ":Telescope live_grep")
nmap("<leader>l", ":Telescope repo list")
nmap("<leader>o", ":Telescope oldfiles")
nmap("<leader>s", ":Telescope lsp_document_symbols")
nmap("<leader>z", ":Telescope zoxide list")

-- NvimTree
nmap("<leader>e", ":NvimTreeToggle")

-- Neogen
nmap("<leader>rd", ":lua require('neogen').generate()")

-- Visual Map
vmap("<leader>f", ":lua vim.lsp.buf.range_formatting()")
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
