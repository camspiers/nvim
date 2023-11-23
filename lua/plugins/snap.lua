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
}

local MAPPINGS_LSP = {
  -- LazyVim LSP overrides
  GO_TO_DEFINITION = "gd",
  GO_TO_IMPLEMENTATION = "gI",
  GO_TO_TYPE_DEFINITION = "gy",
}

local function create_snap_lsp_handler(action)
  return function()
    local snap = require("snap")

    local function async(executor)
      local value = nil
      local error = nil
      local function resolve(val)
        value = val
      end
      local function reject(err)
        error = err
      end
      executor(resolve, reject)
      while value == nil and error == nil do
        snap.continue()
      end
      return value, error
    end

    snap.run({
      producer = function(request)
        -- To exit just delete the current buffer
        local exit = function()
          snap.sync(function()
            vim.api.nvim_buf_delete(vim.api.nvim_get_current_buf(), { force = true })
          end)
        end

        local response, error = async(function(resolve, reject)
          snap.sync(function()
            vim.lsp.buf_request(
              vim.api.nvim_win_get_buf(request.winnr),
              action,
              vim.lsp.util.make_position_params(request.winnr),
              function(error, result, context, _)
                if error then
                  reject(error)
                else
                  resolve({ locations = vim.tbl_islist(result) and result or { result }, context = context })
                end
              end
            )
          end)
        end)

        if response == nil or error or #response.locations == 0 then
          exit()
        elseif #response.locations == 1 then
          exit()
          snap.sync(function()
            vim.lsp.util.jump_to_location(
              response.locations[1],
              vim.lsp.get_client_by_id(response.context.client_id).offset_encoding,
              true
            )
          end)
        else
          return vim.tbl_map(
            function(item)
              return snap.with_metas(item.filename, item)
            end,
            snap.sync(function()
              return vim.lsp.util.locations_to_items(
                response.locations,
                vim.lsp.get_client_by_id(response.context.client_id).offset_encoding
              )
            end)
          )
        end
      end,
      select = require("snap.select.common.file")(function(selection)
        return { path = selection.filename, lnum = selection.lnum, col = selection.col }
      end),
      views = {
        require("snap.preview.common.create-file-preview")(function(selection)
          return { path = selection.filename, line = selection.lnum, column = selection.col }
        end),
      },
    })
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
    dependencies = { "camspiers/snap" },
    keys = vim.tbl_map(function(value)
      return { value, nil }
    end, vim.tbl_values(MAPPINGS_LSP)),
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      table.insert(keys, {
        MAPPINGS_LSP.GO_TO_DEFINITION,
        create_snap_lsp_handler("textDocument/definition"),
      })
      table.insert(keys, {
        MAPPINGS_LSP.GO_TO_IMPLEMENTATION,
        create_snap_lsp_handler("textDocument/implementation"),
      })
      table.insert(keys, {
        MAPPINGS_LSP.GO_TO_TYPE_DEFINITION,
        create_snap_lsp_handler("textDocument/typeDefinition"),
      })
    end,
  },
  {
    -- "camspiers/snap",
    dir = "~/dev/snap",
    dependencies = { "camspiers/luarocks" },
    keys = vim.tbl_map(function(value)
      return { value, nil }
    end, vim.tbl_values(MAPPINGS)),
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
    end,
  },
}
