require("nightfox").setup({
    options = {
        transparent = true,
    },
    modules = {
        "telescope",
        "treesitter",
        "native_lsp",
        "lazy.nvim"
    }

})

vim.cmd 'colorscheme carbonfox'
