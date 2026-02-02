require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i", "v" }, "<C-s", "<cmd> w <cr>")

-- use Alt instead of Ctrl for some common commands
map({ "n" }, "<A-p>", "<C-i>", { desc = "Jump Forward" })
map({ "n" }, "<C-p>", "<C-i>", { desc = "Jump Forward" })
map({ "n" }, "<A-o>", "<C-o>", { desc = "Jump Backward" })

map({ "n", "v", "x" }, "<A-d>", "<C-d>", { desc = "PageDown" })
map({ "n", "v", "x" }, "<A-u>", "<C-u>", { desc = "PageUp" })

map({ "n" }, "<A-r>", "<C-r>", { desc = "Redo" })

vim.keymap.del("n", "<A-h>")
vim.keymap.del("n", "<A-v>")
map("n", "<A-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<A-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<A-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<A-k>", "<C-w>k", { desc = "switch window up" })
map("n", "<A-v>", "<C-v>", { desc = "visual block" })

map("n", "<leader>dd", function()
  vim.diagnostic.open_float(nil, { scope = "line" })
end, { desc = "Open diagnostic float" })

-- Copilot Suggestion Acceptance Key
map("i", "<A-l>", function()
  vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
end, { desc = "Copilot Accept", noremap = true, silent = true })

-- telescope with selected word helper function
local telescope = require "telescope.builtin"
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

-- telescope live_grep with selected word
map("v", "<leader>fw", function()
  local text = get_selected_text()
  if text ~= "" then
    telescope.live_grep { default_text = text }
  end
end, { desc = "Live grep selected word", silent = true })

-- telescope find files with selected word
map("v", "<leader>ff", function()
  local text = get_selected_text()
  if text ~= "" then
    telescope.find_files { default_text = text }
  end
end, { desc = "Find files with selected word", silent = true })

-- telescope find all files with selected word
map("v", "<leader>fa", function()
  local text = get_selected_text()
  if text ~= "" then
    telescope.find_files { default_text = text, follow = true, no_ignore = true, hidden = true }
  end
end, { desc = "Find files with selected word", silent = true })

-- Telescope LSP keymaps override
-- Create an autocmd to override LSP keymaps after they are set

pcall(vim.keymap.del, "n", "grr")
pcall(vim.keymap.del, "n", "grt")
pcall(vim.keymap.del, "n", "gri")
pcall(vim.keymap.del, "n", "gra")
pcall(vim.keymap.del, "n", "grn")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("TelescopeLspKeymaps", { clear = true }),
  callback = function(event)
    local bufnr = event.buf
    local ok, telescope = pcall(require, "telescope.builtin")
    if not ok or not telescope then
      return
    end

    -- Wait a bit to ensure all other keymaps are set first
    vim.defer_fn(function()
      -- Override LSP keymaps with telescope equivalents
      local opts = { buffer = bufnr, silent = true, noremap = true }

      vim.keymap.set(
        "n",
        "gd",
        telescope.lsp_definitions,
        vim.tbl_extend("force", opts, { desc = "Telescope LSP definitions" })
      )

      vim.keymap.set(
        "n",
        "gD",
        telescope.lsp_type_definitions,
        vim.tbl_extend("force", opts, { desc = "Telescope LSP type definitions" })
      )

      vim.keymap.set(
        "n",
        "gr",
        telescope.lsp_references,
        vim.tbl_extend("force", opts, { desc = "Telescope LSP references" })
      )

      vim.keymap.set(
        "n",
        "gi",
        telescope.lsp_implementations,
        vim.tbl_extend("force", opts, { desc = "Telescope LSP implementations" })
      )
    end, 100) -- Wait 100ms after LSP attach
  end,
})

-- DAP (Debug Adapter Protocol) keymappings
map("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "Toggle Breakpoint" })
map("n", "<leader>dc", "<cmd>DapContinue<CR>", { desc = "Start/Continue Debugging" })
map("n", "<leader>di", "<cmd>DapStepInto<CR>", { desc = "Step Into" })
map("n", "<leader>do", "<cmd>DapStepOver<CR>", { desc = "Step Over" })
map("n", "<leader>dO", "<cmd>DapStepOut<CR>", { desc = "Step Out" })
map("n", "<leader>dt", "<cmd>DapTerminate<CR>", { desc = "Terminate Debugging" })
map("n", "<leader>dr", "<cmd>DapToggleRepl<CR>", { desc = "Toggle REPL" })
map("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Toggle DAP UI" })
map("n", "<leader>dh", function()
  require("dap.ui.widgets").hover()
end, { desc = "Hover Variables" })
map("n", "<leader>ds", function()
  local widgets = require "dap.ui.widgets"
  widgets.centered_float(widgets.scopes)
end, { desc = "Show Scopes" })
