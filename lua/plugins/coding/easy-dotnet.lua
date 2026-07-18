return {
	"GustavEikaas/easy-dotnet.nvim",
	ft = { "cs", "csproj", "sln" },
	dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
	config = function()
		require("easy-dotnet").setup()
	end,
}
