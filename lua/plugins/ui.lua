local devicons = require "nvim-web-devicons"
devicons.setup {}

-- Catppuccin Macchiato.
require("catppuccin").setup {
  flavour = "macchiato",
  -- No italics anywhere (keeps the upright look used by the rest of this config).
  no_italic = true,
  integrations = {
    blink_cmp = true,
    gitsigns = true,
    treesitter = true,
    telescope = { enabled = true },
    native_lsp = { enabled = true },
    nvimtree = true,
    dap = true,
    dap_ui = true,
    mason = true,
  },
}

-- Per-icon highlight groups re-based onto the tab/status backgrounds; cleared on
-- colorscheme change so the colors stay correct.
local icon_hl_cache = {}

-- Strip italics from every highlight group, then brighten statusline / active-tab text.
local function tweak_highlights()
  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if hl.italic then
      hl.italic = false
      vim.api.nvim_set_hl(0, name, hl)
    end
  end

  -- Pure white statusline text (brighter than dracula's default grey).
  local sl = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
  vim.api.nvim_set_hl(0, "StatusLine", { fg = 0xFFFFFF, bg = sl.bg, bold = sl.bold })

  -- Active buffer in the tabline: bright white and bold.
  local sel = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false })
  vim.api.nvim_set_hl(0, "TabLineSel", { fg = 0xFFFFFF, bg = sel.bg, bold = true })

  icon_hl_cache = {}
end

-- Render a devicon keeping its own color but adopting `base`'s background so it
-- blends into the surrounding tab/status segment. Returns a "%#group#icon" chunk.
local function colored_icon(icon, icon_hl, base)
  if not icon or icon == "" then
    return ""
  end
  local key = "User" .. base .. (icon_hl or "None")
  if not icon_hl_cache[key] then
    local ihl = icon_hl and vim.api.nvim_get_hl(0, { name = icon_hl, link = false }) or {}
    local bhl = vim.api.nvim_get_hl(0, { name = base, link = false })
    vim.api.nvim_set_hl(0, key, { fg = ihl.fg, bg = bhl.bg })
    icon_hl_cache[key] = true
  end
  return "%#" .. key .. "#" .. icon
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("user_no_italics", { clear = true }),
  callback = function()
    vim.schedule(tweak_highlights)
  end,
})

vim.cmd.colorscheme "catppuccin-macchiato"
tweak_highlights()

-- Native statusline (single global statusline via laststatus=3).
local mode_names = setmetatable({
  ["n"] = "NORMAL",
  ["i"] = "INSERT",
  ["v"] = "VISUAL",
  ["V"] = "V-LINE",
  ["\22"] = "V-BLOCK",
  ["c"] = "COMMAND",
  ["R"] = "REPLACE",
  ["t"] = "TERMINAL",
  ["s"] = "SELECT",
}, {
  __index = function()
    return "?"
  end,
})

function _G.__statusline()
  local parts = {}

  parts[#parts + 1] = "%#StatusLine# " .. mode_names[vim.fn.mode()] .. " "
  parts[#parts + 1] = " %f%( %m%)%( %r%)"

  local head = vim.b.gitsigns_head
  if head and head ~= "" then
    parts[#parts + 1] = "  " .. head
  end

  parts[#parts + 1] = "%="

  local levels = {
    { vim.diagnostic.severity.ERROR, "E", "DiagnosticError" },
    { vim.diagnostic.severity.WARN, "W", "DiagnosticWarn" },
    { vim.diagnostic.severity.INFO, "I", "DiagnosticInfo" },
    { vim.diagnostic.severity.HINT, "H", "DiagnosticHint" },
  }
  local counts = vim.diagnostic.count(0)
  for _, l in ipairs(levels) do
    local n = counts[l[1]] or 0
    if n > 0 then
      parts[#parts + 1] = ("%%#%s#%s%d "):format(l[3], l[2], n)
    end
  end

  parts[#parts + 1] = "%#StatusLine# "
  local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "none"
  local icon, icon_hl = devicons.get_icon_by_filetype(ft, { default = true })
  if icon then
    parts[#parts + 1] = colored_icon(icon, icon_hl, "StatusLine") .. "%#StatusLine# "
  end
  parts[#parts + 1] = ft .. " "
  parts[#parts + 1] = " %l:%c "
  parts[#parts + 1] = " %P "

  return table.concat(parts)
end

vim.o.statusline = "%!v:lua.__statusline()"

-- Native tabline listing buffers (<Tab>/<S-Tab> cycle buffers).
function _G.__tabline()
  local s = ""
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted and vim.api.nvim_buf_is_loaded(buf) then
      local fullname = vim.api.nvim_buf_get_name(buf)
      local name = fullname == "" and "[No Name]" or vim.fn.fnamemodify(fullname, ":t")
      local flag = vim.bo[buf].modified and " ●" or ""
      local base = buf == current and "TabLineSel" or "TabLine"
      local hl = "%#" .. base .. "#"
      local icon, icon_hl = devicons.get_icon(name, name:match "%.([^.]+)$", { default = true })
      s = s .. hl .. " " .. colored_icon(icon, icon_hl, base) .. hl .. " " .. name .. flag .. " "
    end
  end
  return s .. "%#TabLineFill#"
end

vim.o.tabline = "%!v:lua.__tabline()"
vim.o.showtabline = 2

vim.api.nvim_create_autocmd({ "BufEnter", "BufModifiedSet", "BufDelete" }, {
  group = vim.api.nvim_create_augroup("user_tabline", { clear = true }),
  callback = function()
    vim.cmd "redrawtabline"
  end,
})
