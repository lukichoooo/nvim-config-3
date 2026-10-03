return {
	"nickjvandyke/opencode.nvim",
	dependencies = {
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {
			server = {
				-- Attach to the already-running `opencode` background service.
				-- Never start a new instance or open any window.
				start = false,
				connect = true,
				url = function(callback)
					local ok, lines = pcall(vim.fn.readfile, vim.env.HOME .. "/.local/state/opencode/service-prod.json")
					if not ok or not lines then
						callback(nil)
						return
					end
					local ok2, svc = pcall(vim.json.decode, table.concat(lines, "\n"))
					if ok2 and svc and svc.url then
						require("opencode.config").opts.server.password = svc.password
						callback(svc.url)
					else
						callback(nil)
					end
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
