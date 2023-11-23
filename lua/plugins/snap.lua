local MAPPINGS = {
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

local function make_lsp_request(bufnr, action, params, on_value, on_error)
  vim.lsp.buf_request(bufnr, action, params, function(error, result, context)
    if error then
      on_error(error)
    else
      on_value({
        results = vim.tbl_islist(result) and result or { result },
        context = context,
      })
    end
  end)
end

local function create_lsp_producer(action, make_params, process_results)
  local snap = require("snap")

  return function(request)
    local response, error = snap.async(function(resolve, reject)
      snap.sync(function()
        make_lsp_request(vim.api.nvim_win_get_buf(request.winnr), action, make_params(request.winnr), resolve, reject)
      end)
    end)

    if response == nil or error or #response.results == 0 then
      if error then
        snap.sync(function()
          vim.notify("There was an error when calling LSP: " .. error.message, vim.log.levels.ERROR)
        end)
      end
      return {}
    end

    return process_results(request, response)
  end
end

local function create_lsp_location_producer(action, make_params)
  local snap = require("snap")
  return create_lsp_producer(action, make_params or vim.lsp.util.make_position_params, function(_, response)
    local offset_encoding = snap.sync(function()
      return vim.lsp.get_client_by_id(response.context.client_id).offset_encoding
    end)
    return vim.tbl_map(
      function(item)
        return snap.with_metas(item.filename, vim.tbl_extend("force", item, { offset_encoding = offset_encoding }))
      end,
      snap.sync(function()
        return vim.lsp.util.locations_to_items(response.results, offset_encoding)
      end)
    )
  end)
end

local function create_lsp_symbol_producer(action, make_params)
  local snap = require("snap")
  return create_lsp_producer(action, make_params or vim.lsp.util.make_position_params, function(request, response)
    return vim.tbl_map(
      function(item)
        return snap.with_metas(item.text, item)
      end,
      snap.sync(function()
        return vim.lsp.util.symbols_to_items(response.results, vim.api.nvim_win_get_buf(request.winnr))
      end)
    )
  end)
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
    "camspiers/snap",
    -- dir = "~/dev/snap",
    dependencies = { "camspiers/luarocks" },
    keys = mappings_to_keys(MAPPINGS),
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
          MAPPINGS.FILES,
          file({ producer = "ripgrep.file", args = { "--hidden", "--iglob", "!.git/*" } }),
          { command = "files" },
        },
        { MAPPINGS.GIT_FILES, file({ producer = "git.file" }), { command = "git.files" } },
        { MAPPINGS.BUFFERS, file({ producer = "vim.buffer" }), { command = "buffers" } },
        { MAPPINGS.OLDFILES, file({ producer = "vim.oldfile" }), { command = "oldfiles" } },
        { MAPPINGS.GREP, vimgrep({}), { command = "grep" } },
        { MAPPINGS.GREP_WORD, vimgrep({ filter_with = "cword" }), { command = "currentwordgrep" } },
        { MAPPINGS.GREP_SELECTION, vimgrep({ filter_with = "selection" }), { modes = "v" } },
        {
          MAPPINGS.MARKS,
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
          MAPPINGS.GLOBAL_MARKS,
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
          MAPPINGS.BUFFER,
          function()
            snap.run({
              producer = filter(snap.get("producer.vim.currentbuffer")),
              select = snap.get("select.vim.currentbuffer").select,
            })
          end,
          { desc = "Search in current buffer" },
        },
        {
          MAPPINGS.JUMPLIST,
          function()
            snap.run({
              producer = filter(snap.get("producer.vim.jumplist")),
              select = snap.get("select.jumplist").select,
              views = { snap.get("preview.jumplist") },
            })
          end,
          { desc = "Search in Jumplist" },
        },
      })

      local lsp_select = snap.get("select.common.file")(function(selection)
        -- TODO: This shows that I need to tidy up the standard types for path, lnum and column
        return { path = selection.filename, lnum = selection.lnum, col = selection.col }
      end)

      local lsp_preview = snap.get("preview.common.create-file-preview")(function(selection)
        return { path = selection.filename, line = selection.lnum, column = selection.col }
      end)

      local function create_snap_lsp_location_handler(action, make_params)
        return function()
          snap.run({
            producer = filter(create_lsp_location_producer(action, make_params)),
            select = lsp_select,
            views = { lsp_preview },
            autoselect = function(selection)
              vim.lsp.util.jump_to_location(selection.user_data, selection.offset_encoding, true)
            end,
          })
        end
      end

      local function create_snap_lsp_references_handler()
        return create_snap_lsp_location_handler("textDocument/references", function(winnr)
          return vim.tbl_deep_extend("force", vim.lsp.util.make_position_params(winnr), {
            context = {
              includeDeclaration = true,
            },
          })
        end)
      end

      local function create_snap_lsp_symbol_handler(action, make_params)
        return function()
          snap.run({
            producer = filter(create_lsp_symbol_producer(action, make_params)),
            select = lsp_select,
            views = { lsp_preview },
          })
        end
      end

      local keys = require("lazyvim.plugins.lsp.keymaps").get()

      vim.list_extend(keys, {
        {
          MAPPINGS.GO_TO_DEFINITION,
          create_snap_lsp_location_handler("textDocument/definition"),
          desc = "Go to definition",
        },
        {
          MAPPINGS.GO_TO_IMPLEMENTATION,
          create_snap_lsp_location_handler("textDocument/implementation"),
          desc = "Go to implementation",
        },
        {
          MAPPINGS.GO_TO_TYPE_DEFINITION,
          create_snap_lsp_location_handler("textDocument/typeDefinition"),
          desc = "Go to type definition",
        },
        {
          MAPPINGS.GO_TO_REFERENCES,
          create_snap_lsp_references_handler(),
          desc = "Go to references",
        },
        {
          MAPPINGS.SHOW_SYMBOLS,
          create_snap_lsp_symbol_handler("textDocument/documentSymbol"),
          desc = "Show symbols",
        },
      })
    end,
  },
}
