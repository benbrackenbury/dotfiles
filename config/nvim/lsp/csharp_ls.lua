---@brief
---
--- https://github.com/razzmatazz/csharp-language-server
---
--- Language Server for C#.
---
--- csharp-ls requires the [dotnet-sdk](https://dotnet.microsoft.com/download) to be installed.
---
--- The preferred way to install csharp-ls is with `dotnet tool install --global csharp-ls`.

return {
  cmd = { 'csharp-ls' },
  root_dir = function(bufnr)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    return vim.fs.dirname(
      vim.fs.find({ '*.sln' }, { path = fname, upward = true })[1]
      or vim.fs.find({ '*.slnx' }, { path = fname, upward = true })[1]
      or vim.fs.find({ '*.csproj' }, { path = fname, upward = true })[1]
    )
  end,
  filetypes = { 'cs' },
  init_options = {
    AutomaticWorkspaceInit = true,
  },
}
