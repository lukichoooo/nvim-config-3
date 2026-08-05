return {
	"GustavEikaas/easy-dotnet.nvim",
	ft = { "cs", "csproj", "sln" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"mfussenegger/nvim-dap",
		"folke/snacks.nvim",
	},
	config = function()
		require("easy-dotnet").setup()
	end,
}
