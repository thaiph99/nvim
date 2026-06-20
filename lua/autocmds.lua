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

-- Autosave modifiable buffers on switch and on idle
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

-- Quickfix: delete entries with dd (normal) / d (visual)
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
