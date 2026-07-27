if vim.fn.has "nvim-0.12" ~= 1 then
  vim.notify("This config requires Neovim >= 0.12 (vim.pack)", vim.log.levels.ERROR)
  return
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require "options"
require "plugins"
require "keymaps"
require "autocmds"
require "indentscope"
