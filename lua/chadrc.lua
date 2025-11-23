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

local get_path = function()
  local icon = "󰈚"
  local path = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0))
  local path_s = vim.fn.expand "%:.:"
  local name = (path == "" and "Empty") or path:match "([^/\\]+)[/\\]*$"

  if name ~= "Empty" then
    local devicons_present, devicons = pcall(require, "nvim-web-devicons")
    if devicons_present then
      local ft_icon = devicons.get_icon(name)
      icon = (ft_icon ~= nil and ft_icon) or icon
    end
  end

  return { icon, path_s }
end

M.ui = {
  statusline = {
    theme = "vscode_colored",
    order = { "mode", "file_path", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor" },
    modules = {
      file_path = function()
        local x = get_path()
        return "%#StText# " .. x[1] .. " " .. x[2] .. " "
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

M.nvdash = {
  load_on_startup = true,
  header = {
    "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
    "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
    "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
    "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
    "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
    "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
    "",
    "",
    "",
    "",
  },
  buttons = {
    { txt = " Recent Files", keys = "fo", cmd = "Telescope oldfiles" },
    { txt = " New file", keys = "e", cmd = "ene | startinsert" },
    { txt = " Find file", keys = "f", cmd = "Telescope find_files" },
    { txt = " Open Config (~/.config/nvim)", keys = "c", cmd = "e ~/.config/nvim" },
    { txt = " Lazy Plugin Manager", keys = "l", cmd = "Lazy" },
    { txt = " Mason Package Manager", keys = "m", cmd = "Mason" },
    { txt = " Quit Neovim", keys = "q", cmd = "qa" },
    { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
    {
      txt = function()
        local stats = require("lazy").stats()
        local ms = math.floor(stats.startuptime) .. " ms"
        return "  Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms
      end,
      hl = "NvDashFooter",
      no_gap = true,
      content = "fit",
    },

    { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
  },
}

return M
