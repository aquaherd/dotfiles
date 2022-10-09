-- treesitter
local presentTT, treesitter = pcall(require, "nvim-treesitter.configs")
if presentTT then
    treesitter.setup {
        -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        ensure_installed = { "bash", "c", "python", "cpp", "lua", "toml", "cmake" },
        --ignore_install = { "javascript" }, -- List of parsers to ignore installing
        highlight = {
            enable = true, -- false will disable the whole extension
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

require('dracula').setup {
    italic_comment = true,
    transparent_bg = true,
    lualine_bg_color = "#282a36",
}
require("which-key").setup {}

require('nvim-tree').setup {
    view = {
        width = 30,
        side = "left",
        hide_root_folder = true,
    },
    disable_netrw = true,
    hijack_cursor = true,
    update_cwd = true,
    update_focused_file = {
        enable = true
    }
}
