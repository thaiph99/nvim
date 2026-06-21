require("conform").setup {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    go = { "goimports", "gofumpt" },
    sh = { "shfmt" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    cmake = { "cmake_format" },
    yaml = { "prettier" },
    markdown = { "markdownlint" },
    json = { "prettier" },
    java = { "google-java-format" },
    cpp = { "clang-format" },
    c = { "clang-format" },
  },
}
