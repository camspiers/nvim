local KEYS = {
  FILES = "<Leader><Leader>",
  GIT_FILES = "<Leader>fg",
  BUFFERS = "<Leader>fb",
  OLDFILES = "<Leader>fo",
  GREP = "<Leader>ff",
  GREP_WORD = "<Leader>m",
  GREP_SELECTION = "<Leader>fm",
  MARKS = "<Leader>n",
  GLOBAL_MARKS = "<Leader>N",
  BUFFER = "<Leader>fi",
  JUMPLIST = "<Leader>fj",

  -- LazyVim LSP overrides
  GO_TO_DEFINITION = "gd",
  GO_TO_IMPLEMENTATION = "gI",
  GO_TO_TYPE_DEFINITION = "gy",
  GO_TO_REFERENCES = "gr",
  SHOW_SYMBOLS = "gb",
}

local function mappings_to_keys(mappings)
  return vim.tbl_map(function(value)
    return { value, nil }
  end, vim.tbl_values(mappings))
end

local function remove_conflicting_lsp_keys()
  local lsp_keymaps = require("lazyvim.plugins.lsp.keymaps").get()
  local index = 1
  for _, value in ipairs({ unpack(lsp_keymaps) }) do
    if vim.tbl_contains(vim.tbl_values(KEYS), value[1]) then
      table.remove(lsp_keymaps, index)
    else
      -- Only increment the index if we didn't remove a value
      index = index + 1
    end
  end
end

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
    "neovim/nvim-lspconfig",
    -- This is required because I want to override LazyVims telescope bindings with snap
    dependencies = { "camspiers/snap" },
  },
  {
    -- "camspiers/snap",
    dir = "~/dev/snap",
    dependencies = { "camspiers/luarocks" },
    keys = mappings_to_keys(KEYS),
    config = function()
      -- Remove all the LSP maps that we don't want
      remove_conflicting_lsp_keys()

      local snap = require("snap")
      local filter = pcall(require, "fzy") and snap.get("consumer.fzy") or snap.get("consumer.fzf")
      local defaults = { prompt = "", suffix = "»" }
      local file = snap.config.file:with(defaults)
      local vimgrep = snap.config.vimgrep:with(vim.tbl_extend("force", defaults, {
        limit = 50000,
      }))

      local lsp = {
        producers = require("snap.producer.lsp"),
        select = require("snap.select.lsp"),
        preview = require("snap.preview.lsp"),
      }

      local function create_snap_lsp_location_handler(producer)
        return function()
          snap.run({
            producer = filter(producer),
            select = lsp.select.select,
            autoselect = lsp.select.autoselect,
            views = { lsp.preview },
          })
        end
      end

      snap.maps({
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
        {
          KEYS.GO_TO_DEFINITION,
          create_snap_lsp_location_handler(lsp.producers.definitions),
          { desc = "Go to definition" },
        },
        {
          KEYS.GO_TO_IMPLEMENTATION,
          create_snap_lsp_location_handler(lsp.producers.implementations),
          { desc = "Go to implementation" },
        },
        {
          KEYS.GO_TO_TYPE_DEFINITION,
          create_snap_lsp_location_handler(lsp.producers.type_definitions),
          { desc = "Go to type definition" },
        },
        {
          KEYS.GO_TO_REFERENCES,
          create_snap_lsp_location_handler(lsp.producers.references),
          { desc = "Go to references" },
        },
        {
          KEYS.SHOW_SYMBOLS,
          function()
            snap.run({
              producer = filter(lsp.producers.symbols),
              select = lsp.select.select,
              views = { lsp.preview },
            })
          end,
          { desc = "Show symbols" },
        },
      })
    end,
  },
}
