vim.diagnostic.config({
  underline = true,
  severity_sort = true,
  virtual_lines = false,
  virtual_text = false,
  -- virtual_text = {
  --   spacing = 4,
  --   source = "if_many",
  --   prefix = "●",
  -- },
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "if_many",
    header = "",
    prefix = "",
  },
})
