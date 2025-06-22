require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

local servers = { "html", "cssls", "pyright", "clangd", "gopls", "lua_ls" }
local nvlsp = require "nvchad.configs.lspconfig"

-- Load telescope once at startup (lazy loading)
local telescope_builtin
local function get_telescope()
  if not telescope_builtin then
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
      telescope_builtin = builtin
    end
  end
  return telescope_builtin
end

-- Set up global LSP mappings with telescope
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    local telescope = get_telescope()

    -- Call NvChad's default on_attach first
    if nvlsp.on_attach then
      nvlsp.on_attach(vim.lsp.get_client_by_id(ev.data.client_id), ev.buf)
    end

    if not telescope then
      return -- Skip if telescope is not available
    end

    -- Override default LSP mappings with telescope (batch keymaps for performance)
    local keymaps = {
      { "gr", telescope.lsp_references, "Telescope lsp references" },
      { "gd", telescope.lsp_definitions, "Telescope lsp definitions" },
      { "gD", telescope.lsp_declarations, "Telescope lsp declarations" },
      { "gi", telescope.lsp_implementations, "Telescope lsp implementations" },
      { "gt", telescope.lsp_type_definitions, "Telescope lsp type definitions" },
    }

    for _, keymap in ipairs(keymaps) do
      local key, func, desc = keymap[1], keymap[2], keymap[3]
      if func then
        vim.keymap.set("n", key, func, vim.tbl_extend("force", opts, { desc = desc }))
      end
    end
  end,
})

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
