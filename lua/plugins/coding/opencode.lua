return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {
			server = {
				port = 4096,
				start = function()
					-- no-op, connect to existing opencode
				end,
				stop = function()
					-- no-op
				end,
				toggle = function()
					-- no-op
				end,
			},
		}

		-- Required for opts.events.reload.
		vim.o.autoread = true

		-- Recommended/example keymaps.
		vim.keymap.set({ "n", "x" }, "<A-m>", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask opencode…" })

		vim.keymap.set({ "n", "x" }, "<A-,>", function()
			require("opencode").select()
		end, { desc = "Execute opencode action…" })

		-- vim.keymap.set({ "n", "t" }, "<A-.>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

		vim.keymap.set({ "n", "x" }, "<A-n>", function()
			return require("opencode").operator("@this ")
		end, { desc = "Add range to opencode", expr = true })
	end,
}
