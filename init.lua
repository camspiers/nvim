-- [[Initialization]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- [[Helper]]
local function close_all_buffers(force)
  for _, value in ipairs(vim.api.nvim_list_bufs()) do
    if (vim.fn.buflisted(value) == 1) and (vim.fn.bufexists(value) == 1) then
      vim.api.nvim_buf_delete(value, { force = force })
    else
    end
  end
  return nil
end

-- [[Keymaps]]
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<Leader>w", "<CMD>w<CR>", { desc = "Write" })
vim.keymap.set("n", "<Tab>", "<CMD>bn<CR>", { desc = "Buffer next" })
vim.keymap.set("n", "<S-Tab>", "<CMD>bp<CR>", { desc = "Buffer previous" })
vim.keymap.set("n", "<Leader>x", "<CMD>bd<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<Leader><S-x>", "<CMD>bd!<CR>", { desc = "Delete buffer (!)" })
vim.keymap.set("n", "<Leader>z", function()
  close_all_buffers(false)
end, { desc = "Delete all buffers" })
vim.keymap.set("n", "<Leader><S-z>", function()
  close_all_buffers(true)
end, { desc = "Delete all buffers (!)" })
vim.keymap.set("n", "<Leader>c", "<CMD>clo<CR>", { desc = "Close window" })
vim.keymap.set("n", "<Leader><S-c>", "<CMD>%clo<CR>", { desc = "Close all windows" })
vim.keymap.set("n", "<Leader>o", "<CMD>only<CR>", { desc = "Only window" })
vim.keymap.set("n", "<Leader>'", "<CMD>Neogit<CR>", { desc = "Open Neogit" })
vim.keymap.set("n", "<Leader>-", "<CMD>split<CR>", { desc = "Split below" })
vim.keymap.set("n", "<Leader>|", "<CMD>vsplit<CR>", { desc = "Split right" })
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
vim.keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })
vim.keymap.set("n", "<Leader>+", vim.cmd.tabnew, { desc = "New Tab" })
vim.keymap.set("n", "<Leader><Tab>", vim.cmd.tabnext, { desc = "Next Tab" })
vim.keymap.set("n", "<Leader><S-Tab>", vim.cmd.tabprev, { desc = "Prev Tab" })
vim.keymap.set("n", "<Leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
vim.keymap.set("n", "<Leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
vim.keymap.set("n", "<Leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })
vim.keymap.set({ "n", "i" }, "<Esc>", function()
  vim.cmd.nohlsearch()
  vim.cmd.stopinsert()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end)

-- [[Options]]
vim.g.mapleader = "\\"
vim.g.maplocalleader = ","
vim.g.background = "light"
vim.opt.guifont = "Source Code Pro Light:h13"
vim.opt.conceallevel = 0
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menuone,noselect"
vim.opt.termguicolors = true
vim.opt.scrolloff = 20
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.breakindent = true
vim.opt.showmode = false
vim.opt.wrap = false
vim.opt.smoothscroll = true
vim.opt.spelllang = { "en" }
vim.opt.ignorecase = true
vim.opt.inccommand = "nosplit"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.wildmode = "longest:full,full"

-- [[Plugins]]
require("lazy").setup("plugins", {
  change_detection = { enabled = false },
})

-- [[Theme]]
vim.cmd.colorscheme("catppuccin-latte")
