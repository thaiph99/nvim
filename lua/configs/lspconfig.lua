require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local servers = { "html", "cssls", "pyright", "clangd", "gopls", "lua_ls", "ts_ls" }
local nvlsp = require "nvchad.configs.lspconfig"

for _, lsp in ipairs(servers) do
  local config = {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }

  if lsp == "pyright" then
    config.root_dir = lspconfig.util.root_pattern(".git", "requirements.txt")
  elseif lsp == "clangd" then
    config.root_dir = lspconfig.util.root_pattern "."
  end
  lspconfig[lsp].setup(config)
end
