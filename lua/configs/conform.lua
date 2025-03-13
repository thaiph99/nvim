local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    c_cpp = { "clang-format" },
    cpp = { "clang-format" },
    c = { "clang-format" },
    python = { "isort", "black" },
    go = { "goimports", "gofmt" },
    sh = { "shfmt" },
    javascript = { "prettierd", "prettier" },
    cmake = { "cmake_format" },
    yaml = { "yamlfmt" },
    markdown = { "markdownlint" },
    json = { "jq" },
    bazel = { "buildifier" },
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
