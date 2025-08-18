-- auto-indent for C++ based on .clang-format
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.c", "*.cpp", "*.h", "*.hpp"},
  callback = function()
    local clang_format = vim.fn.findfile(".clang-format", ".;")
    if clang_format ~= "" then
      local content = vim.fn.readfile(clang_format)
      for _, line in ipairs(content) do
        local width = line:match("IndentWidth:%s*(%d+)")
        if width then
          local w = tonumber(width)
          vim.bo.shiftwidth = w
          vim.bo.tabstop = w
          vim.bo.softtabstop = w
          break
        end
      end
    end
  end,
})
