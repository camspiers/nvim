local maps = {
  { key = "-", action = "<CMD>Oil<CR>" },
  {
    key = "<Esc>",
    action = function()
      vim.cmd.nohlsearch()
      vim.cmd.stopinsert()
    end,
    mode = { "n", "i" },
  },
  { key = "<C-h>", action = "<C-w>h" },
  { key = "<C-j>", action = "<C-w>j" },
  { key = "<C-k>", action = "<C-w>k" },
  { key = "<C-l>", action = "<C-w>l" },
  { key = "<Tab>", action = vim.cmd.bnext },
  { key = "<S-Tab>", action = vim.cmd.bprev },
  { key = "[q", action = vim.cmd.cprev },
  { key = "]q", action = vim.cmd.cnext },
  { key = "<Leader><S-x>", action = "<CMD>bd!<CR>" },
  { key = "<Leader>z", action = "<CMD>%bd<CR>" },
  { key = "<Leader><S-z>", action = "<CMD>%bd!<CR>" },
  { key = "<Leader><S-c>", action = "<CMD>%clo<CR>" },
  { key = "<Leader>'", action = "<CMD>Neogit<CR>" },
  { key = "<Leader>w", action = vim.cmd.write },
  { key = "<Leader>x", action = vim.cmd.bdelete },
  { key = "<Leader>c", action = vim.cmd.close },
  { key = "<Leader>o", action = vim.cmd.only },
  { key = "<Leader>-", action = vim.cmd.split },
  { key = "<Leader>|", action = vim.cmd.vsplit },
  { key = "<Leader>+", action = vim.cmd.tabnew },
  { key = "<Leader><Tab>", action = vim.cmd.tabnext },
  { key = "<Leader><S-Tab>", action = vim.cmd.tabprev },
  { key = "<Leader>l", action = "<cmd>Lazy<cr>" },
  { key = "<Leader>xl", action = vim.cmd.lopen },
  { key = "<Leader>xq", action = vim.cmd.copen },
  -- Run ollama in a terminal
  {
    mode = { "n", "v" },
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

      vim.cmd.tabnew()
      vim.cmd.term("ollama run code --nowordwrap")

      local buffer = vim.api.nvim_get_current_buf()
      vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = buffer })
      vim.keymap.set("n", "<Esc>", function()
        vim.api.nvim_buf_delete(buffer, { force = true })
      end, { buffer = buffer })

      -- Defer because otherwise we get repeated content displayed
      vim.defer_fn(function()
        vim.cmd.startinsert()
        if text ~= nil then
          vim.api.nvim_chan_send(vim.b[buffer].terminal_job_id, '"""' .. text)
        end
      end, 500)
    end,
  },
  { key = "<Leader>e", action = vim.diagnostic.open_float },
  { key = "<Leader>q", action = vim.diagnostic.setloclist },
}

for _, value in ipairs(maps) do
  vim.keymap.set(value.mode or "n", value.key, value.action)
end
