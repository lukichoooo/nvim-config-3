return {
	"Exafunction/windsurf.vim",
	event = "BufEnter",
	config = function()
		vim.g.codeium_manual = false -- change to false for manual autocomplete
		vim.g.codeium_idle_delay = 0
		vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = "#aaaaaa", bg = "#1e1e2e" })
	end,
}
