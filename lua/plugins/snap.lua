return {
  {
    "camspiers/luarocks",
    dependencies = {
      "rcarriga/nvim-notify",
    },
    opts = {
      rocks = { "fzy" },
    },
  },
  {
    -- "camspiers/snap",
    dir = "~/dev/snap",
    dependencies = {
      "camspiers/luarocks",
    },
    config = function()
      local snap = require("snap")
      local filter = pcall(require, "fzy") and snap.get("consumer.fzy") or snap.get("consumer.fzf")

      -- Get marks
      local marks = snap.get("producer.vim.marks")
      local marks_global = snap.get("producer.vim.globalmarks")
      local mark_preview = snap.get("preview.vim.mark")
      local mark_select = snap.get("select.vim.mark")

      -- Get current buffer
      local currentbuffer = snap.get("producer.vim.currentbuffer")
      local currentbuffer_select = snap.get("select.vim.currentbuffer")

      local defaults = {
        prompt = "",
        suffix = "\194\187",
        reverse = true,
        layout = function()
          return snap.get("layout")["%centered"](0.95, 0.8)
        end,
      }

      local file = snap.config.file:with(vim.tbl_extend("force", defaults, {
        consumer = pcall(require, "fzy") and "fzy" or "fzf",
      }))

      local vimgrep = snap.config.vimgrep:with(vim.tbl_extend("force", defaults, {
        limit = 50000,
      }))

      snap.maps({
        {
          "<Leader><Leader>",
          file({ producer = "ripgrep.file", args = { "--hidden", "--iglob", "!.git/*" } }),
          { command = "files" },
        },
        { "<Leader>fg", file({ producer = "git.file" }), { command = "git.files" } },
        { "<Leader>fb", file({ producer = "vim.buffer" }), { command = "buffers" } },
        { "<Leader>fo", file({ producer = "vim.oldfile" }), { command = "oldfiles" } },
        { "<Leader>ff", vimgrep({}), { command = "grep" } },
        { "<Leader>m", vimgrep({ filter_with = "cword" }), { command = "currentwordgrep" } },
        { "<Leader>fm", vimgrep({ filter_with = "selection" }), { modes = "v" } },
        {
          "<Leader>n",
          function()
            snap.run({
              producer = filter(marks),
              select = mark_select.select,
              views = { mark_preview },
            })
          end,
          { desc = "Search local marks" },
        },
        {
          "<Leader>N",
          function()
            snap.run({
              producer = filter(marks_global),
              select = mark_select.select,
              views = { mark_preview },
            })
          end,
          { desc = "Search global marks" },
        },
        {
          "<Leader>fi",
          function()
            snap.run({
              producer = filter(currentbuffer),
              select = currentbuffer_select.select,
            })
          end,
          { desc = "Search in current buffer" },
        },
      })
    end,
  },
}
