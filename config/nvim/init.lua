vim.opt.mouse = ""
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 16
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.o.winborder = "rounded"
vim.o.pumborder = 'rounded'
vim.o.completeopt = "noselect,menuone,popup,fuzzy"
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.o.exrc = true
vim.o.secure = true

vim.diagnostic.config({
    virtual_lines = false,
    virtual_text = false,
})

vim.pack.add({
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/tpope/vim-fugitive",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/Wansmer/treesj",
    "https://github.com/echasnovski/mini.surround",
    "https://github.com/mbbill/undotree",
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/christoomey/vim-tmux-navigator",
    "https://github.com/stevearc/conform.nvim",
    "https://github.com/olimorris/codecompanion.nvim",
})
require("mason").setup()
require('oil').setup({})
require('treesj').setup({})
require('mini.surround').setup({})
require("nvim-treesitter.configs").setup({
    auto_install = true,
    highlight = { enable = true },
})

require("codecompanion").setup({
    strategies = {
        chat = {
            adapter = "xai",
        },
        inline = {
            adapter = "xai",
        }
    },
    adapters = {
        http = {
            xai = function()
                return require("codecompanion.adapters").extend("xai", {
                    env = {
                        api_key = "cmd:gpg -qd ~/.secrets/xai-api-key.gpg",
                    },
                    schema = {
                        model = {
                            default = "grok-code-fast",
                        },
                    },
                })
            end,
        },
    },
})

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>oo", "<CMD>Oil<CR>")
vim.keymap.set("n", "<leader>ot", "<CMD>tab Oil<CR>")
vim.keymap.set("n", "<leader>ov", "<CMD>vert Oil<CR>")
vim.keymap.set("n", "<leader>oh", "<CMD>belowright Oil<CR>")
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
vim.keymap.set("n", "<leader>ff", "<CMD>Telescope find_files<CR>")
vim.keymap.set("n", "<leader>fg", "<CMD>Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>ft", "<CMD>Telescope filetypes<CR>")
vim.keymap.set("n", "<leader>fb", "<CMD>Telescope buffers<CR>")
vim.keymap.set("i", "jk", "<esc>l")
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<leader>fm", vim.lsp.buf.format)
vim.keymap.set("n", "<c-d>", "<c-d>zz")
vim.keymap.set("n", "<c-u>", "<c-u>zz")
vim.keymap.set("n", "<leader>vrc", "<CMD>tabe ~/.config/nvim/init.lua<CR>")
vim.keymap.set({ 'n', 'v' }, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>yef", "<CMD>!cat % | pbcopy<CR>")

for _, key in pairs({ '<Up>', '<Down>', '<Left>', '<Right>' }) do
    vim.keymap.set({ 'n', 'v', 'x', 'i' }, key, '<nop>')
end

vim.lsp.enable({
    'lua_ls',
    'ts_ls',
    'tailwindcss',
    'emmet_language_server',
    'gopls',
    'intelephense',
    'docker_language_server',
    'docker_compose_language_service',
    'csharp_ls',
    'laravel_ls',
    'jsonls',
    'sourcekit',
    'ruby_lsp',
    'biome',
})

require("conform").setup({
    formatters_by_ft = {
        php = { "php_cs_fixer" },
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
    },
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight_yank', {}),
    desc = 'Hightlight selection on yank',
    pattern = '*',
    callback = function()
        vim.highlight.on_yank { higroup = 'IncSearch', timeout = 500 }
    end,
})

vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
    callback = function(ev)
        vim.wo.cursorline = ev.event == "WinEnter"
    end,
})
vim.wo.cursorline = true

dofile(vim.fn.expand('~') .. "/dotfiles/themes/current/neovim.lua")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
