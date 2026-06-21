require("nvim-surround").setup {}

-- Copilot accepts via <A-l> (keymaps.lua), not Tab.
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true

-- copilot-language-server needs node:sqlite; on Node < 23 inject the flag and
-- bypass the npx launcher (its shebang ignores it).
vim.g.copilot_npx_command = 0
vim.g.copilot_node_command = { "node", "--experimental-sqlite" }
