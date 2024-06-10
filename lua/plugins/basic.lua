return {
  "tpope/vim-repeat",
  "romainl/vim-cool",
  "rcarriga/nvim-notify",
  "editorconfig/editorconfig-vim",
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = { scope = { enabled = false } } },
  { "Olical/nfnl", ft = "fennel" },
  { "Bilal2453/luvit-meta", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "latte",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      theme = "catppuccin-latte",
      options = {
        section_separators = "",
        component_separators = "",
        globalstatus = true,
      },
      tabline = {
        lualine_a = {
          { "tabs" },
        },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        callback = function(info)
          if info.data == "lualine.nvim" then
            vim.opt.showtabline = 1
          end
        end,
      })
    end,
  },
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    opts = {
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,
      },
      skip_confirm_for_simple_edits = true,
    },
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    config = true,
  },
}
