local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    c_cpp = { "clang-format" },
    cpp = { "clang-format" },
    c = { "clang-format" },
    python = { "isort", "black" },
    go = { "gofmt", "goimports" },
    sh = { "shfmt" },
    javascript = { "prettierd", "prettier" },
    cmake = { "cmake_format" },
    yaml = { "yamlfmt" },
    markdown = { "markdownlint" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  formatters = {
    clang_format = {
      -- prepend_args = { "--style=file:/home/thaiph/.config/nvim/lua/configs/.clang-format", "--fallback-style=LLVM" },
      prepend_args = { "--style=file:/home/thaiph/.config/nvim/lua/configs/.clang-format" },
    },
  },
  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
