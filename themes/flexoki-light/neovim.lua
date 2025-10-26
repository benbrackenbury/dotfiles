vim.pack.add({
    "https://github.com/kepano/flexoki-neovim"
})

require("flexoki").setup()

vim.cmd("colorscheme flexoki-light")
vim.cmd("set background=light")
