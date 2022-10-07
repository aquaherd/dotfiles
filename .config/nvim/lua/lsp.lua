-- lsp
-- Disable virtual text
vim.diagnostic.config({
  virtual_text = false,
})
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions

local function gmap(mode, keys, command, desc)
    vim.api.nvim_set_keymap(mode, keys, command, {noremap = true, silent = true, desc = desc})
end

local function bmap(bufnr, mode, keys, command, desc)
    vim.api.nvim_buf_set_keymap(bufnr, mode, keys, command, {noremap = true, silent=true,desc=desc})
end

gmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', "lsp: go to previous diagnostic")
gmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', "lsp: go to next diagnostic")
gmap('n', '<leader>q', '<cmd>lua vim.diagnostic.setqflist()<CR>', "lsp: show diagnostics in qflist")
gmap('n', '<leader>h', '<cmd>lua vim.diagnostic.open_float()<CR>', "lsp: show diagnostic in float")

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  bmap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', "lsp: signature help")
  bmap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', "lsp: go to type definition")
  bmap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', "lsp: code action")
  bmap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.format()<CR>', "lsp: format buffer")
  bmap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', "lsp: rename symbol")
  bmap(bufnr, 'n', 'F2', '<cmd>lua vim.lsp.buf.rename()<CR>', "lsp: rename symbol")
  bmap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', "lsp: hover help")
  bmap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', "lsp: go to declaration")
  bmap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', "lsp: go to definition")
  bmap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', "lsp: go to implementation")
  bmap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', "lsp: go to references")
end

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

local servers = { 'pyright', 'clangd', 'cmake', 'bashls', 'sumneko_lua' }
local lspconfig = require 'lspconfig'
require("nvim-lsp-installer").setup {
  ensure_installed = servers
}
for _, lsp in pairs(servers) do

  local settings = {}
  if lsp == 'sumneko_lua' then
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Setup your lua path
          path = runtime_path,
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { 'vim' },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    }
  end
  lspconfig[lsp].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = settings,
  }
end

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete({}),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}
