local alpha = require "alpha"
local dashboard = require "alpha.themes.dashboard"

-- Set header
local logo = [[
    ██████╗ ██╗  ██╗ █████╗ ███╗   ███╗    ██╗  ██╗ ██████╗ ███╗   ██╗ ██████╗     ████████╗██╗  ██╗ █████╗ ██╗
    ██╔══██╗██║  ██║██╔══██╗████╗ ████║    ██║  ██║██╔═══██╗████╗  ██║██╔════╝     ╚══██╔══╝██║  ██║██╔══██╗██║
    ██████╔╝███████║███████║██╔████╔██║    ███████║██║   ██║██╔██╗ ██║██║  ███╗       ██║   ███████║███████║██║
    ██╔═══╝ ██╔══██║██╔══██║██║╚██╔╝██║    ██╔══██║██║   ██║██║╚██╗██║██║   ██║       ██║   ██╔══██║██╔══██║██║
    ██║     ██║  ██║██║  ██║██║ ╚═╝ ██║    ██║  ██║╚██████╔╝██║ ╚████║╚██████╔╝       ██║   ██║  ██║██║  ██║██║
    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝
    ]]
dashboard.section.header.val = vim.split(logo, "\n", { trimempty = true })

-- Set menu
dashboard.section.buttons.val = {
  dashboard.button("e", "📄  New file", ":ene <BAR> startinsert <CR>"),
  dashboard.button("f", "🔍  Find file", ":Telescope find_files <CR>"),
  dashboard.button("c", "⚙️  Open Config (~/.config/nvim)", ":e ~/.config/nvim<CR>"),
  dashboard.button("l", "📦  Lazy Plugin Manager", ":Lazy<CR>"),
  dashboard.button("m", "🧱  Mason Package Manager", ":Mason<CR>"),
  dashboard.button("q", "🚪  Quit Neovim", ":qa<CR>"),
}

-- Send config to alpha
alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
vim.cmd [[
    autocmd FileType alpha setlocal nofoldenable
]]
