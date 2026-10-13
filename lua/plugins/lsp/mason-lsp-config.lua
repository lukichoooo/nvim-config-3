return {
	"mason-org/mason-lspconfig.nvim",
	opts = {
		ensure_installed = {
			"clangd",
			"ts_ls",
			"cspell_ls",
		},
	},
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
	},
}
