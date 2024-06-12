-- [[Initialization]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- [[Plugins]]
require("lazy").setup("camspiers/plugins", {
  change_detection = { enabled = false },
  checker = { enabled = true },
})

-- [[Custom]]
vim.cmd.runtime({ "lua/camspiers/startup/*.lua", bang = true })
