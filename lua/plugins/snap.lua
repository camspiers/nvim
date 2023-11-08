return {
  -- "camspiers/snap",
  dir = "~/dev/snap",
  config = function()
    local snap = require("snap")

    local layout = snap.get("layout")
    local fzf = snap.get("consumer.fzf")
    local producer_jumplist = snap.get("producer.vim.jumplist")
    local producer_help = snap.get("producer.vim.help")
    local producer_tmux_session = snap.get("producer.tmux.session")
    local select_help = snap.get("select.help")
    local select_jumplist = snap.get("select.jumplist")
    local select_tmux_switch = snap.get("select.tmux.switch")
    local preview_help = snap.get("preview.help")
    local preview_jumplist = snap.get("preview.jumplist")

    local function create(config)
      return snap.create(config, { layout = layout.bottom, reverse = true })
    end

    local reverse = true

    local args = { "--hidden", "--iglob", "!.git/*" }

    local function centered()
      return layout["%centered"](0.95, 0.8)
    end

    local file = (snap.config.file):with({
      reverse = reverse,
      consumer = "fzf",
      layout = centered,
      suffix = "\194\187",
    })

    local vimgrep = (snap.config.vimgrep):with({
      reverse = reverse,
      layout = centered,
      limit = 50000,
      suffix = "\194\187",
    })

    snap.maps({
      { "<Leader><Leader>", file({ producer = "ripgrep.file", args = args }), { command = "files" } },
      { "<Leader>fg", file({ producer = "git.file" }), { command = "git.files" } },
      { "<Leader>fb", file({ producer = "vim.buffer" }), { command = "buffers" } },
      { "<Leader>ff", vimgrep({}), { command = "grep" } },
      { "<Leader>m", vimgrep({ filter_with = "cword" }), { command = "currentwordgrep" } },
      { "<Leader>fm", vimgrep({ filter_with = "selection" }), { modes = "v" } },
      { "<Leader>fo", file({ producer = "vim.oldfile" }), { command = "oldfiles" } },
      {
        "<Leader>fs",
        file({ try = { "git.file", "ripgrep.file" }, args = args }),
        { command = "git-with-fallback" },
      },
    })

    snap.register.map(
      { "n" },
      { "<Leader>s" },
      create(function()
        return {
          prompt = "Switch Session>",
          producer = fzf(producer_tmux_session),
          select = select_tmux_switch.select,
        }
      end)
    )

    snap.register.map(
      { "n" },
      { "<Leader>fh" },
      create(function()
        return {
          prompt = "Help>",
          producer = fzf(producer_help),
          select = select_help.select,
          views = { preview_help },
        }
      end)
    )

    snap.register.map(
      { "n" },
      { "<Leader>fj" },
      create(function()
        return {
          prompt = "Jumplist>",
          producer = fzf(producer_jumplist),
          select = select_jumplist.select,
          views = { preview_jumplist },
        }
      end)
    )
  end,
}
