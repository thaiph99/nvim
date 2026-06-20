local function gh(repo)
  return "https://github.com/" .. repo
end

-- Build commands for plugins that ship native code, run on install/update.
local build_steps = {
  ["telescope-fzf-native.nvim"] = { "make" },
}

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("user_pack_build", { clear = true }),
  callback = function(ev)
    local data = ev.data
    if data.kind ~= "install" and data.kind ~= "update" then
      return
    end
    local cmd = build_steps[data.spec.name]
    if not cmd then
      return
    end
    vim.notify(("Building %s ..."):format(data.spec.name), vim.log.levels.INFO)
    vim.system(cmd, { cwd = data.path }, function(out)
      local level = out.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
      vim.schedule(function()
        vim.notify(("Build %s: %s"):format(data.spec.name, out.code == 0 and "ok" or (out.stderr or "failed")), level)
      end)
    end)
  end,
})

-- load = true forces :packadd now, so we can require plugin configs below.
vim.pack.add({
  { src = gh "nvim-lua/plenary.nvim" },
  { src = gh "MunifTanjim/nui.nvim" },
  { src = gh "nvim-tree/nvim-web-devicons" },
  { src = gh "Mofiqul/dracula.nvim" },
  { src = gh "nvim-treesitter/nvim-treesitter",         version = "main" },
  { src = gh "neovim/nvim-lspconfig" },
  { src = gh "mason-org/mason.nvim" },
  -- Pinned to v1: v2 (default branch) needs a separate blink.lib dep.
  { src = gh "saghen/blink.cmp",                        version = "v1.10.2" },
  { src = gh "nvim-telescope/telescope.nvim" },
  { src = gh "nvim-telescope/telescope-fzf-native.nvim" },
  { src = gh "nvim-tree/nvim-tree.lua" },
  { src = gh "lewis6991/gitsigns.nvim" },
  { src = gh "stevearc/conform.nvim" },
  { src = gh "kylechui/nvim-surround" },
  { src = gh "github/copilot.vim" },
  { src = gh "mfussenegger/nvim-dap" },
  { src = gh "rcarriga/nvim-dap-ui" },
  { src = gh "nvim-neotest/nvim-nio" },
  { src = gh "jay-babu/mason-nvim-dap.nvim" },
  { src = gh "theHamsta/nvim-dap-virtual-text" },
  { src = gh "mfussenegger/nvim-jdtls" },
}, { load = true })

-- Load order: ui/devicons first, completion before lsp (capabilities), rest independent.
local modules = {
  "plugins.ui",
  "plugins.treesitter",
  "plugins.completion",
  "plugins.lsp",
  "plugins.telescope",
  "plugins.nvimtree",
  "plugins.gitsigns",
  "plugins.conform",
  "plugins.editor",
  "plugins.dap",
  "plugins.jdtls",
}

for _, mod in ipairs(modules) do
  local ok, err = pcall(require, mod)
  if not ok then
    vim.schedule(function()
      vim.notify(("Failed to load %s:\n%s"):format(mod, err), vim.log.levels.ERROR)
    end)
  end
end
