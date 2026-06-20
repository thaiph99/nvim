local telescope = require "telescope"

telescope.setup {
  defaults = {
    prompt_prefix = "   ",
    selection_caret = " ",
    sorting_strategy = "ascending",
    layout_config = {
      horizontal = { prompt_position = "top", preview_width = 0.55 },
      width = 0.87,
      height = 0.80,
    },
    mappings = {
      i = { ["<Esc>"] = require("telescope.actions").close },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
}

pcall(telescope.load_extension, "fzf")
