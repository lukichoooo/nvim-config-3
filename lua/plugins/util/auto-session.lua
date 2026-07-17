vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos"

-- automatically restore buffers
return {
	"rmagatti/auto-session",
	config = function()
		require("auto-session").setup({
			log_level = "info",
			auto_session_enabled = true,
			auto_save_enabled = true,
			auto_restore_enabled = true,
			auto_session_suppress_dirs = { "~/", "~/Downloads" },
			auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
		})

		-- optional: create a command to restore manually
		vim.api.nvim_create_user_command("RestoreSession", function()
			require("auto-session").RestoreSession()
		end, {})
	end,
}
