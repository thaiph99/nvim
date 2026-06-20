local ensure_installed = {
  "bash",
  "fish",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "printf",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
  "json",
  "c",
  "cpp",
  "cmake",
  "make",
  "typescript",
  "javascript",
  "java",
  "go",
  "python",
}

local ts = require "nvim-treesitter"

local installed = ts.get_installed and ts.get_installed() or {}
local to_install = vim
    .iter(ensure_installed)
    :filter(function(p)
      return not vim.tbl_contains(installed, p)
    end)
    :totable()
if #to_install > 0 then
  ts.install(to_install)
end

-- Start treesitter highlighting + indentation per buffer
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
