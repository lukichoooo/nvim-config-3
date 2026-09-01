return {
	"GustavEikaas/easy-dotnet.nvim",
	ft = { "cs", "csproj", "sln" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"mfussenegger/nvim-dap",
		"folke/snacks.nvim",
	},
	capabilities = {
		workspace = {
			didChangeWatchedFiles = {
				dynamicRegistration = true,
			},
		},
	},
	config = function()
		require("easy-dotnet").setup({
			lsp = {
				restart_roslyn_on_branch_change = true,
			},
		})
	end,
}
