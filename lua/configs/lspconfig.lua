require("nvchad.configs.lspconfig").defaults()

local servers = {
  html = {},
  cssls = {},
  pyright = {
    root_markers = { "requirements.txt", ".git" },
  },
  clangd = {
    cmd_env = {
      CPLUS_INCLUDE_PATH = table.concat({
        "/usr/include/c++/11",
        "/usr/include/x86_64-linux-gnu/c++/11",
        "/usr/include/c++/11/backward",
        "/usr/lib/gcc/x86_64-linux-gnu/11/include",
        "/usr/local/include",
        "/usr/lib/gcc/x86_64-linux-gnu/11/include-fixed",
        "/usr/include/x86_64-linux-gnu",
        "/usr/include",
      }, ":"),
    },
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
