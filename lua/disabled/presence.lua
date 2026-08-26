return {
	"andweeb/presence.nvim",
	event = "VeryLazy",
	config = function()
		require("presence").setup({
			-- log_level = "debug",
		})
	end,
}
