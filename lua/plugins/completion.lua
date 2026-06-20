require("blink.cmp").setup {
  -- default: C-space open, C-y accept, C-e hide. Tab/S-Tab cycle, Enter accepts.
  keymap = {
    preset = "default",
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
  },

  appearance = { nerd_font_variant = "mono" },

  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    menu = { border = "rounded" },
    ghost_text = { enabled = false }, -- copilot provides ghost text
  },

  signature = { enabled = true },

  cmdline = {
    -- Behave like the buffer menu: Tab/S-Tab cycle options, Enter accepts.
    keymap = {
      preset = "cmdline",
      ["<Tab>"] = { "show", "select_next", "fallback" },
      ["<S-Tab>"] = { "show", "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
    completion = {
      menu = { auto_show = true }, -- show the menu as you type
      list = { selection = { preselect = false, auto_insert = false } },
    },
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  fuzzy = { implementation = "prefer_rust_with_warning" },
}
