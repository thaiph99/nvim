local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    go = { "goimports", "gofumpt" },
    sh = { "shfmt" },
    javascript = { "prettierd", "prettier" },
    cmake = { "cmake_format" },
    yaml = { "prettier" },
    markdown = { "markdownlint" },
    json = { "prettier" },
    java = {},
    bazel = { "buildifier" },
    -- c_cpp = { "clang-format" },
    -- cpp = { "clang-format" },
    -- c = { "clang-format" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
