local vars = require("camspiers/share/vars")

vim.api.nvim_set_option_value("background", vars.colorscheme_background, {})
vim.cmd.colorscheme(vars.colorscheme)
