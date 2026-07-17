return {
	"saghen/blink.cmp",
	build = function()
		require("blink.cmp").build():pwait()
	end,
	dependencies = { "saghen/blink.lib" },
	opts = {
		completion = { documentation = { auto_show = true } },
		keymap = {
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<C-Space>"] = { "show", "fallback" },
		},
	},
	fuzzy = { implementation = "rust" },
}
