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
    opts = require "configs.nvim-tree",
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

  -- {
  --   "CopilotC-Nvim/CopilotChat.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
  --     { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
  --   },
  --   build = "make tiktoken", -- Only on MacOS or Linux
  --   opts = {
  --     window = {
  --       width = 0.4,
  --     },
  --     mappings = {
  --       reset = {
  --         normal = "<C-e>",
  --         insert = "<C-e>",
  --       },
  --     },
  --   },
  --   -- See Commands section for default commands if you want to lazy load on them
  -- },

  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      provider = "copilot",
      cursor_applying_provider = 'copilot',
      behaviour = {
        enable_cursor_planning_mode = true,
      },
    },
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },

  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
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
