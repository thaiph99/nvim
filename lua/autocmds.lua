local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup "yank_highlight",
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 150 }
  end,
})

-- Don't auto-insert comment leaders on new lines
vim.api.nvim_create_autocmd("FileType", {
  group = augroup "formatoptions",
  callback = function()
    vim.opt_local.formatoptions:remove { "c", "r", "o" }
  end,
})

-- Indent C/C++ from the nearest .clang-format IndentWidth
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup "clang_format_indent",
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
  callback = function()
    local clang_format = vim.fn.findfile(".clang-format", ".;")
    if clang_format == "" then
      return
    end
    for _, line in ipairs(vim.fn.readfile(clang_format)) do
      local width = line:match "IndentWidth:%s*(%d+)"
      if width then
        local w = tonumber(width)
        vim.bo.shiftwidth = w
        vim.bo.tabstop = w
        vim.bo.softtabstop = w
        break
      end
    end
  end,
})

-- Smart indent guide: size leadmultispace to the buffer's indent (shiftwidth,
-- else tabstop) so the guide follows 2- vs 4-space indents automatically.
local function set_indent_guide()
  local w = vim.bo.shiftwidth ~= 0 and vim.bo.shiftwidth or vim.bo.tabstop
  local lc = vim.opt_local.listchars:get()
  lc.leadmultispace = "│" .. (" "):rep(math.max(w - 1, 0))
  vim.opt_local.listchars = lc
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "OptionSet" }, {
  group = augroup "indent_guide",
  callback = function(ev)
    local opt = ev.match
    if ev.event == "OptionSet" and opt ~= "shiftwidth" and opt ~= "tabstop" and opt ~= "expandtab" then
      return
    end
    set_indent_guide()
  end,
})

-- Autosave on switch / idle
local function autosave()
  if vim.bo.buftype == "" and vim.bo.modifiable and not vim.bo.readonly and vim.bo.modified then
    if vim.api.nvim_buf_get_name(0) ~= "" then
      vim.cmd "silent! update"
    end
  end
end

vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "CursorHold" }, {
  group = augroup "autosave",
  callback = autosave,
})

-- Terminal: no numbers/signs in floats
local terminal_group = augroup "terminal"

vim.api.nvim_create_autocmd("TermOpen", {
  group = terminal_group,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- Keep terminal cursor/scroll stable across focus switches.
local term_views = {}

vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
  group = terminal_group,
  callback = function()
    if vim.bo.buftype == "terminal" then
      term_views[vim.api.nvim_get_current_buf()] = vim.fn.winsaveview()
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = terminal_group,
  callback = function()
    if vim.bo.buftype == "terminal" then
      vim.cmd "stopinsert"
      local view = term_views[vim.api.nvim_get_current_buf()]
      if view then
        vim.fn.winrestview(view)
      end
    end
  end,
})

-- Quickfix: delete entries with dd / d
vim.api.nvim_create_autocmd("FileType", {
  group = augroup "quickfix",
  pattern = "qf",
  callback = function()
    local function delete_qf_entries(first, last)
      local list = vim.fn.getqflist()
      for _ = first, last do
        table.remove(list, first)
      end
      vim.fn.setqflist(list, "r")
      if #list > 0 then
        vim.fn.cursor(math.min(first, #list), 1)
      end
    end

    vim.keymap.set("n", "dd", function()
      delete_qf_entries(vim.fn.line ".", vim.fn.line ".")
    end, { buffer = true, desc = "Delete quickfix entry" })

    vim.keymap.set("n", "<leader>qd", function()
      delete_qf_entries(vim.fn.line ".", vim.fn.line ".")
    end, { buffer = true, desc = "Delete quickfix entry" })

    vim.keymap.set("v", "d", function()
      local first = math.min(vim.fn.line "v", vim.fn.line ".")
      local last = math.max(vim.fn.line "v", vim.fn.line ".")
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      delete_qf_entries(first, last)
    end, { buffer = true, desc = "Delete selected quickfix entries" })
  end,
})
