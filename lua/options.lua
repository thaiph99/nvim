require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!

-- Prevent cursor from being at the first or last line
vim.opt.scrolloff = 5
vim.opt.wrap = false
vim.opt.foldmethod = "indent"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
vim.o.title = true
vim.o.titlestring = "nvim - " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

vim.api.nvim_create_autocmd("BufEnter", {
  --
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove "o"
    vim.opt.formatoptions:remove "r"
  end,
})

-- autosave
vim.o.autowriteall = true
vim.o.updatetime = 2000 -- Set idle timeout to 2 seconds
vim.api.nvim_create_autocmd("CursorHold", {
  pattern = "*",
  callback = function()
    if vim.bo.modified then
      vim.cmd "silent! update"
    end
  end,
})
