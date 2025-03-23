require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

local servers = { "html", "cssls", "pyright", "clangd", "gopls" }
local nvlsp = require "nvchad.configs.lspconfig"

-- Change lsp.buf.references to telescope.builtin.lsp_references
local remapping = function(client, bufnr)
  nvlsp.on_attach(client, bufnr)
  vim.keymap.set(
    "n",
    "gr",
    "<cmd>Telescope lsp_references<cr>",
    { buffer = bufnr, desc = "Telescope lsp go to references" }
  )
end

for _, lsp in ipairs(servers) do
  local config = {
    on_attach = remapping,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }

  if lsp == "pyright" then
    config.root_dir = lspconfig.util.root_pattern(".git", "requirements.txt")
  end
  lspconfig[lsp].setup(config)
end
