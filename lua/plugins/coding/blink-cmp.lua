return {
	"saghen/blink.cmp",
	version = "*",
	dependencies = { { "saghen/blink.lib", version = "*" } },
	build = function()
		require("blink.cmp").build():pwait()
	end,
	opts = {
		completion = { documentation = { auto_show = true } },
		sources = {
			per_filetype = {
				opencode_ask = {}, -- disable autocomplete for opencode_ask
			},
		},
		keymap = {
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<C-Space>"] = { "show", "fallback" },
		},
	},
	fuzzy = { implementation = "rust" },
}
