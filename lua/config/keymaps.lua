-- search
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fa", function()
	builtin.find_files({ hidden = true, no_ignore = true })
end, { desc = "Telescope find files (incl. hidden/ignored)" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
-- snacks find and replace <leader>fr

-- sidebar
vim.keymap.set("n", "<leader>e", function()
	Snacks.explorer()
end, { desc = "File Explorer" })

------------------------------------------------------- Windsurf / Codeium AI
vim.g.codeium_disable_bindings = 1

-- manual trigger
vim.keymap.set("i", "<A-k>", function()
	return vim.fn["codeium#Complete"]()
end, { expr = true, silent = true })

-- accept full suggestion
vim.keymap.set("i", "<A-h>", function()
	return vim.fn["codeium#Accept"]()
end, { expr = true, silent = true })

-- next suggestion
vim.keymap.set("i", "<A-l>", function()
	return vim.fn["codeium#CycleCompletions"](1)
end, { expr = true, silent = true })

-- previous suggestion
vim.keymap.set("i", "<A-j>", function()
	return vim.fn["codeium#CycleCompletions"](-1)
end, { expr = true, silent = true })
