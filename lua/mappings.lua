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
    telescope.find_files { default_text = text, follow=true, no_ignore=true, hidden=true }
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
