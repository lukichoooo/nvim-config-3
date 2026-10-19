return {
	"nickjvandyke/opencode.nvim",
	dependencies = {
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {
			server = {
				-- Attach to the already-running `opencode` v2 background service.
				-- OpenCode v2.0.x writes `service-prod.json`; newer versions may
				-- write `service.json`, so accept either one.
				-- Never start a new instance or open any window.
				start = false,
				connect = true,
				url = function(callback)
					local home = vim.uv.os_homedir() or vim.env.HOME or ""
					local state_dir = (vim.env.XDG_STATE_HOME and vim.env.XDG_STATE_HOME ~= "")
							and vim.fs.joinpath(vim.env.XDG_STATE_HOME, "opencode")
						or vim.fs.joinpath(home, ".local", "state", "opencode")

					for _, name in ipairs({ "service.json", "service-prod.json" }) do
						local path = vim.fs.joinpath(state_dir, name)
						local ok, lines = pcall(vim.fn.readfile, path)
						if ok and lines and #lines > 0 then
							local decoded_ok, svc = pcall(vim.json.decode, table.concat(lines, "\n"))
							if decoded_ok and svc and svc.url then
								require("opencode.config").opts.server.password = svc.password
								callback(svc.url)
								return
							end
						end
					end

					callback(nil)
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
