local prettier = require('efmls-configs.formatters.prettier')
local languages = {
  javascript = { prettier },
  javascriptreact = { prettier },
  typescript = { prettier },
  typescriptreact = { prettier },
}
return {
  cmd = { 'efm-langserver' },
  root_markers = { '.git' },
  filetypes = vim.tbl_keys(languages),
  settings = { languages = languages },
  init_options = { documentFormatting = true, documentRangeFormatting = true },
}
