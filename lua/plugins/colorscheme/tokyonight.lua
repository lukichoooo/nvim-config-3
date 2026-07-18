return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		style = "night",
		on_colors = function(colors)
			colors.bg = "#0d0d0d"
			colors.bg_dark = "#090909"
		end,
		on_highlights = function(hl, _)
			hl.DiagnosticUnderlineWarn = { fg = "#5a6a8a", undercurl = true, sp = "#e0af68" }
		end,
	},
	config = function(_, opts)
		require("tokyonight").setup(opts)
		vim.cmd.colorscheme("tokyonight")
	end,
}
