require("gitsigns").setup {
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 500,
  },
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "󰍵" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "│" },
  },
}
