return {
  {
    "camspiers/luarocks",
    lazy = true,
    dependencies = { "rcarriga/nvim-notify" },
    opts = {
      rocks = { "fzy" },
    },
  },
  {
    -- "camspiers/snap",
    dir = "~/dev/snap",
    lazy = true,
    dependencies = { "camspiers/luarocks" },
    -- Add used keys here with nil to enable lazy loading
    keys = {
      { "<Leader><Leader>", nil },
      { "<Leader>fg", nil },
      { "<Leader>fb", nil },
      { "<Leader>fo", nil },
      { "<Leader>ff", nil },
      { "<Leader>m", nil },
      { "<Leader>fm", nil },
      { "<Leader>n", nil },
      { "<Leader>N", nil },
      { "<Leader>fi", nil },
      { "<Leader>fj", nil },
    },
    config = function()
      local snap = require("snap")
      local filter = pcall(require, "fzy") and snap.get("consumer.fzy") or snap.get("consumer.fzf")

      local defaults = { prompt = "", suffix = "»" }

      local file = snap.config.file:with(defaults)
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
              producer = filter(snap.get("producer.vim.marks")),
              select = snap.get("select.vim.mark").select,
              views = { snap.get("preview.vim.mark") },
            })
          end,
          { desc = "Search local marks" },
        },
        {
          "<Leader>N",
          function()
            snap.run({
              producer = filter(snap.get("producer.vim.globalmarks")),
              select = snap.get("select.vim.mark").select,
              views = { snap.get("preview.vim.mark") },
            })
          end,
          { desc = "Search global marks" },
        },
        {
          "<Leader>fi",
          function()
            snap.run({
              producer = filter(snap.get("producer.vim.currentbuffer")),
              select = snap.get("select.vim.currentbuffer").select,
            })
          end,
          { desc = "Search in current buffer" },
        },
        {
          "<Leader>fj",
          function()
            snap.run({
              producer = filter(require("snap.producer.vim.jumplist")),
              select = snap.get("select.jumplist").select,
              views = { snap.get("preview.jumplist") },
            })
          end,
          { desc = "Search in Jumplist" },
        },
      })
    end,
  },
}
