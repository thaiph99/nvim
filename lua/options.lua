local o = vim.o
local opt = vim.opt

-- UI
o.number = true
o.ruler = false
o.signcolumn = "yes"
-- Line number, two-space gap, sign column (so text isn't cramped against numbers).
o.statuscolumn = "%=%{&number ? (&relativenumber && v:relnum ? v:relnum : v:lnum) : ''}  %s"
o.cursorline = true
o.cursorlineopt = "both"
o.scrolloff = 5
o.termguicolors = true
o.showmode = false
o.laststatus = 3
o.cmdheight = 1
o.pumheight = 12
o.title = true
o.titlestring = "nvim - " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
o.mouse = ""
opt.fillchars = { eob = " " }
opt.shortmess:append "sI"

o.list = true
opt.listchars = { tab = "│ ", trail = "·", nbsp = "+" }

-- Indentation
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true

-- Editing
o.wrap = false
o.ignorecase = true
o.smartcase = true
o.undofile = true
o.swapfile = false
o.timeout = false
o.timeoutlen = 500
o.updatetime = 250
o.autowriteall = true

-- Splits
o.splitright = true
o.splitbelow = true

-- Folding
o.foldmethod = "indent"
o.foldlevel = 99
o.foldlevelstart = 99
opt.foldtext = ""

vim.schedule(function()
  o.clipboard = "unnamedplus"
end)

o.scrollback = 100000
