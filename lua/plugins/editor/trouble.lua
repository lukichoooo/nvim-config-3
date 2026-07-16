return {
  "folke/trouble.nvim",
  opts = {
    focus = true,
    auto_close = true,
    modes = {
      diagnostics = {
        filter = {
          severity = {
            min = vim.diagnostic.severity.ERROR,
            max = vim.diagnostic.severity.WARN,
          },
        },
      },
    },
  },
  keys = {
    {
      "<A-q>",
      function()
        require("trouble").toggle("diagnostics")
      end,
      desc = "Diagnostics (Trouble)",
    },
  },
}
