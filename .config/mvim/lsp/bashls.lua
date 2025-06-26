---@type vim.lsp.Config
return {
    cmd = { "bash-language-server", "start" },
    root_markers = { ".git", ".cfg" },
    filetypes = { "sh", "bash" },
} 
