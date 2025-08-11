return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      { "neovim/nvim-lspconfig" },
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      local servers = {
        "robotframework_ls",
        "html",
        "cssls",
        "tailwindcss",
        "reason_ls",
        "ocamllsp",
        "biome",
        "lua_ls",
        "ts_ls",
        "vue_ls",
        "vtsls",
      }

      require("mason-lspconfig").setup({
        automatic_enable = false,
        ensure_installed = servers,
      })

      vim.lsp.enable(servers)

      -- Setup snap actions for LSP
      local snap = require("snap")
      local filter = pcall(require, "fzy") and snap.get("consumer.fzy") or snap.get("consumer.fzf")
      local producers = require("snap.producer.lsp")

      local function lsp_action(producer, enable_autoselect)
        return function()
          local select = require("snap.select.lsp")
          snap.run({
            producer = filter(producer),
            select = select.select,
            autoselect = enable_autoselect and select.autoselect or nil,
            views = { require("snap.preview.lsp") },
          })
        end
      end

      local actions_config = {
        {
          keys = "<F2>",
          action = vim.lsp.buf.rename,
          enable = function(client)
            return client.supports_method(vim.lsp.protocol.Methods.textDocument_rename)
          end,
        },
        {
          keys = "gd",
          action = lsp_action(producers.definitions, true),
          enable = function(client)
            return client.supports_method(vim.lsp.protocol.Methods.textDocument_definition)
          end,
        },
        {
          keys = "gr",
          action = lsp_action(producers.references, true),
          enable = function(client)
            return client.supports_method(vim.lsp.protocol.Methods.textDocument_references)
          end,
        },
        {
          keys = "gi",
          action = lsp_action(producers.implementations, true),
          enable = function(client)
            return client.supports_method(vim.lsp.protocol.Methods.textDocument_implementation)
          end,
        },
        {
          keys = "<space>D",
          action = lsp_action(producers.type_definitions, true),
          enable = function(client)
            return client.supports_method(vim.lsp.protocol.Methods.textDocument_typeDefinition)
          end,
        },
        {
          keys = "gb",
          action = lsp_action(producers.symbols, false),
          enable = function(client)
            return client.supports_method(vim.lsp.protocol.Methods.textDocument_documentSymbol)
          end,
        },
        {
          keys = "[d",
          action = function()
            vim.diagnostic.jump({ count = -1 })
          end,
        },
        {
          keys = "]d",
          action = function()
            vim.diagnostic.jump({ count = 1 })
          end,
        },
        {
          keys = "[e",
          action = function()
            vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
          end,
        },
        {
          keys = "]e",
          action = function()
            vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
          end,
        },
      }

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          for _, value in ipairs(actions_config) do
            if value.enable == nil or value.enable(client) then
              vim.keymap.set("n", value.keys, value.action, { buffer = args.buf })
            end
          end
        end,
      })
    end,
  },
}
