return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	opts = {
		ensure_installed = {
			"stylua",
			"sonarlint-language-server",
			"black",
			"isort",
			"prettier",
			"prettierd",
		},
	},
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
	},
}
