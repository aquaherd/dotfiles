local active = false
local hwk, wk = pcall(require, "which-key")

local function map(mode, keys, command, desc)
    vim.api.nvim_set_keymap(mode, keys, command, { noremap = true, silent = true, desc = desc })
    if hwk and not desc == nil then
        wk.register({ keys = { desc } }, { mode = mode })
    end
end

local function nmap(keys, command, desc)
    map("n", keys, command .. " <CR>", desc)
end

local function vmap(keys, command, desc)
    map("v", keys, command .. " <CR>", desc)
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
nmap("<A-t>", ":ToggleTerm")

nmap("<leader>x", ":q")
nmap("<C-S>", ":w")

nmap("<C-N>", ":cnext")
nmap("<C-P>", ":cprev")
-- nmap("<A-O>", ":colder")

nmap('<A-down>', ":wincmd j")
nmap('<A-left>', ":wincmd h")
nmap('<A-right>', ":wincmd l")
nmap('<A-up>', ":wincmd k")
nmap('<AS-down>', ":wincmd -")
nmap('<AS-left>', ":wincmd <")
nmap('<AS-right>', ":wincmd >")
nmap('<AS-up>', ":wincmd +")

-- Minimal toggle
nmap("<leader>m", ":lua Minimal()", "Minimal mode")

-- Telescope
nmap("<leader><space>", ":Telescope")
nmap("<leader>F", ":Telescope find_files", "ts: Find files")
nmap("<leader>W", ":Telescope lsp_dynamic_workspace_symbols", "lsp: Workspace symbols")
nmap("<leader>b", ":Telescope buffers", "ts: buffers")
nmap("<leader>cc", ":ColorizerToggle")
nmap("<leader>g", ":Telescope live_grep", "ts: Live grep")
nmap("<leader>l", ":Telescope repo list", "ts: Repository list")
nmap("<leader>o", ":Telescope oldfiles", "ts: oldfiles")
nmap("<leader>s", ":Telescope lsp_document_symbols", "lsp: Document Symbols")
nmap("<leader>z", ":Telescope zoxide list", "ts: zoxide list")

-- NvimTree
nmap("<leader>e", ":NvimTreeToggle")

-- Neogen
nmap("<leader>rd", ":lua require('neogen').generate()", "generate doxygen")

-- Visual Map
vmap("<leader>f", ":lua vim.lsp.buf.range_format()", "lsp: format selection")

-- Terminal map
-- tmap("<esc>", [[<C-\><C-n>]])
tmap('<C-h>', [[<C-\><C-n><C-W>h]])
tmap('<C-j>', [[<C-\><C-n><C-W>j]])
tmap('<A-down>', [[<C-\><C-n><C-W>j]])
tmap('<C-k>', [[<C-\><C-n><C-W>k]])
tmap('<A-up>', [[<C-\><C-n><C-W>k]])
tmap('<C-l>', [[<C-\><C-n><C-W>l]])
tmap('<A-t>', [[<C-\><C-n><Cmd>ToggleTerm<CR>]])

-- insert mode
imap('<C-a>', [[<Home>]])
imap('<C-e>', [[<End>]])
imap('<C-b>', [[<left>]])
imap('<C-f>', [[<right>]])
