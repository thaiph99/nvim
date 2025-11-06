-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "chadracula",

  -- hl_override = {
  -- 	Comment = { italic = true },
  -- 	["@comment"] = { italic = true },
  -- },
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
--}

vim.cmd "highlight St_relativepath guifg=#bbbbbb guibg=#2a2b36"

local stbufnr = function()
  return vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
end

M.ui = {
  statusline = {
    theme = "vscode_colored",
    order = { "mode", "relativepath", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor" },
    hl_add = {
      St_relativepath = {
        bg = "black2",
      },
    },
    modules = {
      relativepath = function()
        local path = vim.api.nvim_buf_get_name(stbufnr())

        if path == "" then
          return ""
        end

        return "%#St_relativepath# " .. vim.fn.expand "%:.:h" .. "/"
      end,
    },
  },
}

M.term = {
  float = {
    row = 0.1,
    col = 0.15,
    height = 0.8,
    width = 0.7,
  },
}

return M
