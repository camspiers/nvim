return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Completion sources
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        -- Enabled except when in comments
        enabled = function()
          local context = require("cmp.config.context")
          return not (context.in_treesitter_capture("comment") == true or context.in_syntax_group("Comment"))
        end,
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete({}),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }, {
          { name = "buffer" },
        }),
      })
      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { "williamboman/mason.nvim", config = true },
      { "williamboman/mason-lspconfig.nvim" },
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = {
        robotframework_ls = {
          capabilities = capabilities,
        },
        lua_ls = {
          capabilities = capabilities,
        },
        html = {
          capabilities = capabilities,
          filetypes = { "html", "vue" },
        },
        cssls = {
          capabilities = capabilities,
          settings = {
            validate = true,
            lint = {
              -- For tailwindcss @apply
              unknownAtRules = "ignore",
            },
          },
        },
        tailwindcss = {
          capabilities = capabilities,
          filetypes = { "html", "react", "vue" },
        },
        ts_ls = {
          capabilities = capabilities,
          filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact", "react", "vue" },
          -- init_options = {
          --   plugins = {
          --     {
          --       name = "@vue/typescript-plugin",
          --       -- Location of @vue/typescript-plugin
          --       location = vim.fn.stdpath("data")
          --         .. "/mason/packages/vue-language-server/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin",
          --       languages = { "javascript", "typescript", "vue" },
          --     },
          --   },
          -- },
        },
        volar = {
          capabilities = capabilities,
        },
        eslint = {
          capabilities = capabilities,
        },
      }

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
          },
          severity_sort = true,
        },
        inlay_hints = {
          enabled = false,
        },
      })

      -- Register the LSP servers
      for server, config in pairs(servers) do
        require("lspconfig")[server].setup(config)
      end

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
