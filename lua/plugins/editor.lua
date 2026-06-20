require("nvim-surround").setup {}

-- Copilot: we accept via <A-l> (see keymaps.lua), not Tab.
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true

-- copilot-language-server needs node:sqlite, which on Node < 23 lives behind
-- --experimental-sqlite. Disable the npx launcher (its shebang ignores the
-- flag) and run the bundled server through node with the flag injected.
vim.g.copilot_npx_command = 0
vim.g.copilot_node_command = { "node", "--experimental-sqlite" }
