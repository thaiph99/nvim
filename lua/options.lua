require "nvchad.options"

local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!
o.mouse = ""

-- Prevent cursor from being at the first or last line
vim.opt.scrolloff = 5

-- Autosave current buffer when switching buffers or leaving window
local function autosave_current_buffer()
  if vim.bo.buftype ~= "" then
    return
  end
  if not vim.bo.modifiable or vim.bo.readonly then
    return
  end
  if not vim.bo.modified then
    return
  end
  if vim.api.nvim_buf_get_name(0) == "" then
    return
  end

  vim.cmd "silent! update" -- Save the current buffer silently
end

vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
  callback = autosave_current_buffer,
  desc = "Autosave buffer on switch/float terminal",
})

vim.opt.wrap = false
vim.opt.foldmethod = "indent"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
vim.o.title = true
vim.o.titlestring = "nvim - " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

-- disable auto inserting comment on new line
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove { "c", "r", "o" }
  end,
})

-- auto-indent for C/C++ based on .clang-format IndentWidth
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
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

-- autosave
vim.o.autowriteall = true
vim.o.updatetime = 2000 -- Set idle timeout to 2 seconds

-- Auto-save modified buffer on CursorHold
vim.api.nvim_create_autocmd("CursorHold", {
  pattern = "*",
  callback = function()
    if vim.bo.modified then
      vim.cmd "silent! update"
    end
  end,
})
