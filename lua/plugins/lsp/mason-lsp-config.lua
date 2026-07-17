return {
	"mason-org/mason-lspconfig.nvim",
	opts = {
		ensure_installed = {
			"stylua",
			"clangd",
			"scpell_lsp",
		},
	},
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
	},
}
