vim.pack.add({
    "https://github.com/ribru17/bamboo.nvim"
})

require("bamboo").setup({
})

vim.cmd("colorscheme bamboo")
vim.cmd("set background=dark")
