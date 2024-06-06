-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")

local function close_all_buffers(force)
  for _, value in ipairs(vim.api.nvim_list_bufs()) do
    if (vim.fn.buflisted(value) == 1) and (vim.fn.bufexists(value) == 1) then
      vim.api.nvim_buf_delete(value, { force = force })
    else
    end
  end
  return nil
end

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>w", "<CMD>w<CR>", { desc = "Write" })
vim.keymap.set("n", "<Tab>", "<CMD>bn<CR>", { desc = "Buffer next" })
vim.keymap.set("n", "<S-Tab>", "<CMD>bp<CR>", { desc = "Buffer previous" })
vim.keymap.set("n", "<leader>x", "<CMD>bd<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader><S-x>", "<CMD>bd!<CR>", { desc = "Delete buffer (!)" })
vim.keymap.set("n", "<leader>z", function()
  close_all_buffers(false)
end, { desc = "Delete all buffers" })
vim.keymap.set("n", "<leader><S-z>", function()
  close_all_buffers(true)
end, { desc = "Delete all buffers (!)" })
vim.keymap.set("n", "<leader>c", "<CMD>clo<CR>", { desc = "Close window" })
vim.keymap.set("n", "<leader><S-c>", "<CMD>%clo<CR>", { desc = "Close all windows" })
vim.keymap.set("n", "<leader>o", "<CMD>only<CR>", { desc = "Only window" })
vim.keymap.set("n", "<leader>'", "<CMD>Neogit<CR>", { desc = "Open Neogit" })

-- vim.keymap.set("n", "<leader>'", function()
--   Util.terminal({ "lazygit" }, { cwd = Util.root(), esc_esc = false, ctrl_hjkl = false })
-- end, { desc = "Lazygit (root dir)" })
