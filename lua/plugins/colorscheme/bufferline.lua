return {
  "akinsho/bufferline.nvim",
  optional = false,
  opts = function(_, opts)
    if (vim.g.colors_name or ""):find("catppuccin") then
      opts.highlights = require("catppuccin.special.bufferline").get_theme()
    end
  end,
}
