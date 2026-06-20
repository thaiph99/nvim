require("mason").setup {}

local ok_blink, blink = pcall(require, "blink.cmp")
local capabilities = ok_blink and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()
vim.lsp.config("*", { capabilities = capabilities })

vim.diagnostic.config {
  virtual_text = { prefix = "●" },
  severity_sort = true,
  float = { border = "rounded" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅙",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "󰋼",
      [vim.diagnostic.severity.HINT] = "󰌵",
    },
  },
}

vim.o.winborder = "rounded"

local servers = {
  html = {},
  cssls = {},
  pyright = { root_markers = { "requirements.txt", "pyproject.toml", ".git" } },
  clangd = {
    cmd = { "clangd", "--background-index", "--clang-tidy" },
    root_markers = { "compile_commands.json", ".clangd", ".git" },
  },
  gopls = {},
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  ts_ls = {},
}

for name, opts in pairs(servers) do
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end

vim.lsp.config("uranus_yaml", {
  cmd = { "uranus-yaml-lsp", "--stdio" },
  filetypes = { "yaml", "yml" },
  root_markers = { ".git", "package.json" },
})
vim.lsp.enable "uranus_yaml"

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
  callback = function(event)
    local bufnr = event.buf
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
    end

    -- Drop Neovim's default gr* mappings
    for _, lhs in ipairs { "grr", "gri", "grt", "gra", "grn", "grx" } do
      pcall(vim.keymap.del, "n", lhs)
    end

    local tb = require "telescope.builtin"
    map("n", "gd", tb.lsp_definitions, "LSP definitions")
    map("n", "gD", tb.lsp_type_definitions, "LSP type definitions")
    map("n", "gr", tb.lsp_references, "LSP references")
    map("n", "gi", tb.lsp_implementations, "LSP implementations")
    map("n", "K", vim.lsp.buf.hover, "Hover docs")
    map("n", "<leader>ra", vim.lsp.buf.rename, "LSP rename")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP code action")
    map("n", "<leader>sh", vim.lsp.buf.signature_help, "Signature help")

    -- Highlight references to the symbol under the cursor on hold, clear on move.
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method "textDocument/documentHighlight" then
      local hl_group = vim.api.nvim_create_augroup("user_lsp_doc_hl_" .. bufnr, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = hl_group,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = hl_group,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})
