return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	opts = {
		ensure_installed = {
			"stylua",
			"sonarlint-language-server",
		},
	},
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
	},
}
