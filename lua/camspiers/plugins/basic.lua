local vars = require("camspiers/share/vars")

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = vars.colorscheme_flavor,
    },
    init = function()
      -- vim.cmd.colorscheme(require("camspiers/share/vars").colorscheme)
    end,
  },
  "editorconfig/editorconfig-vim",
  { "Olical/nfnl", ft = "fennel" },
  { "Bilal2453/luvit-meta", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = { scope = { enabled = false } } },
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
    "nvim-lualine/lualine.nvim",
    opts = {
      theme = vars.colorscheme,
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
      -- I only use the tabline for tabs, this ensures that the showtabline setting doesn't get changed by lualine
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
        show_hidden = true,
      },
      skip_confirm_for_simple_edits = true,
      win_options = {
        number = false,
        relativenumber = false,
      },
    },
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    config = true,
  },
}
