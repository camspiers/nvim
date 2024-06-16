local KEYS = {
  FILES = "<Leader><Leader>",
  GIT_FILES = "<Leader>fg",
  BUFFERS = "<Leader>fb",
  OLDFILES = "<Leader>fo",

  -- Grep
  GREP = "<Leader>ff",
  GREP_WORD = "<Leader>m",
  GREP_SELECTION = "<Leader>fm",

  -- Marks
  MARKS = "<Leader>n",
  GLOBAL_MARKS = "<Leader>N",
  BUFFER = "<Leader>fi",

  -- TODO better name
  GREP_BUFFERS = "<Leader>fB",
  JUMPLIST = "<Leader>fj",

  -- Git integrations
  GIT_LOG = "<Leader>gl",
  GIT_LOCAL_BRANCHES = "<Leader>gb",
  GIT_REMOTE_BRANCHES = "<Leader>gB",

  -- Resume search
  RESUME_SEARCH = "<Leader>i",
}

local function mappings_to_keys(mappings)
  return vim.tbl_map(function(value)
    return { value, nil }
  end, vim.tbl_values(mappings))
end

return {
  {
    "camspiers/luarocks",
    lazy = true,
    opts = {
      rocks = { "fzy" },
    },
  },
  {
    "camspiers/snap",
    -- dir = "~/dev/snap",
    dependencies = { "camspiers/luarocks" },
    keys = mappings_to_keys(KEYS),
    config = function()
      vim.ui.select = function(items, opts, on_choice)
        local snap = require("snap")
        local filter = pcall(require, "fzy") and snap.get("consumer.fzy") or snap.get("consumer.fzf")
        snap.run({
          prompt = opts.prompt or "Select>",
          producer = filter(function()
            local result = {}
            for index, value in ipairs(items) do
              table.insert(
                result,
                snap.with_metas(opts.format_item and opts.format_item(value) or value, { value = value, index = index })
              )
            end
            return result
          end),
          select = vim.schedule_wrap(function(selection)
            if selection == nil then
              return
            end
            on_choice(selection.value, selection.index)
          end),
        })
      end

      local snap = require("snap")
      local tbl = require("snap.common.tbl")
      local run = snap.run
      local last_config = nil

      snap.run = function(config)
        last_config = config
        local function on_update(filter)
          if config.on_update then
            config.on_update(filter)
          end
          last_config.initial_filter = filter
        end
        run(tbl.merge(config, { on_update = on_update }))
      end

      local filter = pcall(require, "fzy") and snap.get("consumer.fzy") or snap.get("consumer.fzf")
      local defaults = { prompt = "", suffix = "»" }
      local file = snap.config.file:with(defaults)
      local vimgrep = snap.config.vimgrep:with(vim.tbl_extend("force", defaults, {
        limit = 50000,
      }))

      snap.maps({
        {
          KEYS.RESUME_SEARCH,
          function()
            if last_config then
              snap.run(last_config)
            end
          end,
        },
        {
          KEYS.FILES,
          file({ producer = "ripgrep.file", args = { "--hidden", "--iglob", "!.git/*" } }),
          { command = "files" },
        },
        { KEYS.GIT_FILES, file({ producer = "git.file" }), { command = "git.files" } },
        { KEYS.BUFFERS, file({ producer = "vim.buffer" }), { command = "buffers" } },
        { KEYS.OLDFILES, file({ producer = "vim.oldfile" }), { command = "oldfiles" } },
        { KEYS.GREP, vimgrep({}), { command = "grep" } },
        { KEYS.GREP_WORD, vimgrep({ filter_with = "cword" }), { command = "currentwordgrep" } },
        { KEYS.GREP_SELECTION, vimgrep({ filter_with = "selection" }), { modes = "v" } },
        {
          KEYS.MARKS,
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
          KEYS.GLOBAL_MARKS,
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
          KEYS.BUFFER,
          function()
            snap.run({
              producer = filter(snap.get("producer.vim.currentbuffer")),
              select = snap.get("select.vim.currentbuffer").select,
              views = { snap.get("preview.vim.currentbuffer") },
            })
          end,
          { desc = "Search in current buffer" },
        },
        {
          KEYS.JUMPLIST,
          function()
            snap.run({
              producer = filter(snap.get("producer.vim.jumplist")),
              select = snap.get("select.jumplist").select,
              views = { snap.get("preview.jumplist") },
            })
          end,
          { desc = "Search in Jumplist" },
        },
        -- Git integrations
        {
          KEYS.GIT_LOG,
          function()
            snap.run({
              producer = filter(snap.get("producer.git.log")),
              select = function(selection)
                snap.run({
                  prompt = string.format("Action on commit '%s'?", selection.hash),
                  suffix = "",
                  producer = filter(function()
                    return { "checkout", "reset" }
                  end),
                  select = function(choice)
                    print(tostring(choice) .. " : " .. selection.hash)
                  end,
                  layout = function()
                    return snap.get("layout")["%bottom"](0.2, 0.1)
                  end,
                })
              end,
              views = { snap.get("preview.git.log") },
            })
          end,
          { desc = "Search in git log" },
        },
        {
          KEYS.GIT_LOCAL_BRANCHES,
          function()
            snap.run({
              producer = filter(snap.get("producer.git.branch.local")),
              select = snap.get("select.git").branch,
            })
          end,
          { desc = "Search in git branches" },
        },
        {
          KEYS.GIT_REMOTE_BRANCHES,
          function()
            snap.run({
              producer = filter(snap.get("producer.git.branch.remote")),
              select = function(selection)
                snap.run({
                  producer = filter(function()
                    return { "checkout", "reset" }
                  end),
                  select = function(choice)
                    print(tostring(choice) .. " : " .. tostring(selection))
                  end,
                  layout = function()
                    return snap.get("layout")["%bottom"](0.2, 0.1)
                  end,
                })
              end,
            })
          end,
          { desc = "Search in remote git branches" },
        },
      })
    end,
  },
}
