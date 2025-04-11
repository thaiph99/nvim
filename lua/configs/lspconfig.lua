require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local telescope = require "telescope.builtin"

local servers = { "html", "cssls", "pyright", "clangd", "gopls", "lua_ls" }
local nvlsp = require "nvchad.configs.lspconfig"

-- Change lsp.buf.references to telescope.builtin.lsp_references
local remapping = function(client, bufnr)
  nvlsp.on_attach(client, bufnr)
  vim.keymap.set("n", "gr", telescope.lsp_references, { buffer = bufnr, desc = "Telescope lsp go to references" })
  vim.keymap.set("n", "gd", telescope.lsp_definitions, { buffer = bufnr, desc = "Telescope lsp go to definitions" })
end

for _, lsp in ipairs(servers) do
  local config = {
    on_attach = remapping,
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
