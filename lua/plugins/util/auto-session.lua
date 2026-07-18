vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,localoptions"

-- automatically restore buffers
return {
	"rmagatti/auto-session",
	config = function()
		require("auto-session").setup({
			auto_restore = true,
			auto_save = true,
			enabled = true,
			log_level = "info",
			root_dir = "/home/luka/.local/share/nvim/sessions/",
			suppressed_dirs = { "~/", "~/Downloads" },
		})

		-- optional: create a command to restore manually
		vim.api.nvim_create_user_command("RestoreSession", function()
			require("auto-session").RestoreSession()
		end, {})
	end,
}
