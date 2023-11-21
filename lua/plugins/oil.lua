return {
  "stevearc/oil.nvim",
  opts = {
    view_options = {
      -- Show files and directories that start with "."
      show_hidden = true,
    },
    skip_confirm_for_simple_edits = true,
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
}
