return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.treesitter"
    end,
  },
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      filters = {
        custom = { "^.git$" },
      },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
    },
  },

  {
    "github/copilot.vim",
    lazy = false,
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
    end,
  },

  {
    "RRethy/vim-illuminate",
    lazy = false,
    config = function()
      require("illuminate").configure {
        providers = { "lsp", "treesitter", "regex" },
        delay = 300,
        filetypes_denylist = { "NvimTree", "TelescopePrompt" },
        modes_allowlist = { "n", "v" },
      }
      vim.cmd "hi IlluminatedWordRead guibg=#525252"
      vim.cmd "hi IlluminatedWordText guibg=#525252"
      vim.cmd "hi IlluminatedWordWrite guibg=#525252"
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    event = "VeryLazy",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      window = {
        width = 0.4,
      },
      mappings = {
        reset = {
          normal = "<C-e>",
          insert = "<C-e>",
        },
      },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },

  -- {
  --   "hrsh7th/nvim-cmp",
  --   opts = function(_, conf)
  --     conf.mapping["<TAB>"] = conf.mapping(function(fallback)
  --       if conf.visible() then
  --         conf.select_next_item { behavior = conf.SelectBehavior.Insert }
  --         conf.mapping.confirm { select = true }
  --       else
  --         fallback()
  --       end
  --     end, { "i", "s" })
  --     return conf
  --   end,
  -- },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
