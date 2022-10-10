local modules = {
    'options',
    'plugins',
    'config',
    'mappings',
    'lsp'
}

for i, a in ipairs(modules) do
    local ok, err = pcall(require, a)
    if not ok then
        error("Error calling " .. a .. err .. i)
    end
end


-- Auto commands
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})
vim.cmd [[ colorscheme dracula ]]
