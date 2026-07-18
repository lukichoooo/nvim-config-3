vim.g.mapleader = " "

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Briefly highlight yanked text",
	group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
	end,
})

vim.keymap.set("v", "<C-S-c>", '"+y', { desc = "Copy to system clipboard" })

-- Clear search highlight on ESC
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>")

-- VIM STUFF
vim.opt.number = true -- show absolute line numbers
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.autoindent = true -- maintain indent
vim.opt.smarttab = true -- smart tab behavior

----------------------- Overwrite without clipboard change
vim.keymap.set("x", "<leader>p", '"_dP', { silent = true })

-- vim.opt.clipboard = "unnamedplus" -- use system clipboard

-- line wrap
-- vim.opt.wrap = false

-- keep cursor centered when jumping
-- vim.keymap.set("n", "<C-d>", "<C-d>zz")  causes error's with animation so commented out
-- vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- make vim more responsive ???
-- vim.opt.updatetime = 50

-- vertical column to the right
vim.opt.colorcolumn = "100"
