local M = {}

M.palette = {
  bg = '#f0efeb',
  bg_alt = '#e0dcd4',

  base0 = '#f5f4f2',
  base1 = '#efeeed',
  base2 = '#e5e3e0',
  base3 = '#d8d6d3',
  base4 = '#b8b5b0',
  base5 = '#9a9791',
  base6 = '#7d7a75',
  base7 = '#5f5c58',
  base8 = '#2d2a27',

  fg = '#1a1d21',
  fg_alt = '#4A4D51',

  red = '#8B6666',
  orange = '#7A6D5A',
  green = '#5A6B5A',
  yellow = '#8B7E52',
  blue = '#5A6B7A',
  cyan = '#64757d',
  teal = '#4D6B6B',
  dark_cyan = '#546470',
}

local p = M.palette
local set = vim.api.nvim_set_hl

-- UI
set(0, 'Normal', { fg = p.fg, bg = p.bg_alt })
set(0, 'CursorLine', { bg = p.base2 })
set(0, 'LineNr', { fg = p.base7 })
set(0, 'CursorLineNr', { fg = p.base8, bold = true })
set(0, 'Visual', { bg = p.base7, fg = p.bg })
set(0, 'Cursor', { fg = p.bg, bg = p.base8 })

-- Syntax
set(0, 'Comment', { fg = p.base7, italic = true })
set(0, 'String', { fg = p.fg })
set(0, 'Function', { fg = p.fg })
set(0, 'Identifier', { fg = p.blue })
set(0, 'Keyword', { fg = p.blue, bold = true })
set(0, 'Operator', { fg = p.green, bold = true })
set(0, 'Type', { fg = p.blue, bold = true })

-- Diagnostics
set(0, 'DiagnosticError', { fg = p.red })
set(0, 'DiagnosticWarn', { fg = p.yellow })
set(0, 'DiagnosticInfo', { fg = p.green })
set(0, 'DiagnosticHint', { fg = p.base7 })

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
vim.api.nvim_set_hl(0, "TabLine", { bg = "none" })
vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none" })
vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "none" })
vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { bg = "none" })

vim.api.nvim_set_hl(0, 'LineNrNC', { fg = '#404040' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = '#808080' })

