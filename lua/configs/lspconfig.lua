require("nvchad.configs.lspconfig").defaults()

local servers = {
  html = {},
  cssls = {},
  pyright = {
    root_markers = { "requirements.txt", ".git" },
  },
  clangd = {
    cmd = { "clangd", "--background-index", "--clang-tidy" },
    root_marker = { "." },
  },
  gopls = {},
  lua_ls = {},
  ts_ls = {},
}

for name, opts in pairs(servers) do
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end
