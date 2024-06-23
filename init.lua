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

-- Allow the sourcing of lua files from a non "nvim" directory, specifically to avoid commiting private code
package.path = package.path .. ";" .. vim.fn.stdpath("config") .. "/../nvim-lua/?.lua"

-- [[Plugins]]
require("lazy").setup("camspiers/plugins", {
  change_detection = { enabled = false },
  checker = { enabled = false },
})

-- [[Custom]]
vim.cmd.runtime({ "lua/camspiers/startup/*.lua", bang = true })
