local ensure_installed = {
  "bash",
  "fish",
  "lua",
  "luadoc",
  "markdown",
  "printf",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
  "c",
  "cpp",
  "cmake",
  "make",
  "typescript",
  "javascript",
  "java",
}

return function()
  local already_installed = require("nvim-treesitter.config").get_installed()
  local to_install = vim
    .iter(ensure_installed)
    :filter(function(p)
      return not vim.tbl_contains(already_installed, p)
    end)
    :totable()
  if #to_install > 0 then
    require("nvim-treesitter").install(to_install)
  end

  vim.api.nvim_create_autocmd("FileType", {
    callback = function()
      pcall(vim.treesitter.start)
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end
