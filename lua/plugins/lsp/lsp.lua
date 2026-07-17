return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			local keymap = vim.keymap
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }

					-- set keybindings
					opts.desc = "Show LSP references"
					keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

					opts.desc = "Go to declaration"
					keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

					opts.desc = "Show LSP definition"
					keymap.set("n", "gd", vim.lsp.buf.definition, opts)

					opts.desc = "Show LSP implementations"
					keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

					opts.desc = "See Code Actions"
					keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

					opts.desc = "Smart Rename"
					keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)

					opts.desc = "Show Diagnostics under cursor"
					keymap.set("n", "<A-k>", vim.diagnostic.open_float, opts)

					opts.desc = "Show Docs under cursor"
					keymap.set("n", "K", vim.lsp.buf.hover, opts)
				end,
			})

			local severity = vim.diagnostic.severity
			vim.diagnostic.config({
				signs = {
					text = {
						[severity.ERROR] = ";<",
						[severity.WARN] = "W",
						[severity.INFO] = ";3",
						[severity.HINT] = ";>",
					},
				},
			})
		end,
	},
}
