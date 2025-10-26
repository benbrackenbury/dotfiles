vim.pack.add({
    "https://github.com/neanias/everforest-nvim" ,
})

require("everforest").setup({
    colorscheme = "everforest",
    background = "soft",
})

vim.cmd("colorscheme everforest")
vim.cmd("set background=dark")
