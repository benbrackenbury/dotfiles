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
vim.opt.scrolloff = 16
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.o.winborder = "rounded"
vim.o.pumborder = 'rounded'
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.o.completeopt = "noselect,menuone,popup,fuzzy"
vim.opt.cursorline = true
vim.o.exrc = true

vim.diagnostic.config({
    virtual_text = {
        severity = {
            vim.diagnostic.severity.ERROR
        },
        current_line = false
    },
    virtual_lines = {
        severity = {
            vim.diagnostic.severity.ERROR
        },
        current_line = true
    },
})

vim.pack.add({
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
    "https://github.com/nvim-treesitter/nvim-treesitter-context",
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
    "https://github.com/windwp/nvim-autopairs",
    "https://github.com/AndrewRadev/tagalong.vim",
    "https://github.com/folke/ts-comments.nvim",
})
require("mason").setup()
require('oil').setup({})
require('treesj').setup({})
require('mini.surround').setup({})
require("nvim-autopairs").setup {}
require("nvim-treesitter.configs").setup({
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["as"] = "@local.scope",
            },
            selection_modes = {
                ['@parameter.outer'] = 'v',
                ['@function.outer'] = 'V',
                ['@class.outer'] = '<c-v>',
            },
            include_surrounding_whitespace = true,
        },
    },
})

require('telescope').setup {
    defaults = {
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                prompt_position = "top",
            },
        },
        sorting_strategy = "ascending",
    },
}

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>oo", "<CMD>Oil<CR>")
vim.keymap.set("n", "<leader>ot", "<CMD>tab Oil<CR>")
vim.keymap.set("n", "<leader>ov", "<CMD>vert Oil<CR>")
vim.keymap.set("n", "<leader>oh", "<CMD>belowright Oil<CR>")
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
vim.keymap.set("n", "<leader>ff", "<CMD>Telescope find_files<CR>")
vim.keymap.set("n", "<leader>fg", "<CMD>Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>fG", "<CMD>Telescope grep_string<CR>")
vim.keymap.set("n", "<leader>fs", "<CMD>Telescope lsp_document_symbols<CR>")
vim.keymap.set("n", '<leader>i', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ 0 }), { 0 }) end)
vim.keymap.set("n", "<leader>fS", "<CMD>Telescope lsp_workspace_symbols<CR>")
vim.keymap.set("n", "<leader>fr", "<CMD>Telescope lsp_references<CR>")
vim.keymap.set("n", "<leader>fR", "<CMD>Telescope lsp_incoming_calls<CR>")
vim.keymap.set("n", "<leader>fd", function() require('telescope.builtin').diagnostics({ severity_limit = 'Error' }) end)
vim.keymap.set("n", "<leader>fD", "<CMD>Telescope diagnostics<CR>")
vim.keymap.set("n", "<leader>d",
    function() vim.diagnostic.setqflist({ open = true, severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set("n", "<leader>D", function() vim.diagnostic.setqflist({ open = true }) end)
vim.keymap.set("i", "jk", "<esc>l")
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<leader>fm", function()
    require("conform").format()
end)
vim.keymap.set("n", "<c-d>", "<c-d>zz")
vim.keymap.set("n", "<c-u>", "<c-u>zz")
vim.keymap.set("n", "<leader>vrc", "<CMD>tabe ~/.config/nvim/init.lua<CR>")
vim.keymap.set({ 'n', 'v' }, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>yef", "<CMD>!cat % | pbcopy<CR>")

for _, key in pairs({ '<Up>', '<Down>', '<Left>', '<Right>' }) do
    vim.keymap.set({ 'n', 'v', 'x', 'i' }, key, '<nop>')
end

local lsp_servers = {
    'lua_ls',
    'ts_ls',
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
    'ast_grep',
    'rust_analyzer',
    'clangd',
}
for _, server in ipairs(lsp_servers) do
    local path = vim.fn.stdpath('config') .. '/lsp/' .. server .. '.lua'
    if vim.fn.filereadable(path) == 1 then
        vim.lsp.config(server, dofile(path))
    end
end
vim.lsp.enable(lsp_servers)

require("conform").setup({
    formatters_by_ft = {
        php = { "pint" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        ruby = { "rubocop" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        go = { "gofumpt" },
        html = { "prettier" },
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


vim.pack.add({
    'https://github.com/rktjmp/lush.nvim',
    'https://github.com/zenbones-theme/zenbones.nvim',
    'https://github.com/f-person/auto-dark-mode.nvim',
    'https://github.com/xiyaowong/transparent.nvim',
})
vim.g.neobones = { transparent_background = true }
require("auto-dark-mode").setup({
    set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        vim.cmd.colorscheme("neobones")
        end,
    set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd.colorscheme("default")
    end,
    update_interval = 100,
})

vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
        require("transparent").clear()  -- still useful for other groups
    end,
})
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
    require("transparent").clear()  -- still useful for other groups


vim.pack.add({ 'https://github.com/dmtrKovalenko/fff.nvim' })
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(event)
    if event.data.updated then
      require('fff.download').download_or_build_binary()
    end
  end,
})
-- the plugin will automatically lazy load
vim.g.fff = {
  lazy_sync = true, -- start syncing only when the picker is open
  debug = {
    enabled = true,
    show_scores = true,
  },
}
vim.keymap.set('n', '<leader>ff', function() require('fff').find_files() end, { desc = 'FFFind files' })
vim.keymap.set('n', '<leader>fg', function() require('fff').live_grep() end, { desc = 'FFFind live grep' })
