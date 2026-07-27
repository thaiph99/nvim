-- Indent guides, with the cursor's scope picked out in its own colour.
--
-- Every guide is drawn here rather than by `listchars.leadmultispace`, the way
-- indent-blankline does it: guides land on the indent grid by construction, so
-- a line aligned under an open paren cannot sprout guides for levels that do
-- not exist, and there is nothing to rub out afterwards.

local ns = vim.api.nvim_create_namespace "user_indentscope"

-- Plain guides keep the surface1 listchars used; the scope's is a muted
-- grey-blue, clear of them without shouting.
local function set_hl()
  local palette = require("catppuccin.palettes").get_palette()
  vim.api.nvim_set_hl(0, "IndentGuide", { fg = palette.surface1 })
  vim.api.nvim_set_hl(0, "IndentScope", { fg = palette.overlay1 })
end

-- A guide over screen column `col`, dropped when horizontal scrolling has
-- pushed that column off the left edge.
local function guide(buf, lnum, col, hl)
  if col >= 0 then
    vim.api.nvim_buf_set_extmark(buf, ns, lnum - 1, 0, {
      virt_text = { { "│", hl } },
      virt_text_win_col = col,
      hl_mode = "combine",
    })
  end
end

local function refresh()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if vim.bo.buftype ~= "" then -- only real files, never trees/help/prompts
    return
  end

  -- Work is bounded by the window: a huge file costs no more than a screenful.
  local top, bot = vim.fn.line "w0", vim.fn.line "w$"
  local eof, leftcol = vim.fn.line "$", vim.fn.winsaveview().leftcol
  local width = vim.bo.shiftwidth ~= 0 and vim.bo.shiftwidth or vim.bo.tabstop

  -- The level a line defines, nil when it defines none: blank lines, and
  -- continuations aligned under an open paren (indent off the grid). Neither
  -- opens a block. Memoised, since the walks below recross the same lines.
  local cache = {}
  local function level(lnum)
    local known = cache[lnum]
    if known == nil then
      local indent = vim.fn.indent(lnum)
      known = vim.fn.getline(lnum):find "%S" and indent % width == 0 and indent or false
      cache[lnum] = known
    end
    return known or nil
  end

  -- First line defining a level, walking from `lnum` towards `stop`.
  local function nearest(lnum, step, stop)
    for l = lnum + step, stop, step do
      local i = level(l)
      if i then
        return l, i
      end
    end
  end

  -- How deep each visible line is drawn: its own level, or for one defining
  -- none the shallower of its neighbours', which keeps blank lines and
  -- continuation padding inside the block they sit in.
  local depth = {}
  for l = top, bot do
    depth[l] = level(l)
    if not depth[l] then
      local _, above = nearest(l, -1, 1)
      local _, below = nearest(l, 1, eof)
      depth[l] = math.min(above or below or 0, below or above or 0)
    end
  end

  -- The cursor's scope is the deepest level among its own line and its nearest
  -- defining neighbours, so a border line (`if (...) {`, `}`) highlights the
  -- block it delimits rather than the one around it.
  local cursor = vim.api.nvim_win_get_cursor(0)[1]
  local scope, seed = level(cursor) or -1, cursor
  for _, step in ipairs { -1, 1 } do
    local l, i = nearest(cursor, step, step < 0 and 1 or eof)
    if i and i > scope then
      scope, seed = i, l
    end
  end

  -- It reaches as far as lines stay that deep. `seed` is a line known to be
  -- inside the scope; the cursor's own line may not be, and may sit off-screen.
  local from = math.max(math.min(seed, bot), top)
  local edges = { from, from }
  for side, step in ipairs { -1, 1 } do
    for l = from + step, step < 0 and top or bot, step do
      if depth[l] < scope then
        break
      end
      edges[side] = l
    end
  end

  -- One guide per grid column up to the line's depth; the scope's own guide
  -- sits one level to the left of its indent.
  for l = top, bot do
    for col = 0, depth[l] - width, width do
      local lit = col == scope - width and l >= edges[1] and l <= edges[2]
      guide(buf, l, col - leftcol, lit and "IndentScope" or "IndentGuide")
    end
  end
end

local group = vim.api.nvim_create_augroup("user_indentscope", { clear = true })

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "WinScrolled", "BufWinEnter" }, {
  group = group,
  callback = refresh,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = vim.schedule_wrap(set_hl),
})

set_hl()
