-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

local status_buf = function()
  return vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
end
local icons = { file = "󰈚", lang = "󰈙" }
local devicon = function(kind, key, default_icon)
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return default_icon
  end
  return (kind == "ft" and devicons.get_icon_by_filetype(key, { default = true }))
    or devicons.get_icon(key, nil, { default = true })
    or default_icon
end

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
  bufnr = bufnr ~= 0 and bufnr or status_buf()

  local lang
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if ok then
    lang = parsers.get_buf_lang(bufnr)
  end
  lang = lang or vim.bo[bufnr].filetype or "Plaintext"
  if lang == "" then
    return "Plaintext"
  end

  local words = {}
  for word in lang:gmatch "[^_%-%.]+" do
    words[#words + 1] = word:sub(1, 1):upper() .. word:sub(2)
  end

  return #words > 0 and table.concat(words, " ") or lang
end

local get_lang_icon = function(bufnr)
  local ft = vim.bo[bufnr].filetype
  return (ft and ft ~= "") and devicon("ft", ft, icons.lang) or icons.lang
end

local shorten_with_ellipsis = function(path, max_len)
  if #path <= max_len then
    return path
  end

  local parts = vim.split(path, "/", { trimempty = true })
  if #parts == 0 then
    return path
  end

  local keep, used = {}, 4 -- ".../"
  for i = #parts, 1, -1 do
    local part = parts[i]
    local extra = #keep > 0 and 1 or 0
    if used + #part + extra > max_len then
      break
    end
    table.insert(keep, 1, part)
    used = used + #part + extra
  end

  return ".../" .. table.concat(keep, "/")
end

local normalize_path = function(path)
  local normalized = path:gsub("\\", "/")
  local cwd = vim.uv.cwd()
  if cwd then
    local prefix = cwd:gsub("\\", "/"):gsub("/$", "") .. "/"
    if normalized:sub(1, #prefix) == prefix then
      return normalized:sub(#prefix + 1)
    end
  end
  return vim.fn.fnamemodify(normalized, ":~"):gsub("^%./", "")
end

local format_file_path = function(bufnr)
  bufnr = bufnr ~= 0 and bufnr or status_buf()

  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    return icons.file, "Empty"
  end

  local icon = devicon("file", vim.fn.fnamemodify(path, ":t"), icons.file)
  local display_path = normalize_path(path)

  local max_len = math.max(25, math.floor(vim.o.columns * 0.35))
  display_path = shorten_with_ellipsis(display_path, max_len)

  return icon, display_path
end

M.ui = {
  statusline = {
    theme = "vscode_colored",
    order = { "mode", "file_path", "git", "%=", "lsp_msg", "%=", "diagnostics", "lang", "cwd", "cursor" },
    modules = {
      file_path = function()
        local bufnr = status_buf()
        local icon, path = format_file_path(bufnr)
        return "%#StText# " .. icon .. " " .. path .. " "
      end,
      lang = function()
        local bufnr = status_buf()
        local lang = format_language(bufnr)
        local icon = get_lang_icon(bufnr)
        return "%#St_Lsp# " .. icon .. " " .. lang .. " "
      end,
    },
  },
}

M.term = {
  float = {
    row = 0.05,
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
