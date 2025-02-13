-- Iterm2 -> Preferemces -> Keys -> Key Bindings -> (+) to add -> Cmd-S: [Send text with "vim" special characters]: \<C-s>
vim.api.nvim_set_keymap("n", "<C-s>", ":w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-s>", "<Esc>:w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<D-s>", ":w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<D-s>", "<Esc>:w<CR>", { noremap = true, silent = true })

-- vim.api.nvim_set_option("clipboard","unnamed") -- deprecated?

vim.cmd("source ~/.vimrc")

return {}
