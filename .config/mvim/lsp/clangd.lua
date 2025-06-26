---@type vim.lsp.Config
return {
    cmd = { "clangd" },
    root_markers = { ".clangd", ".clang-format", ".git" },
    filetypes = { "c", "cpp" },
} 
