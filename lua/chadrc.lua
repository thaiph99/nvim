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

local format_language = function(bufnr)
  bufnr = bufnr ~= 0 and bufnr or vim.api.nvim_get_current_buf()

  local lang
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if ok then
    lang = parsers.get_buf_lang(bufnr)
  end

  lang = lang or vim.bo[bufnr].filetype
  if not lang or lang == "" then
    return "Plaintext"
  end

  local words = {}
  for word in lang:gmatch "[^_%-%.]+" do
    words[#words + 1] = word:sub(1, 1):upper() .. word:sub(2)
  end

  return #words > 0 and table.concat(words, " ") or lang
end

M.ui = {
  statusline = {
    theme = "vscode_colored",
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lang", "cwd", "cursor" },
    modules = {
      lang = function()
        local lang = format_language(vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0))
        return "%#St_Lsp# " .. lang .. " "
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
