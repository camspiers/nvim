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
local maps = {
  {
    key = "<Leader>z",
    action = function()
      close_all_buffers(false)
    end,
  },
  {
    key = "<Leader><S-z>",
    action = function()
      close_all_buffers(true)
    end,
  },
  { key = "-", action = "<CMD>Oil<CR>" },
  { key = "<Leader>w", action = "<CMD>w<CR>" },
  { key = "<Tab>", action = "<CMD>bn<CR>" },
  { key = "<S-Tab>", action = "<CMD>bp<CR>" },
  { key = "<Leader>x", action = "<CMD>bd<CR>" },
  { key = "<Leader><S-x>", action = "<CMD>bd!<CR>" },
  { key = "<Leader>c", action = "<CMD>clo<CR>" },
  { key = "<Leader><S-c>", action = "<CMD>%clo<CR>" },
  { key = "<Leader>o", action = "<CMD>only<CR>" },
  { key = "<Leader>'", action = "<CMD>Neogit<CR>" },
  { key = "<Leader>-", action = "<CMD>split<CR>" },
  { key = "<Leader>|", action = "<CMD>vsplit<CR>" },
  { key = "<C-h>", action = "<C-w>h" },
  { key = "<C-j>", action = "<C-w>j" },
  { key = "<C-k>", action = "<C-w>k" },
  { key = "<C-l>", action = "<C-w>l" },
  { key = "[q", action = vim.cmd.cprev },
  { key = "]q", action = vim.cmd.cnext },
  { key = "<Leader>+", action = vim.cmd.tabnew },
  { key = "<Leader><Tab>", action = vim.cmd.tabnext },
  { key = "<Leader><S-Tab>", action = vim.cmd.tabprev },
  { key = "<Leader>l", action = "<cmd>Lazy<cr>" },
  { key = "<Leader>xl", action = "<cmd>lopen<cr>" },
  { key = "<Leader>xq", action = "<cmd>copen<cr>" },
  {
    key = "<Esc>",
    action = function()
      vim.cmd.nohlsearch()
      vim.cmd.stopinsert()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative == "win" then
          vim.api.nvim_win_close(win, false)
        end
      end
    end,
    mode = { "n", "i" },
  },
  {
    key = "<Leader>/",
    action = function()
      local mode = vim.api.nvim_get_mode().mode
      local text = nil

      if mode == "V" or mode == "v" then
        local register = vim.fn.getreg('"')
        vim.cmd("normal! y")
        text = vim.fn.trim(vim.fn.getreg("@"))
        vim.fn.setreg('"', register)
      end

      vim.cmd.term("ollama run code --nowordwrap")

      local buffer = vim.api.nvim_get_current_buf()

      vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = buffer })
      vim.keymap.set("n", "<Esc>", function()
        vim.api.nvim_buf_delete(buffer, { force = true })
      end, { buffer = buffer })

      vim.defer_fn(function()
        if text ~= nil then
          vim.api.nvim_chan_send(vim.b[buffer].terminal_job_id, '"""' .. text)
        end
        vim.cmd.startinsert()
      end, 500)
    end,
    mode = { "n", "v" },
  },
}

for _, value in ipairs(maps) do
  vim.keymap.set(value.mode or "n", value.key, value.action)
end

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
