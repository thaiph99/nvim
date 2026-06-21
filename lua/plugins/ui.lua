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

-- Mode table: display name + which palette color drives the mode segment, plus a
-- stable `key` used to name the per-mode highlight groups (several Vim modes share
-- one color/key, e.g. all the visual variants).
local modes = setmetatable({
  ["n"] = { "NORMAL", "n" },
  ["i"] = { "INSERT", "i" },
  ["v"] = { "VISUAL", "v" },
  ["V"] = { "V-LINE", "v" },
  ["\22"] = { "V-BLOCK", "v" },
  ["s"] = { "SELECT", "v" },
  ["S"] = { "S-LINE", "v" },
  ["c"] = { "COMMAND", "c" },
  ["R"] = { "REPLACE", "r" },
  ["t"] = { "TERMINAL", "t" },
}, {
  __index = function()
    return { "?", "n" }
  end,
})

-- Palette color per mode key.
local mode_colors = { n = "blue", i = "green", v = "mauve", c = "peach", r = "red", t = "teal" }

-- Build all statusline highlight groups from the active Catppuccin palette so the
-- bar tracks the colorscheme (rerun on every ColorScheme via tweak_highlights).
local function setup_statusline_hl()
  local p = require("catppuccin.palettes").get_palette()
  local b_bg = p.surface0 -- file / filetype segment background
  local c_bg = p.mantle -- middle (git, diagnostics) background

  -- Fill / middle section.
  vim.api.nvim_set_hl(0, "StatusLine", { fg = p.subtext0, bg = c_bg })
  vim.api.nvim_set_hl(0, "StB", { fg = p.text, bg = b_bg, bold = true })
  vim.api.nvim_set_hl(0, "StGit", { fg = p.mauve, bg = c_bg, bold = true })
  -- Separator glyph between the b-section and the middle (same colors both sides).
  vim.api.nvim_set_hl(0, "StSep", { fg = b_bg, bg = c_bg })

  -- Diagnostics rendered as a badge on the b-section (surface0) so the counts read
  -- as a defined widget rather than floating text on the bar.
  vim.api.nvim_set_hl(0, "StDiagError", { fg = p.red, bg = b_bg, bold = true })
  vim.api.nvim_set_hl(0, "StDiagWarn", { fg = p.yellow, bg = b_bg, bold = true })
  vim.api.nvim_set_hl(0, "StDiagInfo", { fg = p.sky, bg = b_bg, bold = true })
  vim.api.nvim_set_hl(0, "StDiagHint", { fg = p.teal, bg = b_bg, bold = true })

  -- Per-mode segment + its separator (separator color pair is shared by both ends).
  for key, colname in pairs(mode_colors) do
    local col = p[colname]
    vim.api.nvim_set_hl(0, "StMode_" .. key, { fg = p.crust, bg = col, bold = true })
    vim.api.nvim_set_hl(0, "StModeSep_" .. key, { fg = col, bg = b_bg })
  end

  -- Inline diagnostics: Catppuccin dims the virtual text; use full severity colors
  -- so they read clearly against the editor background.
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = p.red, bold = true })
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = p.yellow, bold = true })
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = p.sky, bold = true })
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = p.teal, bold = true })

  -- Current-line git blame: dim, muted blue-grey (matches the subtle NonText-style
  -- blame used in the NvChad config). Sits clearly below the brighter comment color
  -- (overlay2) without being as washed-out as the gitsigns default.
  vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = p.overlay0, italic = false })
end

-- Strip italics from every highlight group, then refresh the bar / active-tab text.
local function tweak_highlights()
  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if hl.italic then
      hl.italic = false
      vim.api.nvim_set_hl(0, name, hl)
    end
  end

  setup_statusline_hl()

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
-- Powerline separators (require a Nerd Font, already used for devicons).
local SEP_R = "" -- right-pointing wedge (light -> dark)
local SEP_L = "" -- left-pointing wedge (dark -> light)

function _G.__statusline()
  local parts = {}
  local m = modes[vim.fn.mode()]
  local key = m[2]
  local mode_grp = "%#StMode_" .. key .. "#"
  local sep_grp = "%#StModeSep_" .. key .. "#"

  -- Left: mode block -> file block -> git.
  parts[#parts + 1] = mode_grp .. "  " .. m[1] .. " "
  parts[#parts + 1] = sep_grp .. SEP_R

  local name = vim.api.nvim_buf_get_name(0)
  local ficon, ficon_hl = devicons.get_icon(vim.fn.fnamemodify(name, ":t"), nil, { default = true })
  parts[#parts + 1] = "%#StB# " .. colored_icon(ficon, ficon_hl, "StB") .. "%#StB# %t %m%r"
  parts[#parts + 1] = "%#StSep#" .. SEP_R

  local head = vim.b.gitsigns_head
  if head and head ~= "" then
    parts[#parts + 1] = "%#StGit#  " .. head .. " "
  end

  parts[#parts + 1] = "%#StatusLine#%="

  -- Right: [ diagnostics  filetype ] badge -> position block. The single SEP_L opens
  -- the surface0 badge; everything up to the mode separator shares that background.
  parts[#parts + 1] = "%#StSep#" .. SEP_L

  local levels = {
    { vim.diagnostic.severity.ERROR, "E", "StDiagError" },
    { vim.diagnostic.severity.WARN, "W", "StDiagWarn" },
    { vim.diagnostic.severity.INFO, "I", "StDiagInfo" },
    { vim.diagnostic.severity.HINT, "H", "StDiagHint" },
  }
  local counts = vim.diagnostic.count(0)
  for _, l in ipairs(levels) do
    local n = counts[l[1]] or 0
    if n > 0 then
      parts[#parts + 1] = ("%%#%s# %s:%d "):format(l[3], l[2], n)
    end
  end

  local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "none"
  local icon, icon_hl = devicons.get_icon_by_filetype(ft, { default = true })
  parts[#parts + 1] = "%#StB# " .. colored_icon(icon, icon_hl, "StB") .. "%#StB# " .. ft .. " "
  parts[#parts + 1] = sep_grp .. SEP_L
  parts[#parts + 1] = mode_grp .. " %l:%c "
  parts[#parts + 1] = mode_grp .. " %P "

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
