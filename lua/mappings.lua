require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map({ "n" }, "<C-p>", "<C-i>", { desc = "Jump Forward" })

-- Copilot Suggestion Acceptance Key
map("i", "<C-l>", function()
  vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
end, { desc = "Copilot Accept", noremap = true, silent = true })

-- telescope live_grep with select word
local telescope = require "telescope.builtin"
map("v", "<leader>fw", function()
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
    return
  end
  lines[1] = lines[1]:sub(cs, -1)
  if #lines == 1 then
    lines[1] = lines[1]:sub(1, ce - cs + 1)
  else
    lines[#lines] = lines[#lines]:sub(1, ce)
  end

  local text = table.concat(lines, " ")
  if text ~= "" then
    telescope.live_grep { default_text = text }
  end
end, { desc = "Live grep selected word", silent = true })

-- Telescope LSP keymaps override
vim.defer_fn(function()
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok or not telescope then
    return
  end

  -- Remove conflicting default LSP keymaps
  pcall(vim.keymap.del, "n", "grr")
  pcall(vim.keymap.del, "n", "gri")
  pcall(vim.keymap.del, "n", "gra")
  pcall(vim.keymap.del, "n", "grn")

  -- Set telescope LSP keymaps
  local opts = { silent = true, noremap = true }
  if telescope.lsp_references then
    vim.keymap.set(
      "n",
      "gr",
      telescope.lsp_references,
      vim.tbl_extend("force", opts, { desc = "Telescope LSP references" })
    )
  end
  if telescope.lsp_definitions then
    vim.keymap.set(
      "n",
      "gd",
      telescope.lsp_definitions,
      vim.tbl_extend("force", opts, { desc = "Telescope LSP definitions" })
    )
  end
  if telescope.lsp_implementations then
    vim.keymap.set(
      "n",
      "gi",
      telescope.lsp_implementations,
      vim.tbl_extend("force", opts, { desc = "Telescope LSP implementations" })
    )
  end
end, 1000)
