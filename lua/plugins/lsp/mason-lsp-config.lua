return {
	"mason-org/mason-lspconfig.nvim",
	opts = {
		ensure_installed = {
			"stylua",
			"clangd",
			"scpell_lsp",
			"ts_ls",
		},
	},
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
	},
}
