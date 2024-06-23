return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      local dap = require("dap")

      dap.adapters["pwa-node"] = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug-adapter",
          args = {
            "${port}",
          },
        },
      }

      if pcall(require, "ports") then
        local dockerConfiguration = {
          type = "pwa-node",
          request = "attach",
          name = "Docker Attach",
          localRoot = "${workspaceFolder}/server",
          remoteRoot = "/app/server",
          outFiles = {
            "${workspaceFolder}/server/build/**/*.js",
          },
          sourceMaps = true,
          protocol = "inspector",
          port = function()
            return coroutine.create(function(dap_run_co)
              vim.ui.select(require("ports"), {
                prompt = "Port> ",
                format_item = function(item)
                  return item.name
                end,
              }, function(choice)
                coroutine.resume(dap_run_co, choice.port)
              end)
            end)
          end,
        }

        dap.configurations.javascript = {
          dockerConfiguration,
        }

        dap.configurations.typescript = {
          dockerConfiguration,
        }
      end

      vim.keymap.set("n", "<F5>", function()
        require("dap").continue()
      end)
      vim.keymap.set("n", "<F10>", function()
        require("dap").step_over()
      end)
      vim.keymap.set("n", "<F11>", function()
        require("dap").step_into()
      end)
      vim.keymap.set("n", "<F12>", function()
        require("dap").step_out()
      end)
      vim.keymap.set("n", "<Leader>b", function()
        require("dap").toggle_breakpoint()
      end)
      vim.keymap.set("n", "<Leader>dr", function()
        require("dap").repl.open()
      end)
      vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
        require("dap.ui.widgets").preview()
      end)
    end,
  },
}
