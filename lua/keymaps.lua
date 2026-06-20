local map = vim.keymap.set

-- General
map("i", "jk", "<ESC>", { desc = "Escape insert mode" })
map("n", "<Esc>", "<cmd>noh<cr>", { desc = "Clear search highlights" })
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<C-c>", "<cmd>%y+<cr>", { desc = "Copy whole file" })

map("n", "<leader>n", "<cmd>set nu!<cr>", { desc = "Toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<cr>", { desc = "Toggle relative number" })

map("n", "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "Format buffer" })

-- Comment
map("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<A-h>", "<C-w>h", { desc = "Window left" })
map("n", "<A-l>", "<C-w>l", { desc = "Window right" })
map("n", "<A-j>", "<C-w>j", { desc = "Window down" })
map("n", "<A-k>", "<C-w>k", { desc = "Window up" })

-- Alt remaps for common motions
map("n", "<A-v>", "<C-v>", { desc = "Visual block" })
map({ "n", "v", "x" }, "<A-d>", "<C-d>", { desc = "Page down" })
map({ "n", "v", "x" }, "<A-u>", "<C-u>", { desc = "Page up" })
map("n", "<A-p>", "<C-i>", { desc = "Jump forward" })
map("n", "<C-p>", "<C-i>", { desc = "Jump forward" })
map("n", "<A-o>", "<C-o>", { desc = "Jump backward" })
map("n", "<A-g>", "<C-g>", { desc = "Show path" })

-- Buffers
map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<leader>b", "<cmd>enew<cr>", { desc = "New buffer" })

local function close_buffer_and_return()
  local current = vim.api.nvim_get_current_buf()
  local alternate = vim.fn.bufnr "#"
  if alternate ~= -1 and vim.api.nvim_buf_is_loaded(alternate) then
    vim.cmd "buffer #"
  else
    local switched = pcall(function()
      vim.cmd "bprevious"
    end)
    if not switched then
      return vim.cmd "bd"
    end
  end
  if vim.api.nvim_buf_is_loaded(current) then
    pcall(function()
      vim.cmd("bd " .. current)
    end)
  end
end
map("n", "<leader>x", close_buffer_and_return, { desc = "Close buffer and go back" })

-- File explorer
map("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle nvim-tree" })
map("n", "<leader>e", "<cmd>NvimTreeFindFile<cr>", { desc = "Focus nvim-tree on current file" })

-- Diagnostics
map("n", "<leader>dd", function()
  vim.diagnostic.open_float(nil, { scope = "line" })
end, { desc = "Open diagnostic float" })

-- Copilot
map("i", "<A-l>", function()
  vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
end, { desc = "Copilot accept", noremap = true, silent = true })

map("i", "<A-k>", function()
  vim.fn.feedkeys(vim.fn["copilot#AcceptWord"](), "")
end, { desc = "Copilot Accept Word", noremap = true, silent = true })

map("i", "<A-j>", function()
  vim.fn.feedkeys(vim.fn["copilot#AcceptLine"](), "")
end, { desc = "Copilot Accept Line", noremap = true, silent = true })

-- Telescope
local function builtin()
  return require "telescope.builtin"
end

map("n", "<leader>ff", function()
  builtin().find_files()
end, { desc = "Find files" })
map("n", "<leader>fa", function()
  builtin().find_files { follow = true, no_ignore = true, hidden = true }
end, { desc = "Find all files" })
map("n", "<leader>fw", function()
  builtin().live_grep()
end, { desc = "Live grep" })
map("n", "<leader>fb", function()
  builtin().buffers()
end, { desc = "Find buffers" })
map("n", "<leader>fo", function()
  builtin().oldfiles()
end, { desc = "Recent files" })
map("n", "<leader>fz", function()
  builtin().current_buffer_fuzzy_find()
end, { desc = "Find in current buffer" })
map("n", "<leader>fh", function()
  builtin().help_tags()
end, { desc = "Help tags" })
map("n", "<leader>ma", function()
  builtin().marks()
end, { desc = "Marks" })
map("n", "<leader>cm", function()
  builtin().git_commits()
end, { desc = "Git commits" })
map("n", "<leader>gt", function()
  builtin().git_status()
end, { desc = "Git status" })
map("n", "<leader>fr", function()
  builtin().resume()
end, { desc = "Resume last picker" })

-- Telescope with the current visual selection as the query
local function get_selected_text()
  local v_start = vim.fn.getpos "v"
  local v_end = vim.fn.getpos "."
  local ls, cs = v_start[2], v_start[3]
  local le, ce = v_end[2], v_end[3]
  if ls > le or (ls == le and cs > ce) then
    ls, le = le, ls
    cs, ce = ce, cs
  end
  local lines = vim.fn.getline(ls, le)
  if type(lines) == "string" then
    lines = { lines }
  end
  if #lines == 0 then
    return ""
  end
  lines[1] = lines[1]:sub(cs, -1)
  if #lines == 1 then
    lines[1] = lines[1]:sub(1, ce - cs + 1)
  else
    lines[#lines] = lines[#lines]:sub(1, ce)
  end
  return table.concat(lines, " ")
end

map("v", "<leader>fw", function()
  local text = get_selected_text()
  if text ~= "" then
    builtin().live_grep { default_text = text }
  end
end, { desc = "Live grep selection", silent = true })
map("v", "<leader>ff", function()
  local text = get_selected_text()
  if text ~= "" then
    builtin().find_files { default_text = text }
  end
end, { desc = "Find files with selection", silent = true })
map("v", "<leader>fa", function()
  local text = get_selected_text()
  if text ~= "" then
    builtin().find_files { default_text = text, follow = true, no_ignore = true, hidden = true }
  end
end, { desc = "Find all files with selection", silent = true })

-- Quickfix
map("n", "<leader>qa", function()
  local entry = {
    bufnr = vim.api.nvim_get_current_buf(),
    lnum = vim.fn.line ".",
    col = vim.fn.col ".",
    text = vim.fn.getline("."):match "^%s*(.-)%s*$",
  }
  vim.fn.setqflist({ entry }, "a")
  vim.notify("Added to quickfix: line " .. entry.lnum, vim.log.levels.INFO)
end, { desc = "Add current line to quickfix" })

-- Terminal
map("t", "<A-q>", "<C-\\><C-N>", { desc = "Escape terminal mode" })

local term = { buf = nil, win = nil }
local function toggle_float_term()
  if term.win and vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_hide(term.win)
    term.win = nil
    return
  end
  if not (term.buf and vim.api.nvim_buf_is_valid(term.buf)) then
    term.buf = vim.api.nvim_create_buf(false, true)
  end
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  term.win = vim.api.nvim_open_win(term.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })
  if vim.bo[term.buf].buftype ~= "terminal" then
    vim.cmd "terminal"
  end
  vim.cmd "startinsert"
end
map({ "n", "t" }, "<A-i>", toggle_float_term, { desc = "Toggle floating terminal" })

-- DAP
map("n", "<leader>db", "<cmd>DapToggleBreakpoint<cr>", { desc = "Toggle breakpoint" })
map("n", "<leader>dc", "<cmd>DapContinue<cr>", { desc = "Start/Continue debugging" })
map("n", "<leader>di", "<cmd>DapStepInto<cr>", { desc = "Step into" })
map("n", "<leader>do", "<cmd>DapStepOver<cr>", { desc = "Step over" })
map("n", "<leader>dO", "<cmd>DapStepOut<cr>", { desc = "Step out" })
map("n", "<leader>dt", "<cmd>DapTerminate<cr>", { desc = "Terminate debugging" })
map("n", "<leader>dr", "<cmd>DapToggleRepl<cr>", { desc = "Toggle REPL" })
map("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Toggle DAP UI" })
map("n", "<leader>dh", function()
  require("dap.ui.widgets").hover()
end, { desc = "Hover variables" })
map("n", "<leader>ds", function()
  local widgets = require "dap.ui.widgets"
  widgets.centered_float(widgets.scopes)
end, { desc = "Show scopes" })
